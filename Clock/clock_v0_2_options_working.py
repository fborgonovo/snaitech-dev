import tkinter


class ClockOptions(object):

    root = None

    def __init__(self, msg, dict_key=None):
        """
        msg = <str> the message to be displayed
        dict_key = <sequence> (dictionary, key) to associate with user input
        (providing a sequence for dict_key creates an entry for user input)
        """
        tki = tkinter
        self.top = tki.Toplevel(ClockOptions.root)

        frm = tki.Frame(self.top, borderwidth=4, relief="ridge")
        frm.pack(fill="both", expand=True)

        label = tki.Label(frm, text=msg)
        label.pack(padx=4, pady=4)

        caller_wants_an_entry = dict_key is not None

        if caller_wants_an_entry:
            self.entry = tki.Entry(frm)
            self.entry.pack(pady=4)

            b_submit = tki.Button(frm, text="Submit")
            b_submit["command"] = lambda: self.entry2dict(dict_key)
            b_submit.pack()

        b_cancel = tki.Button(frm, text="Cancel")
        b_cancel["command"] = self.top.destroy
        b_cancel.pack(padx=4, pady=4)

    def entry2dict(self, dict_key):
        data = self.entry.get()
        if data:
            d, key = dict_key
            d[key] = data
            self.top.destroy()
