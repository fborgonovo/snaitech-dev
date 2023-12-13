import pandas as pd

def logger(severity, msg):

  return

def log_anomaly(contact, contact_nr):

  return

def check_record(piva, denominazione, telefono, email, pec):
  status = False

  status = True
  return status

def build_dossier(contact, contact_nr):
  status = False

  status = True
  return status

contacts_fn = ('F:/SNAITECH dev/Workspaces/Massive sig/data/contacts.xlsx')

print('Reading data from: {}'.format({contacts_fn}))

data = pd.read_excel(contacts_fn, sheet_name='Imprese_File clean', header=1, dtype='object')
df = pd.DataFrame(data, columns= ['_PIVA', 'Denominazione', 'Telefono', 'Email', 'PEC'])

for contact_nr in df.index:
  # Get record
  print('Processing record: {}'.format({contact_nr}))
  print('{}, {}, {}, {}, {}'.format({df['_PIVA'][contact_nr]}, {df['Denominazione'][contact_nr]}, \
                                    {df['Telefono'][contact_nr]}, {df['Email'][contact_nr]}, {df['PEC'][contact_nr]}))

  # Check record
  if (check_record(df['_PIVA'][contact_nr], df['Denominazione'][contact_nr], df['Telefono'][contact_nr], df['Email'][contact_nr], df['PEC'][contact_nr])):
  # OK: Build the dossier and send it
    dossier = build_dossier(df, contact_nr)
    if (dossier):
      logger('FATAL', 'Build dossier failed')
      log_anomaly(df, contact_nr)
  else:
  # NOK: Write record in the anomalies file, next
    log_anomaly(df, contact_nr)

  # Next
