#!/usr/bin/env python

import time
import sys
from pynput import mouse

class MyException(Exception):
    pass

def on_move(x, y):
    print('Pointer moved to {0}'.format(
        (x, y)))

def on_click(x, y, button, pressed):
    print('{0} at {1}'.format(
        'Pressed' if pressed else 'Released',
        (x, y)))
    if ((not pressed) and (button.name == 'left')):
        MyException(button)

def on_scroll(x, y, dx, dy):
    print('Scrolled {0} at {1}'.format(
        'down' if dy < 0 else 'up',
        (x, y)))

# Collect events until released

listener = mouse.Listener(
        on_move=on_move,
        on_click=on_click,
        on_scroll=on_scroll)

listener.start()
try:
    listener.wait()
    while True:
        print('.')
        time.sleep(1)
except MyException as e:
    print('{0} was clicked'.format(e.args[0]))
    listener.stop()
    sys.exit(0)
