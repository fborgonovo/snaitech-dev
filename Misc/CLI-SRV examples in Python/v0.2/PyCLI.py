#!/usr/bin/env python
 
"""
    Client module.

	Send a message to the server and waits for that message to be bounced back.
	The sent message contains the name of the program to be launched, the name 
	of the process that will be executed and the timeout after which the server
	will kill it if the task is not completed.

	Parameter(s):
	
	server_name  -> Name of the server (if on the same machine use "localhost")
	process_name -> Process name
	program_name -> Full name of the program file
	timeout      -> Timeout

	Message data:
	
	process_name -> Process name
	program_name -> Full name of the program file
	timeout      -> Timeout
	
	Command format: "process_name#program_name#timeout"

	History:

	v0.1 : Project start
	v0.2 : Parameters order congruity check
			Handlers for abnormal termination added
			Minor log messages modification
"""

import socket
import sys
import logging
import wmi
from time import sleep

"""
__author__ = "Furio Angelo Borgonovo"
__copyright__ = ""
__date__ = "Aug 2019"
__credits__ = [""]
__license__ = ""
__version__ = "0.3"
__maintainer__ = "Furio Angelo Borgonovo"
__email__ = "furio.borgonovo@snaitech.it"
__status__ = "Prototype"
"""

# Check if the passed process is active active
def checkProcessStatus(processName):
	# connecting to local machine
	conn = wmi.WMI()
	for process in conn.Win32_Process(name="py.exe"):
		if processName in process.CommandLine:
			return True
	return False

# Check arguments
if (__name__ == "__main__"):
	if (len(sys.argv) != 5):
		exit("Usage: %s <server_name> <process_name> <program_name> <timeout>" %
		     sys.argv[0])

server_name  = sys.argv[1]
process_name = sys.argv[2]
program_name = sys.argv[3]
timeout = sys.argv[4]

if not checkProcessStatus("PySRV"):
	print('[CLI] - PySRV not active. Request aborted.')
	sys.exit()

# Init logger
logging.basicConfig(filename='monitor.log', format='%(asctime)s [CLI] - %(message)s', level=logging.DEBUG)

logging.info('-------------------------------------------------------------------------------')
logging.info('--- PyCLI starts --------------------------------------------------------------')
logging.info('-------------------------------------------------------------------------------')

# Create a TCP/IP socket
logging.debug('Creating TCP/IP socket')
sock_cli = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect the socket to the port where the server is listening
server_address = (server_name, 10001)
logging.info('Connecting to %s (%s port %s)' % (server_name, server_address[0], server_address[1]))
sock_cli.connect(server_address)

try:
	# Send data
	message = "%s#%s#%s" % (process_name, program_name, timeout)
	logging.info('Sending: >>>"%s"<<<' % message)
	sock_cli.sendall(message.encode('utf-8'))

	# Look for the response
	amount_received = 0
	amount_expected = len(message)

	while amount_received < amount_expected:
		logging.info('Waiting response')
		data = sock_cli.recv(16)
		amount_received += len(data)
		logging.info('Received %s bytes (total: %s)' % (len(data), amount_received))
		logging.info('Message: >>>%s<<<' % data)

finally:
	logging.debug('Closing socket')
	sock_cli.close()
	logging.debug('Client terminated')

logging.shutdown()

