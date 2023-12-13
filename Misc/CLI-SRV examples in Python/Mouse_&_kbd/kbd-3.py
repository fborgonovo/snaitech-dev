#!/usr/bin/env python

# https://tutorialedge.net/python/concurrency/asyncio-event-loops-tutorial/
# https://asyncio.readthedocs.io/en/latest/producer_consumer.html
# https://docs.python.org/2/library/queue.html
# https://realpython.com/async-io-python/#using-a-queue


import logging
import random
import string
import attr
import asyncio
import traceback
import time
import random
from pynput import keyboard

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s,%(msecs)d %(levelname)s: %(message)s",
    datefmt="%H:%M:%S",
)

BREAK_CMD = 'quit'

def log_traceback(ex):
    tb_lines = traceback.format_exception(ex.__class__, ex, ex.__traceback__)
    tb_text = ''.join(tb_lines)
    print(tb_text)

#===================================================================================================

async def readKeyboard(queue):
#    global usrMessage

    print('readKeyboard START')
    userName = "usr1"
    prompt = "{}> ".format(userName)

    while True:
        try:
            usrMessage = input(prompt) # raw_input in python 2
            if usrMessage == "":
                continue

            print("User input: {0}".format(usrMessage))
            
            await queue.put(usrMessage)
            print('readyKeyboard added <{0}> to the queue'.format(usrMessage))
            print('readyKeyboard - There are {} items in queue'.format(queue.qsize()))
            usrMessage = ""

        except KeyboardInterrupt:
            print('readKeyboard *** EMERGENCY USER TERMINATION - readKeybord ***')
            await queue.put(None)

        except Exception as ex:
            print('readKeyboard *** ABNORMAL CLIENT TERMINATION - readKeybord ***')
            log_traceback(ex)
            await queue.put(None)
'''
def writeConsole():
#    global srvMessage
    while True:
        try:

        except Exception as ex:
           print('*** ABNORMAL CLIENT TERMINATION - writeConsole ***')
           log_traceback(ex)

def reciveFromServer():
#   global srvMessage

    while True:
        try:

        except Exception as ex:
            print('*** ABNORMAL CLIENT TERMINATION - reciveFromServer ***')
            log_traceback(ex)
'''

async def sendToServer(queue):
#    global usrMessage

    print('sendToServer START')
    while True:
        try:
            print('sendToServer - There are {} items in queue'.format(queue.qsize()))
            print('sendToServer ready to work...')
            usrMessage = await queue.get_nowait()
            print('sendToServer - There are {} items in queue'.format(queue.qsize()))
    #        await asyncio.sleep(random.random())
            print('sendToServer received message to transmit <{0}>'.format(usrMessage))
            if usrMessage == BREAK_CMD:
                print('sendToServer - User shut down.')
                exit
            else:
                print("sendToServer sending: {0}".format(usrMessage))
                queue.task_done()
        except asyncio.queues.QueueEmpty:
            print('sendToServer - Queue is empty.')
        except Exception as ex:
            print('*** ABNORMAL CLIENT TERMINATION - sendToServer ***')
            log_traceback(ex)

#===================================================================================================

def main():
    queue = asyncio.Queue()
    loop = asyncio.get_event_loop()

    try:
        loop.create_task(sendToServer(queue))
        loop.create_task(readKeyboard(queue))
        loop.run_forever()
    except KeyboardInterrupt:
        logging.info("Process interrupted.")
    finally:
        loop.close()
        logging.info("Successfully shutdown.")

if __name__ == "__main__":
    main()
