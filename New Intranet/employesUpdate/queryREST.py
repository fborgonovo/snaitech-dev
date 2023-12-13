import requests
import xml.etree.ElementTree as ET

"""
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

codAzienda
codDipendente
id_reparto
id_squadra
id_divisione
id_mansione
codBU
codAzResp
codDipResp
id_avatar
data_assunzione
data_nascita
inquadramento
"""

"""
class ca6(object):
    def loadCA6(self, packedCA6):


    def codAzienda(self):
    def codDipendente(self):
    def id_reparto(self):
    def id_squadra(self):
    def id_divisione(self):
    def id_mansione(self):
    def codBU(self):
    def codAzResp(self):
    def codDipResp(self):
    def id_avatar(self):
    def data_assunzione(self):
    def data_nascita(self):
    def inquadramento(self):

class employesREST(object):
    def loadFromHTML(self, uri):
        return requests.get(uri)

    def loadFromFile(self, fileName):
        method = getattr(self, method_name, lambda: "Invalid file name")

    def company(self):
    def sn(self):
    def givenName(self):
    def mail(self):
    def department(self):
    def description(self):
    def office(self):
    def jobTitle(self):
    def manager(self):
    def l(self):
    def streetAddress(self):
    def telephoneNumber(self):
    def mobile(self):
    def thumbnailphoto(self):
    def customAttribute6(self):
    def gruppoSPOwner(self):
    def gruppoSPReader(self):
    def mailDelResponsabile(self):
    def codAzienda(self):
    def codDipendente(self):
    def codBU(self):
"""

uri = "http://10.177.111.32:8080/Employee/getXMLForExcel?caller=intranet&firma=E2E38FDC09A1CAEF479F96E887D049DB&requestId=1"
response = requests.get(uri)
print(response.status_code)

treeRoot = ET.fromstring(response.content)

child = treeRoot[1]

for child in treeRoot.iter('*'):

    print(child.tag, child.text)

dummy = 1