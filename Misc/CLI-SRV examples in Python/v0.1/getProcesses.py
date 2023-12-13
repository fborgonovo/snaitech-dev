#!/usr/bin/env python

import wmi

c = wmi.WMI()

for process in c.Win32_Process():
    print(process.ProcessId, process.Name)
