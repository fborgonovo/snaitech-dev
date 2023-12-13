# to make the executable:
#
# pyinstaller --onefile --icon="F:/SNAITECH dev/Workspaces/Clock/res/Oxygen-Icons.org-Oxygen-Apps-clock.ico" "clock OO.py"
#
# or:
#
# pyinstaller --onefile --noconsole --icon="F:/SNAITECH dev/Workspaces/Clock/res/Oxygen-Icons.org-Oxygen-Apps-clock.ico" "clock OO.py" (sophos mark the executables as PUA)

# Importing modules
from tkinter import Tk
from tkinter.ttk import Label
from time import strftime

# creating tkinter window
root = Tk()
root.iconbitmap('C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Clock/res/Oxygen-Icons.org-Oxygen-Apps-clock.ico')
root.title('Clock')

# This function is used to display time on the label
#    string = strftime('%H:%M:%S %p') AM/PM
def time():
    string = strftime(' %H:%M:%S ')
    lbl.config(text = string)
    lbl.after(1000, time)

# Styling the label widget so that clock will look more attractive
lbl = Label(root, font = ('calibri', 40, 'bold'),
            background = 'purple',
            foreground = 'white')

# Placing clock at the centre of the tkinter window
lbl.pack(anchor = 'center')
time()

root.mainloop()
