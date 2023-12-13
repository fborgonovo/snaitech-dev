
import tkinter as tk
#import random
import time
import datetime

root = tk.Tk()

# window's size
root.geometry("900x600")

# window's title
root.title("Message Encryption and Decryption")

Tops = tk.Frame(root, width = 800, relief = tk.SUNKEN)
Tops.pack(side = tk.TOP)

f1 = tk.Frame(root, width = 300, height = 200, relief = tk.SUNKEN)
f1.pack(side = tk.LEFT)

localtime = time.asctime(time.localtime(time.time()))

lblInfo = tk.Label(Tops, font = ('helvetica', 50, 'bold'),
                         text = "Vigenère cipher",
                         fg = "Black", bd = 10, anchor='w')
lblInfo.grid(row = 0, column = 0)

lblInfo = tk.Label(Tops, font=('arial', 20, 'bold'),
                         text = localtime,
                         fg = "Steel Blue",
                         bd = 10, anchor = 'w')
lblInfo.grid(row = 1, column = 0)

Msg = tk.StringVar()
key = tk.StringVar()
rb_mode = tk.IntVar()
Result = tk.StringVar()
mode_enc = 0

def quick_exit():
    root.destroy()

def full_reset():
    Msg.set("")
    Msg.set
    key.set("")
    rb_mode.set(0)
    Result.set("")
    txtMsg.focus_set()

def mode_sel():
    mode = rb_mode.get()

    if (mode == mode_enc):
        sel_mode = "Encode"
    else:
        sel_mode = "Decode"

lblMsg = tk.Label(f1, font = ('arial', 16, 'bold'),
                      text = "MESSAGE", bd = 16, anchor = "w")
lblMsg.grid(row = 2, column = 0)

txtMsg = tk.Entry(f1, font = ('arial', 16, 'bold'),
                      textvariable = Msg, bd = 10, insertwidth = 4,
                      bg = "powder blue", justify = 'left')
txtMsg.grid(row = 2, column = 1)
txtMsg.focus_set()

lblkey = tk.Label(f1, font = ('arial', 16, 'bold'),
                      text = "KEY", bd = 16, anchor = "w")
lblkey.grid(row = 3, column = 0)

txtkey = tk.Entry(f1, font = ('arial', 16, 'bold'),
                      textvariable = key, bd = 10, insertwidth = 4,
                      bg = "powder blue", justify = 'left')
txtkey.grid(row = 3, column = 1)

lblResult = tk.Label(f1, font = ('arial', 16, 'bold'),
                         text = "The Result-", bd = 16, anchor = "w")
lblResult.grid(row = 3, column = 2)

txtResult = tk.Entry(f1, font = ('arial', 16, 'bold'),
                         textvariable = Result, bd = 10, insertwidth = 4, state='readonly',
                         justify = 'left')
txtResult.grid(row = 3, column = 4)

# ----------------------------------------------------------------------------
lblmode = tk.Label(f1, font = ('arial', 16, 'bold'),
                       text = "MODE ",
                       bd = 16, anchor = "w")
lblmode.grid(row = 4, column = 0)

rb_mode_enc = tk.Radiobutton(f1, font = ('arial', 16, 'bold'),
                                 text='Encode',
                                 variable=rb_mode, value=0,
                                 command=mode_sel)
rb_mode_enc.grid(row = 4, column = 1)

rb_mode_dec = tk.Radiobutton(f1, font = ('arial', 16, 'bold'),
                                 text='Decode',
                                 variable=rb_mode, value=1,
                                 command=mode_sel)
rb_mode_dec.grid(row = 4, column = 2)
# ----------------------------------------------------------------------------

# Vigenère cipher
import base64

def encode(key, clear):
    enc = []

    for i in range(len(clear)):
        key_c = key[i % len(key)]
        enc_c = chr((ord(clear[i]) +
                     ord(key_c)) % 256)

        enc.append(enc_c)

    return base64.urlsafe_b64encode("".join(enc).encode()).decode()

def decode(key, enc):
    dec = []

    enc = base64.urlsafe_b64decode(enc).decode()
    for i in range(len(enc)):
        key_c = key[i % len(key)]
        dec_c = chr((256 + ord(enc[i]) -
                           ord(key_c)) % 256)

        dec.append(dec_c)
    return "".join(dec)


def message():
    print("Message= ", (Msg.get()))

    clear = Msg.get()
    k = key.get()

    if (rb_mode.get() == mode_enc):
        Result.set(encode(k, clear))
    else:
        Result.set(decode(k, clear))        

# Show message button
btnTotal = tk.Button(f1, padx = 16, pady = 8, bd = 16, fg = "black",
                         font = ('arial', 16, 'bold'), width = 10,
                         text = "Execute", bg = "powder blue",
                         command = message)
btnTotal.grid(row = 6, column = 1)

# Reset button
btnReset = tk.Button(f1, padx = 16, pady = 8, bd = 16,
                         fg = "black", font = ('arial', 16, 'bold'),
                         width = 10, text = "Reset", bg = "green",
                         command = full_reset)
btnReset.grid(row = 6, column = 2)

# Exit button
btnExit = tk.Button(f1, padx = 16, pady = 8, bd = 16,
                        fg = "black", font = ('arial', 16, 'bold'),
                        width = 10, text = "Exit", bg = "red",
                        command = quick_exit)
btnExit.grid(row = 6, column = 4)

# keeps window alive
root.mainloop()