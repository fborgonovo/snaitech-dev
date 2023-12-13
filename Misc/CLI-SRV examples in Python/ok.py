import logging

from time import sleep
from timeit import default_timer

# Init logger
logging.basicConfig(filename='monitor.log', format='%(asctime)s [OK_ROBOT] - %(message)s', level=logging.DEBUG)

# OK robot start
logging.debug('Start')

# Asynchronous sleep
def aSleep(delay):
	count = 0
	time0 = default_timer()
	while (default_timer() < time0 + delay):
		count += 1
		logging.debug('%s', count)
		sleep(1)

"""
-------------------------------------------------------------------------------
Program starts here
-------------------------------------------------------------------------------
"""

"""
-------------------------------------------------------------------------------
Program ends here
-------------------------------------------------------------------------------
"""

aSleep(10)

# OK robot stop
logging.debug('Stop')
