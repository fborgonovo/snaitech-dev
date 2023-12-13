#!/usr/bin/env python

# https://tutorialedge.net/python/concurrency/asyncio-event-loops-tutorial/

import asyncio
import traceback
import time
import random
from pynput import keyboard

message = ""
consoleMessage = ""
broadcast = None

def log_traceback(ex):
    tb_lines = traceback.format_exception(ex.__class__, ex, ex.__traceback__)
    tb_text = ''.join(tb_lines)
    print(tb_text)

#===================================================================================================

def readKeyboard():
    global usrMessage

    userName = "usr1"
    prompt = "{}> ".format(userName)

    while True:
        try:
            usrMessage = input(prompt) # raw_input in python 2
### TBD Send server message here
            print("Sending: {0}".format(usrMessage))
            await asyncio.sleep(random.random())
            await queue.put(usrMessage)
#            await queue.put(None)
            usrMessage = ""
        except KeyboardInterrupt:
            print('*** EMERGENCY USER TERMINATION - readKeybord ***')
            log_traceback(ex)
        except Exception as ex:
            print('*** ABNORMAL CLIENT TERMINATION - readKeybord ***')
            log_traceback(ex)

def writeConsole():
    global srvMessage

def reciveFromServer():
    global srvMessage

def sendToServer():
    global usrMessage

    while True:
        try:
            usrMessage = await queue.get()
            print('Sending message: {}...'.format(usrMessage))
            # simulate i/o operation using sleep
#            await asyncio.sleep(random.random())
        except Exception as ex:
            print('*** ABNORMAL CLIENT TERMINATION - sendToServer ***')
            log_traceback(ex)

#===================================================================================================

loop = asyncio.get_event_loop()
queue = asyncio.Queue(loop=loop)

try:
    asyncio.ensure_future(readKeyboard())
    asyncio.ensure_future(writeConsole())
    asyncio.ensure_future(reciveFromServer())
    asyncio.ensure_future(sendToServer())

    loop.run_forever()

except KeyboardInterrupt:
    print('*** CLIENT EMEERGENCY TERMINATION ***')

except Exception as ex:
    print('*** ABNORMAL CLIENT TERMINATION ***')
    log_traceback(ex)

finally:
    print("Housekeeping...")
    loop.close()
