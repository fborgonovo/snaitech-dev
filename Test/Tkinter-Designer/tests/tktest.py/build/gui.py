
# This file was generated by the Tkinter Designer by Parth Jadhav
# https://github.com/ParthJadhav/Tkinter-Designer


from pathlib import Path

from tkinter import *


OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path("./assets")


def relative_to_assets(path: str) -> Path:
    return ASSETS_PATH / Path(path)


window = Tk()

window.geometry("520x481")
window.configure(bg = "#FFFFFF")


canvas = Canvas(
    window,
    bg = "#FFFFFF",
    height = 481,
    width = 520,
    bd = 0,
    highlightthickness = 0,
    relief = "ridge"
)

canvas.place(x = 0, y = 0)
image_image_1 = PhotoImage(
    file=relative_to_assets("image_1.png"))
image_1 = canvas.create_image(
    725.0,
    558.0,
    image=image_image_1
)

entry_image_1 = PhotoImage(
    file=relative_to_assets("entry_1.png")
)
entry_bg_1 = canvas.create_image(
    143.97566604614258,
    154.14309692382812,
    image=entry_image_1
)
entry_1 = Text(
    bd=0,
    bg="#FFFFFF",
    highlightthickness=0
)
entry_1.place(
    x=113.0,
    y=145.0,
    width=61.951332092285156,
    height=16.28619384765625
)

entry_image_2 = PhotoImage(
    file=relative_to_assets("entry_2.png")
)
entry_bg_2 = canvas.create_image(
    143.97566604614258,
    188.14309692382812,
    image=entry_image_2
)
entry_2 = Text(
    bd=0,
    bg="#FFFFFF",
    highlightthickness=0
)
entry_2.place(
    x=113.0,
    y=179.0,
    width=61.951332092285156,
    height=16.28619384765625
)

entry_image_3 = PhotoImage(
    file=relative_to_assets("entry_3.png")
)
entry_bg_3 = canvas.create_image(
    143.97566604614258,
    222.14310455322266,
    image=entry_image_3
)
entry_3 = Text(
    bd=0,
    bg="#FFFFFF",
    highlightthickness=0
)
entry_3.place(
    x=113.0,
    y=213.0,
    width=61.951332092285156,
    height=16.286209106445312
)

entry_image_4 = PhotoImage(
    file=relative_to_assets("entry_4.png")
)
entry_bg_4 = canvas.create_image(
    263.5,
    81.0,
    image=entry_image_4
)
entry_4 = Text(
    bd=0,
    bg="#FFFFFF",
    highlightthickness=0
)
entry_4.place(
    x=175.0,
    y=67.0,
    width=177.0,
    height=26.0
)

button_image_1 = PhotoImage(
    file=relative_to_assets("button_1.png"))
button_1 = Button(
    image=button_image_1,
    borderwidth=0,
    highlightthickness=0,
    command=lambda: print("button_1 clicked"),
    relief="flat"
)
button_1.place(
    x=210.0,
    y=382.0,
    width=105.0,
    height=42.0
)

button_image_2 = PhotoImage(
    file=relative_to_assets("button_2.png"))
button_2 = Button(
    image=button_image_2,
    borderwidth=0,
    highlightthickness=0,
    command=lambda: print("button_2 clicked"),
    relief="flat"
)
button_2.place(
    x=329.0,
    y=266.0,
    width=76.0,
    height=43.0
)

button_image_3 = PhotoImage(
    file=relative_to_assets("button_3.png"))
button_3 = Button(
    image=button_image_3,
    borderwidth=0,
    highlightthickness=0,
    command=lambda: print("button_3 clicked"),
    relief="flat"
)
button_3.place(
    x=222.0,
    y=266.0,
    width=76.0,
    height=43.0
)

button_image_4 = PhotoImage(
    file=relative_to_assets("button_4.png"))
button_4 = Button(
    image=button_image_4,
    borderwidth=0,
    highlightthickness=0,
    command=lambda: print("button_4 clicked"),
    relief="flat"
)
button_4.place(
    x=56.0,
    y=266.0,
    width=135.0,
    height=43.0
)

entry_image_5 = PhotoImage(
    file=relative_to_assets("entry_5.png")
)
entry_bg_5 = canvas.create_image(
    298.0,
    222.0,
    image=entry_image_5
)
entry_5 = Entry(
    bd=0,
    bg="#D9D9D9",
    highlightthickness=0
)
entry_5.place(
    x=180.0,
    y=213.0,
    width=236.0,
    height=16.0
)

entry_image_6 = PhotoImage(
    file=relative_to_assets("entry_6.png")
)
entry_bg_6 = canvas.create_image(
    298.0,
    188.0,
    image=entry_image_6
)
entry_6 = Text(
    bd=0,
    bg="#71B8FA",
    highlightthickness=0
)
entry_6.place(
    x=180.0,
    y=179.0,
    width=236.0,
    height=16.0
)

entry_image_7 = PhotoImage(
    file=relative_to_assets("entry_7.png")
)
entry_bg_7 = canvas.create_image(
    298.0,
    154.0,
    image=entry_image_7
)
entry_7 = Text(
    bd=0,
    bg="#71B8FA",
    highlightthickness=0
)
entry_7.place(
    x=180.0,
    y=145.0,
    width=236.0,
    height=16.0
)

canvas.create_rectangle(
    115.0,
    94.42257690429688,
    416.00335693359375,
    95.0,
    fill="#000000",
    outline="")
window.resizable(False, False)
window.mainloop()