import pandas as pd

import mm_logs as log

mm_gr_logger = log.mm_get_logger(__name__)

def write_record(voucher, piva, email, telefono):
  mm_gr_logger.info('write_record: %s, %s, %s', voucher, piva, email, telefono)

  return 0

def send_record(piva, email, telefono):
  mm_gr_logger.info('send_record: %s, %s, %s', piva, email, telefono)

  return 0

def read_recipients():

  contacts_fn = ('F:/SNAITECH dev/Workspaces/Massive mail/data/contacts.xlsx')

  mm_gr_logger.info('Reading data from: %s', contacts_fn)

  data = pd.read_excel(contacts_fn, sheet_name='Imprese_File clean', header=1, dtype='object')
  df = pd.DataFrame(data, columns= ['_PIVA', 'Denominazione', 'Telefono', 'Email', 'PEC'])

  vouchers = pd.read_excel(contacts_fn, sheet_name='Imprese_File clean', header=1, dtype='object')
  dfv = pd.DataFrame(vouchers, columns= ['voucher'])

  for contact_nr in df.index:
    # Get record
    mm_gr_logger.info('Processing record: %s', contact_nr)
    mm_gr_logger.info('%s, %s, %s, %s, %s, %s', df['_PIVA'][contact_nr], df['Denominazione'][contact_nr], df['Telefono'][contact_nr], df['Email'][contact_nr], df['PEC'][contact_nr], dfv['voucher'][contact_nr])

    # Check record
    if (df['PEC'][contact_nr]):
      email = df['Email'][contact_nr]
    else:
      email = df['PEC'][contact_nr]

    if (send_record(df['_PIVA'][contact_nr], email, dfv['voucher'][contact_nr])):
    # OK: voucher sent
      write_record(dfv['voucher'][contact_nr], df['_PIVA'][contact_nr], email, df['Telefono'][contact_nr])
      mm_gr_logger.info("mm_gr_logger mm_read_recipients: [%s] %s", contact_nr, df)
    else:
    # NOK: Write record in the anomalies file, next
      mm_gr_logger.warning("mm_gr_logger mm_read_recipients: [%s] %s", contact_nr, df)

    # Next
