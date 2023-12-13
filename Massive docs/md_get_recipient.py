import pandas as pd

import md_logs as log

md_gr_logger = log.md_get_logger(__name__)

def write_record(piva, email, telefono):
  md_gr_logger.info('write_record: %s, %s', piva, email, telefono)

  return 0

def send_record(piva, email, telefono):
  md_gr_logger.info('send_record: %s, %s, %s', piva, email, telefono)

  return 0

def read_recipients():

  contacts_fn = ('F:/SNAITECH dev/Workspaces/Massive mail/data/contacts.xlsx')

  md_gr_logger.info('Reading data from: %s', contacts_fn)

  data = pd.read_excel(contacts_fn, sheet_name='Imprese_File clean', header=1, dtype='object')
  df = pd.DataFrame(data, columns= ['_PIVA', 'Denominazione', 'Telefono', 'Email', 'PEC'])

  for contact_nr in df.index:
    # Get record
    md_gr_logger.info('Processing record: %s', contact_nr)
    md_gr_logger.info('%s, %s, %s, %s, %s, %s', df['_PIVA'][contact_nr], df['Denominazione'][contact_nr], df['Telefono'][contact_nr], df['Email'][contact_nr], df['PEC'][contact_nr])

    # Check record
    if (df['PEC'][contact_nr]):
      email = df['Email'][contact_nr]
    else:
      email = df['PEC'][contact_nr]

    if (send_record(df['_PIVA'][contact_nr], email, df['Telefono'][contact_nr])):
    # OK: record sent
      write_record(df['_PIVA'][contact_nr], email, df['Telefono'][contact_nr])
      md_gr_logger.info("md_gr_logger md_read_recipients: [%s] %s", contact_nr, df)
    else:
    # NOK: Write record in the anomalies file, next
      md_gr_logger.warning("md_gr_logger md_read_recipients: [%s] %s", contact_nr, df)
