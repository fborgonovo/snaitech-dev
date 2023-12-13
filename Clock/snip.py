#
# Add banner
#
import tkinter as tk

class MyDialog:
    def __init__(self, parent):
        top = self.top = tk.Toplevel(parent)
        self.my_label = tk.Label(top, text='Enter your username below')
        self.my_label.pack()

        self.my_entry_box = tk.Entry(top)
        self.my_entry_box.pack()

        self.my_submit_button = tk.Button(top, text='Submit', command=self.send)
        self.my_submit_button.pack()

    def send(self):
        global username
        username = self.my_entry_box.get()
        self.top.destroy()

def on_click():
    input_dialog = MyDialog(root)
    root.wait_window(input_dialog.top)
    print('Username: ', username)

username = 'Empty'

root = tk.Tk()

main_label = tk.Label(root, text='Example for pop up input box')
main_label.pack()

main_button = tk.Button(root, text='Click me', command=on_click)
main_button.pack()


root.mainloop()

''' Prova 1
# Import module
import tkinter
import tkinter.font

# Creating the GUI window.
root = tkinter.Tk()
root.title("Welcome to GeekForGeeks")
root.geometry("918x450")

# Creating our text widget.
sample_text=tkinter.Text(root, height = 10)
sample_text.pack()

# Create an object of type Font from tkinter.
Desired_font = tkinter.font.Font(family = "Advanced Pixel LCD-7",
                                 size = 40,
                                 weight = "bold")

# Parsed the Font object
# to the Text widget using .configure( ) method.
sample_text.configure(font = Desired_font)
root.mainloop()
'''

''' Pomodoro

import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import pygame
import time
import os

class Pomodoro:
	def __init__(self, root):
		self.root = root

	def work_break(self, timer):

		# common block to display minutes
		# and seconds on GUI
		minutes, seconds = divmod(timer, 60)
		self.min.set(f"{minutes:02d}")
		self.sec.set(f"{seconds:02d}")
		self.root.update()
		time.sleep(1)

	def work(self):
		timer = 25*60
		while timer >= 0:
			pomo.work_break(timer)
			if timer == 0:

				# once work is done play
				# a sound and switch for break
				dirname = os.path.dirname(__file__)
				sound_fn = os.path.join(dirname, 'res\\sound.ogg')
				pygame.mixer.music.init()
				pygame.mixer.music.load(sound_fn)
				pygame.mixer.music.play()
				messagebox.showinfo(
					"Good Job", "Take A Break, \
					nClick Break Button")
			timer -= 1

	def break_(self):
#		timer = 5*60
		timer = 1*10
		while timer >= 0:
			pomo.work_break(timer)
			if timer == 0:

				# once break is done,
				# switch back to work
				dirname = os.path.dirname(__file__)
				sound_fn = os.path.join(dirname, 'res\\sound.ogg')
				pygame.mixer.music.init()
				pygame.mixer.music.load(sound_fn)
				pygame.mixer.music.play()
				messagebox.showinfo(
					"Times Up", "Get Back To Work, \
					nClick Work Button")
			timer -= 1

	def main(self):

		# GUI window configuration
		self.root.geometry("450x455")
		self.root.resizable(False, False)
		self.root.title("Pomodoro Timer")

		# label
		self.min = tk.StringVar(self.root)
		self.min.set("25")
		self.sec = tk.StringVar(self.root)
		self.sec.set("00")

		self.min_label = tk.Label(self.root,
								textvariable=self.min, font=(
			"arial", 22, "bold"), bg="red", fg='black')
		self.min_label.pack()

		self.sec_label = tk.Label(self.root,
								textvariable=self.sec, font=(
			"arial", 22, "bold"), bg="black", fg='white')
		self.sec_label.pack()

		# add background image for GUI using Canvas widget
		canvas = tk.Canvas(self.root)
		canvas.pack(expand=True, fill="both")
		dirname = os.path.dirname(__file__)
		pomodoro_fn = os.path.join(dirname, 'res/pomodoro.png')
		img = Image.open(pomodoro_fn)
		bg = ImageTk.PhotoImage(img)
		canvas.create_image(90, 10, image=bg, anchor="nw")

		# create three buttons with countdown function command
		btn_work = tk.Button(self.root, text="Start",
							bd=5, command=self.work,
							bg="red", font=(
			"arial", 15, "bold")).place(x=140, y=380)
		btn_break = tk.Button(self.root, text="Break",
							bd=5, command=self.break_,
							bg="red", font=(
			"arial", 15, "bold")).place(x=240, y=380)

		self.root.mainloop()


if __name__ == '__main__':
	pomo = Pomodoro(tk.Tk())
	pomo.main()
'''