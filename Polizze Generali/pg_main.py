import pandas as pd

from datetime import datetime, timedelta

import pg_constants as c
import pg_logs as log
import pg_db as db

def check_record(piva, denominazione, telefono, email, pec):
  status = False

  status = True
  return status

def build_dossier(contact, contact_nr):
  status = False

  status = True
  return status

print('Reading data from: ' + c.CONTACTS_FN)

data = pd.read_excel(c.CONTACTS_FN, sheet_name='Imprese_File clean', header=1, dtype='object')
df = pd.DataFrame(data, columns= ['_PIVA', 'Denominazione', 'Telefono', 'Email', 'PEC'])
pg_logger = log.pg_get_logger(__name__)

start_dt = datetime.now()
st = start_dt.strftime("%y/%m/%d %H:%M:%S")

pg_logger.debug(f"\n\n*** STARTING POLIZZE GENERALI ***\n{st: ^30}\n")

pg_logger.debug("Connecting to ' + PG_DB_FN' + '. Creating if it does not exist")
#* pg_db_con = db.pg_connect_db(c.APPEND) # Append to DB
pg_db_con = db.pg_connect_db(c.TRUNCATE) # New DB

pg_logger.debug("Processing recipients...")

for contact_nr in df.index:
  # Get record
  pg_logger.info('Processing record: {}'.format({contact_nr}))
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
