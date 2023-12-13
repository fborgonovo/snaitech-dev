#!/usr/bin/env python
 
"""
    Server module.

	Waits for a message from a client and bounce it back.
	The received message contains the name of the program to be launched, the name 
	of the process that will be executed and the timeout after which it	will be killed
	if the task can not complete in the designated time window. As soon as the message
	is received a thread is launched to carry on the task and the server go back waiting
	for the next message.

	Parameter(s):

	server_name  -> Name of the server (if on the same machine use "localhost")

	Message data:
	
	process_name -> Process name
	program_name -> Full name of the program file
	timeout      -> Timeout

	Command format: "process_name#program_name#timeout"
	
	History:

	v0.1 :	Project start
	v0.2 :	Parameters order congruity check
			Handlers for abnormal termination added
			Minor log messages modification
	v0.3 :	Changed message receive method from sync
			to async
			Multi connection support?
"""

import socket
import sys
import logging
import threading
import subprocess
#import os
from sys import exit
from signal import signal, SIGINT
from time import sleep

"""
__author__ = "Furio Angelo Borgonovo"
__copyright__ = ""
__date__ = "Aug 2019"
__credits__ = [""]
__license__ = ""
__version__ = "0.2"
__maintainer__ = "Furio Angelo Borgonovo"
__email__ = "furio.borgonovo@snaitech.it"
__status__ = "Prototype"
"""

# Utility functions
"""
def is_process_running(pid):
	try:
		subprocess.kill(pid, 0)
		logging.debug('[WRK] - Process is running: %s' % (pid))
		return True
	except OSError:
		logging.debug('[WRK] - Process is not running: %s' % (pid))
		return False
"""
# Interrupts handler
def handler(signal_received, frame):
    # Handle any cleanup here
    print('[SRV] - SIGINT or CTRL-C detected. Exiting gracefully')
    exit(0)

#### Worker thread function begin
def worker(process_name, program_name, tmo):
	DETACHED_PROCESS = 0x0000008
	thread_name = threading.currentThread().getName()
	logging.debug('[WRK] - Thread %s started. Program: %s, timeout: %s' % (process_name, program_name, tmo))
	p = subprocess.Popen(["python", program_name],
	                     creationflags=DETACHED_PROCESS)
	sleep(int(tmo)+1)
	logging.debug('[WRK] - Timeout expired.')
    # kill after 'tmo' seconds if process doesn't end before
	if p.poll() is None:
		logging.debug('[WRK] - # WARNING # Timeout expired. PID %s still running.', p.pid)
		logging.debug('[WRK] - Killing process %s with PID %s' % (process_name, p.pid))
		p.kill()
		sleep(1)
		if p.poll() is None:
			logging.debug('[WRK] - # WARNING # Process kill failed. PID %s still running.', p.pid)
		else:
			logging.debug('[WRK] - Process killed. PID %s terminated.', p.pid)
	else:
		logging.debug('[WRK] - PID %s terminated.', p.pid)
	logging.debug('[WRK] - Thread %s exit.', thread_name)
	return
#### Worker thread function end

### Main program starts

# Check arguments
if (__name__ == "__main__"):
	if (len(sys.argv) != 2):
		exit("Usage: %s <server_name>" %
		     sys.argv[0])
	# Tell Python to run the handler() function when SIGINT is recieved
	signal(SIGINT, handler)

# Init logger
logging.basicConfig(filename='monitor.log', format='%(asctime)s %(message)s', level=logging.DEBUG)

# Create a TCP/IP socket
logging.info('-------------------------------------------------------------------------------')
logging.info('--- PySRV starts --------------------------------------------------------------')
logging.info('-------------------------------------------------------------------------------')
logging.debug('[SRV] - Creating TCP/IP socket')
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the address given on the command line
### TBD : Implement remote execution in a future version
server_name = sys.argv[1]
server_name = 'localhost'
server_address = (server_name, 10001)
logging.info('[SRV] - starting up on server %s %s port %s' % (socket.gethostname(), server_address[0], server_address[1]))
sock.bind(server_address)

# Listen for incoming connections
logging.debug('[SRV] - Listen for incoming connections')
sock.listen(1)

while True:
### 
### TODO: Change to asynchronous recv
###
	# Accepting connection
	logging.debug('[SRV] - Accepting the connection')
	connection, client_address = sock.accept()

	try:
		logging.info('[SRV] - Connection from: %s', client_address)
		request = ""

		# Receive the data in small chunks and retransmit it
		while True:
			inbuf = data = connection.recv(16)
			logging.info('[SRV] - Received "%s" (decoded)' % data.decode())
			request = request + data.decode()

			if inbuf:
				logging.info('[SRV] - Sending data back to the client')
				connection.sendall(inbuf)
			else:
				logging.info('[SRV] - No more data from %s', client_address)
				(process_name, program_name, process_tmo) = request.split("#")
				logging.info('[SRV] - Thread %s executing %s command with %s timeout' % (process_name,program_name,process_tmo))
				w = threading.Thread(name="wrkTread", target=worker, args=(process_name,program_name,process_tmo,))
				w.start()
				break

	finally:
		# Clean up the connection
		logging.info('[SRV] - Closing connection')
		connection.close()

logging.info('[SRV] - Server terminated')
sleep(1.0)
