import logging

from time import sleep
from timeit import default_timer

# Init logger
logging.basicConfig(filename='monitor.log', format='%(asctime)s [NOK_ROBOT] - %(message)s', level=logging.DEBUG)

# NOK robot start
logging.debug('Start')

# Asynchronous sleep
def aSleep(delay):
	count = 0
	time0 = default_timer()
	while (default_timer() < time0 + delay):
		count += 1
		logging.debug('%s', count)
		sleep(1)

aSleep(20)

# NOK robot stop
logging.debug('Stop')
