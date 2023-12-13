#!/usr/bin/env python

# Chat client

import threading
import socket
import select
import string
import sys
import binascii
import struct

def prompt():
	sys.stdout.write('<Cli> ')
	sys.stdout.flush()

#A typical sequence of a socket connection.
#1 - Create socket
#2 - Bind the Socket to an IP and Port
#3 - Instruct the OS to accept connections as per specifications above.
#4 - Instruct the OS to recv-send data via the sockets.
#5 - Close Socket when it is not needed any longer.

sckt = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_address = ('localhost', 10001)
sckt.connect((server_address))

def client_send():
        values = ('a')
        packer = struct.Struct('s')
        packed_data = packer.pack(values)
        sckt.send(packed_data)
"""
        while True:
        message = input("[CLI] ")
        values = (message)
        s = struct.Struct('s')
        packed_data = s.pack(*values)
        sckt.send(packed_data)
"""

def client_recv():
        while True:
                packed_data = sckt.recv(1024)
                unpacker = struct.Struct('s')
                unpacked_data = unpacker.pack(packed_data)
                print("received", repr(unpacked_data))

thread_send = []
thread_rcv = []
num_threads = 10

for loop_1 in range(num_threads):
        thread_send.append(threading.Thread(target=client_send))
        thread_send[-1].start()

for loop_2 in range(num_threads):
        thread_rcv.append(threading.Thread(target=client_recv))
        thread_rcv[-1].start()
