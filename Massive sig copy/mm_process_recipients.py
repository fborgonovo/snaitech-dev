from datetime import datetime

import pandas as pd
import xlsxwriter

import mm_constants as c
import mm_logs as log
import mm_db as db
import mm_insert_dossier as mm_id

mm_pr_logger = log.mm_get_logger(__name__)

def mm_check_email(_pec, _email):
  mm_pr_logger.debug('mm_check_email - BEGIN')

  _pec = _pec.translate({ord('-'): None}).strip().split(';', 1)[0]
  _email = _email.translate({ord('-'): None}).strip().split(';', 1)[0]

  if ("".__eq__(_pec) and not "".__eq__(_email)):
    mm_pr_logger.debug(f'mm_check_email: email found -> {_email}')
    email = _email
    pec = ""
  elif (not "".__eq__(_pec) and "".__eq__(_email)):
    mm_pr_logger.debug(f'mm_check_email: pec found -> {_pec}')
    email = ""
    pec = _pec
  elif (not "".__eq__(_pec) and not "".__eq__(_email)):
    mm_pr_logger.debug(f'mm_check_email: pec and email found. Choosing pec -> [{_email}] - [{_pec}]')
    email = ""
    pec = _pec
  else:
    mm_pr_logger.debug('mm_check_email: no email nor pec found')
    email = ""
    pec = ""

  mm_pr_logger.debug('mm_check_email - END')

  return email, pec

def mm_send_record(piva, denominazione, telefono, email, voucher):
  mm_pr_logger.debug('mm_send_record - BEGIN')

  mm_pr_logger.debug(f'Sending record: {piva}, {denominazione}, {telefono}, {email}, {voucher}')

  sent_datetime = datetime.now()

  mm_id.mm_insert_dossier()

  mm_pr_logger.debug('mm_send_record - END')

  return sent_datetime

def mm_process_record(mm_db_con, _piva, _denominazione, _telefono, _email, _pec, _voucher):
  mm_pr_logger.debug(f'\n\nmm_process_record - BEGIN')

  if ("".__eq__(_email)):
    email = _pec
  else:
    email = _email

  sent_datetime = mm_send_record(_piva, _denominazione, _telefono, email, _voucher)

  if (sent_datetime != ''):
    mm_pr_logger.debug(f"Record processed: {_piva}, {email}, {_voucher}, '', '', {c.SEND_STATUS_OK}")
    values = (_piva, email, _voucher, sent_datetime, '', c.SEND_STATUS_OK)
    db.mm_insert_processed(mm_db_con, values)
  else:
    mm_pr_logger.warning(f"Record skipped: {_piva}, {email}, {_voucher}, '', '', {c.SEND_STATUS_NOK}")
    values = (_piva, _email, _pec, _voucher, '', '', c.SEND_STATUS_NOK)
    db.mm_insert_anomalies(mm_db_con, values)

  if (c.DEBUG):
    sql = f"SELECT * FROM {c.PROCESSED} WHERE piva == '{_piva}'"
    (piva_, email_, voucher_, sent_data_, activation_data_, status_) = db.mm_query(mm_db_con, sql)
    if (piva_ == ''):
      mm_pr_logger.warning(f"Record not inserted: {_piva}, {_email}, {_pec}, {_voucher}, '', '', c.SEND_STATUS_NOK")
    else:
      mm_pr_logger.debug(f"Record inserted: {piva_}, {email_}, {voucher_}, {sent_data_}, {activation_data_}, {status_}")

  mm_pr_logger.debug(f'mm_process_record - END\n')

  return True

def mm_process_recipients(mm_db_con):
  mm_pr_logger.debug('mm_process_recipients - BEGIN')

  if (c.DEBUG):
    contacts_fn = c.CONTDBG_FN
    vouchers_fn = c.VOUCDBG_FN
  else:
    contacts_fn = c.CONTACTS_FN
    vouchers_fn = c.VOUCHERS_FN

  mm_pr_logger.debug(f'Reading records from: {contacts_fn}')
  mm_pr_logger.debug('TAB: Imprese_File clean - COLS: ALL)')
  data = pd.read_excel(contacts_fn, sheet_name='Imprese_File clean', header=1, dtype='object')
  df = pd.DataFrame(data, columns= ['99', 'RAGIONE SOCIALE', '_PIVA', '_CF', 'SEDE', 'Posizione incrociata', 'Posizione Duplicata', \
                                    'Crif Number', 'Denominazione', 'Partita Iva', 'REA', 'CCIAA', 'Codice fiscale', 'Indirizzo', 'Cap', \
                                    'Comune', 'Frazione', 'Provincia', 'Regione', 'Stato Impresa Cribis', 'Natura giuridica', 'Tipo natura giuridica', \
                                    'dummy1', 'Cognome Esponente', 'Nome Esponente', 'Sesso', 'Data di nascita', 'Provincia di Nascita', 'Comune di Nascita', \
                                    'Nazione di Nascita', 'Cittadinanza', 'Indirizzo RL', 'CAP RL', 'Comune RL', 'Provincia RL', 'Frazione RL', 'Altre indicazioni', \
                                    'Nazione', 'Telefono', 'Email', 'PEC'])

  mm_pr_logger.debug(f'Reading vouchers from: {vouchers_fn}')
  mm_pr_logger.debug('TAB: vouchers - COL: voucher)')
  vouchers = pd.read_excel(vouchers_fn, sheet_name='vouchers', header=0, dtype='object')
  dfv = pd.DataFrame(vouchers, columns= ['voucher', 'partita iva (account/codice sap)', 'rappresentante legale', 'pec', 'telefono', 'data invio', 'data attivazione', 'stato'])

  process_status = c.PROCESSING_RECIPIENTS_COMPLETE
  mm_pr_processed = 0
  mm_pr_anomalies = 0
  mm_pr_send_fail = 0
  nvoucher = ""

  for contact_nr in df.index:
    for voucher_nr in dfv.index:
      if (dfv['stato'][voucher_nr] == c.VOUCHER_RESERVED):
        dfv['stato'][voucher_nr] = c.VOUCHER_SENDING
        voucher = dfv['voucher'][voucher_nr]
        globals()[nvoucher] = voucher_nr
        break

    if (dfv['stato'][nvoucher] != c.VOUCHER_SENDING):
      mm_pr_logger.warning('record #{mm_pr_processed}: No more vouchers available')
      return c.PROCESSING_RECIPIENTS_PARTIAL, mm_pr_processed, mm_pr_anomalies, mm_pr_send_fail
    else:
      mm_pr_logger.debug(f"Processing record #{mm_pr_processed}: {df['_PIVA'][contact_nr]}, {df['Denominazione'][contact_nr]}, {df['Telefono'][contact_nr]}, {df['Email'][contact_nr]}, {df['PEC'][contact_nr]}, {voucher}")

    a = f"{df['99'][contact_nr]}"
    b = f"{df['RAGIONE SOCIALE'][contact_nr]}"
    c2 = f"{df['_PIVA'][contact_nr]}"
    d = f"{df['_CF'][contact_nr]}"
    e = f"{df['SEDE'][contact_nr]}"
    f = f"{df['Posizione incrociata'][contact_nr]}"
    g = f"{df['Posizione Duplicata'][contact_nr]}"
    h = f"{df['Crif Number'][contact_nr]}"
    i = f"{df['Denominazione'][contact_nr]}"
    j = f"{df['Partita Iva'][contact_nr]}"
    k = f"{df['REA'][contact_nr]}"
    l = f"{df['CCIAA'][contact_nr]}"
    m = f"{df['Codice fiscale'][contact_nr]}"
    n = f"{df['Indirizzo'][contact_nr]}"
    o = f"{df['Cap'][contact_nr]}"
    p = f"{df['Comune'][contact_nr]}"
    q = f"{df['Frazione'][contact_nr]}"
    r = f"{df['Provincia'][contact_nr]}"
    s = f"{df['Regione'][contact_nr]}"
    t = f"{df['Stato Impresa Cribis'][contact_nr]}"
    u = f"{df['Natura giuridica'][contact_nr]}"
    v = f"{df['Tipo natura giuridica'][contact_nr]}"
    w = f"{df['dummy1'][contact_nr]}"
    x = f"{df['Cognome Esponente'][contact_nr]}"
    y = f"{df['Nome Esponente'][contact_nr]}"
    z = f"{df['Sesso'][contact_nr]}"
    a1 = f"{df['Data di nascita'][contact_nr]}"
    b1 = f"{df['Provincia di Nascita'][contact_nr]}"
    c1 = f"{df['Comune di Nascita'][contact_nr]}"
    d1 = f"{df['Nazione di Nascita'][contact_nr]}"
    e1 = f"{df['Cittadinanza'][contact_nr]}"
    f1 = f"{df['Indirizzo RL'][contact_nr]}"
    g1 = f"{df['CAP RL'][contact_nr]}"
    h1 = f"{df['Comune RL'][contact_nr]}"
    i1 = f"{df['Provincia RL'][contact_nr]}"
    j1 = f"{df['Frazione RL'][contact_nr]}"
    k1 = f"{df['Altre indicazioni'][contact_nr]}"
    l1 = f"{df['Nazione'][contact_nr]}"
    m1 = f"{df['Telefono'][contact_nr]}"
    n1 = f"{df['Email'][contact_nr]}"
    o1 = f"{df['PEC'][contact_nr]}"

    values = (
        a, b, c2, d, e,     \
        f, g, h, i, j,      \
        k, l, m, n, o,      \
        p, q, r, s, t,      \
        u, v, w, x, y,      \
        z, a1, b1, c1, d1,  \
        e1, f1, g1, h1, i1, \
        j1, k1, l1, m1, n1, \
        o1, c.SEND_STATUS_NOK
    )

    last_row = db.mm_insert_recipients(mm_db_con, values)

    mm_pr_logger.debug(f"Record #{mm_pr_processed}/{last_row} successful inserted into RECIPIENTS table.")

    # Check record's emails
    (email, pec) = mm_check_email(df['PEC'][contact_nr], df['Email'][contact_nr])

    if ("".__eq__(email) and "".__eq__(pec)):
      mm_pr_logger.warning(f"Record #{mm_pr_processed} with no email nor PEC: {contact_nr}, {df['_PIVA'][contact_nr]}, {df['Denominazione'][contact_nr]}, {df['Telefono'][contact_nr]}, {email}, {pec}, {dfv['voucher'][contact_nr]}")
      process_status = c.PROCESSING_RECIPIENTS_PARTIAL
      dfv['stato'][nvoucher] = 'NOMAIL'
      mm_pr_anomalies += 1
    else:
      if (mm_process_record(mm_db_con, df['_PIVA'][contact_nr], df['Denominazione'][contact_nr], df['Telefono'][contact_nr], email, pec, dfv['voucher'][contact_nr])):
        mm_pr_logger.info(f"Record #{mm_pr_processed}: {contact_nr}, {df['_PIVA'][contact_nr]}, {df['Denominazione'][contact_nr]}, {df['Telefono'][contact_nr]}, {email}, {pec}, {dfv['voucher'][contact_nr]}")
        process_status = c.PROCESSING_RECIPIENTS_COMPLETE
        dfv['stato'][nvoucher] = 'SENT'
        mm_pr_processed += 1
      else:
        mm_pr_logger.warning(f"Record #{mm_pr_processed}: with no email nor PEC: #{contact_nr}: {df['_PIVA'][contact_nr]}, {df['Denominazione'][contact_nr]}, {df['Telefono'][contact_nr]}, {email}, {pec}, {dfv['voucher'][contact_nr]}")
        process_status = c.PROCESSING_RECIPIENTS_SEND_FAIL
        dfv['stato'][nvoucher] = 'SEND FAIL'
        mm_pr_send_fail += 1

  dfv.to_excel(vouchers_fn, sheet_name='vouchers', engine='xlsxwriter')

  mm_pr_logger.debug('mm_process_recipients - END')

  return process_status, mm_pr_processed, mm_pr_anomalies, mm_pr_send_fail
