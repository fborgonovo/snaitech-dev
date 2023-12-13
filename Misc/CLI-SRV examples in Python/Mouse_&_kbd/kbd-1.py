#!/usr/bin/env python

import traceback
from pynput import keyboard

message = ""

def log_traceback(ex):
    tb_lines = traceback.format_exception(ex.__class__, ex, ex.__traceback__)
    tb_text = ''.join(tb_lines)

    print(tb_text)

def on_press(key):
    global message
    try:
        if key == keyboard.Key.enter:
            if message != "":
                print('Sending message: {0}'.format(message))
###TBD Clever send message function call here
                message = ""
        else:
            print('alphanumeric key {0} pressed'.format(key.char))
            if (key.char).isalnum:
                message = message + key.char
                print("Message: {0} added char: {1}".format(message, key.char))
    except AttributeError:
        print('special key {0} pressed'.format(key))

def on_release(key):
    print('{0} released'.format(key))
    if key == keyboard.Key.esc:  # Stop listener
        return False

with keyboard.Listener(
        on_press=on_press,
        on_release=on_release) as listener:
    try:
        listener.join()
        print('Client terminated.')
    except Exception as ex:
        print('*** ABNORMAL CLIENT TERMINATION ***')
        log_traceback(ex)
