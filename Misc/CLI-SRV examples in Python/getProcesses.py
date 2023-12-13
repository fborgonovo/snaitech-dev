#!/usr/bin/env python

import wmi

# connecting to local machine
conn = wmi.WMI()
# connecting to remote machines
#conn = wmi.WMI("xxx.xxx.xxx.xxx", user="", password="")

for process in conn.Win32_Process():
    print(process.ProcessId, process.Name)
