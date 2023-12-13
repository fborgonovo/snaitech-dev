# Send email with SMTP and TLS - Python 3.3 or above

import smtplib

#from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

FROM = "furio.borgonovo@gmail.com"
TO = ["furio.borgonovo@snaitech.it"] #! must be a list

SUBJECT = "Comunicazione voucher per acquisto certificato di Firma Remota"

BODY = """Gentile Cliente,\r\n\r\n \
al fine ottimizzare il processo di comunicazione siamo lieti di annunciarti che SNAITECH ti mette a disposizione gratuitamente un certificato di Firma\r\n \
Remota valido per 3 anni con il quale potrai firmare tutte le pratiche che ti invieremo durante la durata del nostro rapporto.\r\n\r\n \
Il codice del voucher per l’acquisto del certificato è: <STAG>VOUCHER<ETAG>\r\n\r\n \
Se sei in possesso di identità digitale (SPID) puoi utilizzare il voucher per acquistare il certificato da questo link:\r\n\r\n \
https://ecommerce.infocert.it/web/portale/workflow?prodotto=pr_cop_contr&idArticolo=FD-FIRMAREMOTA-SPID&currentStep=inizio&backto=firma/firma-digitale&operazione=A\r\n\r\n \
Se non sei in possesso di identità digitale (SPID) puoi utilizzare il voucher per acquistare il certificato da questo link:\r\n\r\n \
https://ecommerce.infocert.it/web/portale/workflow?prodotto=pr_cop_contr&idArticolo=FD-FIRMAREMOTA-COP&currentStep=inizio&backto=firma/firma-digitale&operazione=A\r\n\r\n \
Ad acquisto effettuato potrai procedere con l’attivazione del certificato seguendo le indicazioni che ti verranno richieste.\r\n\r\n \
IMPORTANTE!\r\n \
Al termine del processo di attivazione ti chiediamo di rispondere a questa mail inviandoci le seguenti informazioni:\r\n\r\n \
•	Casella di posta con la quale è stata effettuata l’attivazione del certificato di firma\r\n \
•	Nominativo dell’intestatario del certificato di firma\r\n \
•	Partita IVA\r\n\r\n \
Certi di porter contare sulla tua collaborazione ti auguriamo buona giornata\r\n\r\n \
Cordiali Saluti\r\n
"""

# Prepare actual message
#message = MIMEMultipart()
message = MIMEText(BODY)
message['From'] = FROM
message['To'] = ', '.join(TO)
message['Subject'] = SUBJECT

# The body and the attachments for the mail
#message.attach(MIMEText(TEXT, 'plain'))

# Create SMTP session for sending the mail
session = smtplib.SMTP('smtp.gmail.com', 587) # use gmail with port
session.starttls() # enable security
session.login(FROM, r"""ufxhbewzovrccopm""") # Login with mail_id and password
#text = message.as_string()
session.sendmail(FROM, TO, message.as_string())
session.quit()

# with smtplib.SMTP('smtp.gmail.com', 587) as server:
#     server.set_debuglevel(1)  # for debug, unnecessary
#     server.starttls()
#     server.login('example@example.com', r"""zxRVQaf-=,G5Nb.JP'J"E""")
#     server.sendmail(FROM, TO, message)
