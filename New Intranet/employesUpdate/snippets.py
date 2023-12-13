#!/usr/bin/python

class Parent:        # define parent class
   parentAttr = 100
   def __init__(self):
      print("Calling parent constructor")

   def parentMethod(self):
      print("Calling parent method")

   def setAttr(self, attr):
      Parent.parentAttr = attr

   def getAttr(self):
      print("Parent attribute :", Parent.parentAttr)

class Child(Parent): # define child class
   def __init__(self):
      print("Calling child constructor")

   def childMethod(self):
      print("Calling child method")

c = Child()          # instance of child
c.childMethod()      # child calls its method
c.parentMethod()     # calls parent's method
c.setAttr(200)       # again call parent's method
c.getAttr()          # again call parent's method

exit

"""
class employeeREST(object):
    def __init__(self,
            company
            sn
            givenName
            mail
            department
            description
            office
            jobTitle
            manager
            l
            streetAddress
            telephoneNumber
            mobile
            thumbnailphoto
            customAttribute6
            gruppoSPOwner
            gruppoSPReader
            mailDelResponsabile
            codAzienda
            codDipendente
            codBU
        ):
        self.company = company
        self.sn = sn
        self.givenName = givenName
        self.mail = mail
        self.department = department
        self.description = description
        self.office = office
        self.jobTitle = jobTitle
        self.manager = manager
        self.l = l
        self.streetAddress = streetAddress
        self.telephoneNumber = telephoneNumber
        self.mobile = mobile
        self.thumbnailphoto = thumbnailphoto
        self.customAttribute6 = customAttribute6
        self.gruppoSPOwner = gruppoSPOwner
        self.gruppoSPReader = gruppoSPReader
        self.mailDelResponsabile = mailDelResponsabile
        self.codAzienda = codAzienda
        self.codDipendente = codDipendente
        self.codBU = codBU

    def say_hello(self, name):
        print("Hello, {}!".format(name))

uri = "http://10.177.111.32:8080/Employee/getXMLForExcel?caller=intranet&firma=E2E38FDC09A1CAEF479F96E887D049DB&requestId=1"
response = requests.get(uri)

employee = employeeREST(response[0])

"""