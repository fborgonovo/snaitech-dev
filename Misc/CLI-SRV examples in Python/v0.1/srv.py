#!/usr/bin/env python
 
"""
    Server module.

	Waits for a message from a client and bounce it back.
	The received message contains the name of the program to be launched, the name 
	of the process that will be executed and the timeout after which it	will be killed
	if the task can not complete in the designated time window. As soon as the message
	is received a thread is launched to carry on the task and the server go back waiting
	for the next message.

	Command parameters:
	
	server_name  -> Name of the server (default "localhost")
	program_name -> Full name of the program file
	process_name -> Process name
	timeout      -> Timeout

	Command format: "program_name#process_name#timeout"
"""

import socket
import sys
import logging
import threading
import subprocess
#import os
from time import sleep

"""
__author__ = "Furio Angelo Borgonovo"
__copyright__ = ""
__date__ = "Aug 2019"
__credits__ = [""]
__license__ = ""
__version__ = "0.1"
__maintainer__ = "Furio Angelo Borgonovo"
__email__ = "furio.borgonovo@snaitech.it"
__status__ = "Prototype"
"""

# Utility functions
def is_process_running(pid):
	try:
		subprocess.kill(pid, 0)
		logging.debug('[WRK] - Process is running: %s' % (pid))
		return True
	except OSError:
		logging.debug('[WRK] - Process is not running: %s' % (pid))
		return False
"""
def ms_win_kill(pid):
	import win32api
	handle = win32api.OpenProcess(1, False, pid)
	logging.debug('[WRK] - PID: %s. Handle: %s' % (pid, handle))
	return (0 != win32api.TerminateProcess(handle, -1))

def killPID(pid, sig=None):
	try:
		if sig is None:
			from signal import SIGTERM
			sig = SIGTERM
		return (subprocess.kill(pid, sig))
	except (AttributeError, ImportError):
		import win32api
		if win32api:
			handle = win32api.OpenProcess(1, False, pid)
			win32api.TerminateProcess(handle, -1)
			win32api.CloseHandle(handle)
		return True
"""
#### Worker thread function begin
def worker(command, tmo):
	DETACHED_PROCESS = 0x0000008
	thread_name = threading.currentThread().getName()
	logging.debug('[WRK] - Thread %s started. Command: %s, timeout: %s' % (thread_name, command, tmo))
	p = subprocess.Popen(["python", command.split()],
	                     creationflags=DETACHED_PROCESS)
	sleep(int(tmo)+1)
	logging.debug('[WRK] - Timeout expired.')
    # kill after 'tmo' seconds if process doesn't end before
	if p.poll() is None:
		logging.debug('[WRK] - # WARNING # Timeout expired. PID %s still running.', p.pid)
		logging.debug('[WRK] - Killing process %s with PID %s' % (command, p.pid))
		p.kill()
		sleep(1)
		if p.poll() is None:
			logging.debug('[WRK] - # WARNING # Process kill failed. PID %s still running.', p.pid)
		else:
			logging.debug('[WRK] - Process killed. PID %s terminated.', p.pid)
	else:
		logging.debug('[WRK] - PID %s has terminated.', p.pid)
	logging.debug('[WRK] - Thread %s exit.', thread_name)
	return
#### Worker thread function end

# Check arguments
if (__name__ == "__main__"):
	if (len(sys.argv) != 2):
		exit("Usage: %s <server_name>" %
		     sys.argv[0])

# Init logger
logging.basicConfig(filename='monitor.log', format='%(asctime)s %(message)s', level=logging.DEBUG)

# Create a TCP/IP socket
logging.debug('[SRV] - Creating TCP/IP socket')
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the address given on the command line
server_name = sys.argv[1]
server_name = 'localhost'
server_address = (server_name, 10001)
logging.info('[SRV] - starting up on server %s %s port %s' % (socket.gethostname(), server_address[0], server_address[1]))
sock.bind(server_address)

# Listen for incoming connections
logging.debug('[SRV] - Listen for incoming connections')
sock.listen(1)

while True:

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
				(process_name, command, process_tmo) = request.split("#")
				logging.info('[SRV] - Thread %s executing %s command with %s timeout' % (process_name, command, process_tmo))
				w = threading.Thread(name=process_name, target=worker, args=(command,process_tmo,))
				w.start()
				break

	finally:
		# Clean up the connection
		logging.info('[SRV] - Closing connection')
		connection.close()

logging.info('[SRV] - Server terminated')
sleep(1.0)
