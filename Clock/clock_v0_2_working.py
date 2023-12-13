# to make the executable:
#
# pyinstaller --onefile --icon="F:/SNAITECH dev/Workspaces/Clock/res/Oxygen-Icons.org-Oxygen-Apps-clock.ico" "clock OO.py"
#
# or:
#
# pyinstaller --onefile --noconsole --icon="F:/SNAITECH dev/Workspaces/Clock/res/Oxygen-Icons.org-Oxygen-Apps-clock.ico" "clock OO.py" (sophos mark the executables as PUA)

from tkinter import Tk, Button, font
from datetime import datetime

from clock_v0_2_options_working import ClockOptions

class Clock:
#    settings = {'foreground' : 'green'}

    def __init__(self, clock_windows):
        self.button1_color = 'green'
        self.clock_windows = clock_windows
        self.clock_windows.ontop = True
        self.clock_windows.attributes('-topmost', self.clock_windows.ontop)
        self.clock_windows.overrideredirect(True)

        self.clock_windows.clock_button = Button(clock_windows, text=datetime.now().strftime('%H:%M:%S'), bg='black', fg='green')
        button_font = font.Font(family='Advanced Pixel LCD-7', size=40, weight='bold')
        self.clock_windows.clock_button['font'] = button_font
        self.clock_windows.clock_button.pack()

        self.clock_windows.bind("<Button-1>" , self.clickwin)
        self.clock_windows.bind("<B1-Motion>", self.dragwin)
        self.clock_windows.bind("<Button-2>" , self.clock_options())
        self.clock_windows.bind("<Button-3>" , self.toggle_depth)
        self.clock_windows.bind('<Escape>', lambda e: self.clock_windows.destroy())

        self.tick()

    def clock_options(self):
        settings = {'foreground' : 'green'}
        clock_options_dlg = Tk()

        clock_options = ClockOptions
#        clock_options.root = clock_options_dlg

        b_options1 = Button(clock_options_dlg, text='Clock options')
        b_options1['command'] = lambda: clock_options('Foreground:', (settings, 'foreground'))
        b_options1.pack()

        b_options2 = Button(root, text='Foreground')
        b_options2['command'] = lambda: clock_options(settings['foreground'])
        b_options2.pack()

        root.mainloop()

    def toggle_depth(self):
        if (self.clock_windows.ontop):
            self.clock_windows.ontop = False
        else:
            self.clock_windows.ontop = True
        self.clock_windows.attributes('-topmost', self.clock_windows.ontop)

    def tick(self):
        self.clock_windows.clock_button['text'] = datetime.now().strftime(' %H:%M:%S ')
        self.clock_windows.clock_button.pack()
        self.clock_windows.after(1000, self.tick)

    def dragwin(self,event):
        x = self.clock_windows.winfo_pointerx() - self.clock_windows._offsetx
        y = self.clock_windows.winfo_pointery() - self.clock_windows._offsety
        self.clock_windows.geometry(f"+{x}+{y}")

    def clickwin(self,event):
        self.clock_windows._offsetx = self.clock_windows.winfo_pointerx() - self.clock_windows.winfo_rootx()
        self.clock_windows._offsety = self.clock_windows.winfo_pointery() - self.clock_windows.winfo_rooty()

root = Tk()
clock = Clock(root)

root.mainloop()

