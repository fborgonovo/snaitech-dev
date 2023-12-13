from datetime import datetime

import pandas as pd
import xlsxwriter

import md_constants as c
import md_logs as log
import md_db as db
import md_insert_dossier as md_id

md_pr_logger = log.md_get_logger(__name__)

def md_check_email(_pec, _email):
  md_pr_logger.debug('md_check_email - BEGIN')

  _pec = _pec.translate({ord('-'): None}).strip().split(';', 1)[0]
  _email = _email.translate({ord('-'): None}).strip().split(';', 1)[0]

  if ("".__eq__(_pec) and not "".__eq__(_email)):
    md_pr_logger.debug(f'md_check_email: email found -> {_email}')
    email = _email
  elif (not "".__eq__(_pec) and "".__eq__(_email)):
    md_pr_logger.debug(f'md_check_email: pec found -> {_pec}')
    email = _pec
  elif (not "".__eq__(_pec) and not "".__eq__(_email)):
    md_pr_logger.debug(f'md_check_email: pec and email found. Choosing pec -> [{_email}] - [{_pec}]')
    email = _pec
  else:
    md_pr_logger.debug('md_check_email: no email nor pec found')
    email = ""

  md_pr_logger.debug('md_check_email - END')

  return email

def md_send_record(piva, denominazione, telefono, email):
  md_pr_logger.debug('md_send_record - BEGIN')

  md_pr_logger.debug(f'Sending record: {piva}, {denominazione}, {telefono}, {email}')

  md_sent_datetime = datetime.now()

  md_id.md_insert_dossier()

  md_pr_logger.debug('md_send_record - END')

  return md_sent_datetime

def md_process_record(md_db_con, email, values):
  md_pr_logger.debug(f'\n\nmd_process_record - BEGIN')

  sent_datetime = md_send_record(values[c.PIVA], values[c.DENOMINAZIONE], values[c.TELEFONO], email)

  if (sent_datetime != ''):
    md_pr_logger.debug(f"Record processed: {values[c.PIVA]}, {email}, {c.SEND_STATUS_OK}")
    db.md_insert_processed(md_db_con, values)
  else:
    md_pr_logger.warning(f"Record skipped: {values[c.PIVA]}, {email}, {c.SEND_STATUS_NOK}")
    db.md_insert_anomalies(md_db_con, values)

  if (c.DEBUG):
    sql = f"SELECT * FROM {c.PROCESSED} WHERE _PIVA == '{values[c.PIVA]}'"
    processed_record = db.md_query(md_db_con, sql)
    if (processed_record[1][c.PIVA] == ''):
      md_pr_logger.warning(f"Record not inserted: {values['_PIVA']}, {values['Email']}, {values['PEC']}, {c.SEND_STATUS_NOK}")
    else:
      md_pr_logger.debug(f"Record inserted: {processed_record[1][c.PIVA]}, {processed_record[1][c.EMAIL]}, {c.SEND_STATUS_OK}")

  md_pr_logger.debug(f'md_process_record - END\n')

  return True

def md_process_recipients(md_db_con):
  md_pr_logger.debug('md_process_recipients - BEGIN')

  if (c.DEBUG):
    contacts_fn = c.CONTDBG_FN
  else:
    contacts_fn = c.CONTACTS_FN

  md_pr_logger.debug(f'Reading records from: {contacts_fn}')
  md_pr_logger.debug('TAB: Imprese_File clean - COLS: ALL)')
  data = pd.read_excel(contacts_fn, sheet_name='Imprese_File clean', header=1, dtype='object')
  df = pd.DataFrame(data, columns= ['99', 'RAGIONE SOCIALE', '_PIVA', '_CF', 'SEDE', 'Posizione incrociata', 'Posizione Duplicata', \
                                    'Crif Number', 'Denominazione', 'Partita Iva', 'REA', 'CCIAA', 'Codice fiscale', 'Indirizzo', 'Cap', \
                                    'Comune', 'Frazione', 'Provincia', 'Regione', 'Stato Impresa Cribis', 'Natura giuridica', 'Tipo natura giuridica', \
                                    'dummy1', 'Cognome Esponente', 'Nome Esponente', 'Sesso', 'Data di nascita', 'Provincia di Nascita', 'Comune di Nascita', \
                                    'Nazione di Nascita', 'Cittadinanza', 'Indirizzo RL', 'CAP RL', 'Comune RL', 'Provincia RL', 'Frazione RL', 'Altre indicazioni', \
                                    'Nazione', 'Telefono', 'Email', 'PEC'])

  process_status = c.PROCESSING_RECIPIENTS_COMPLETE
  md_pr_processed = 0
  md_pr_anomalies = 0
  md_pr_send_fail = 0

  for contact_nr in df.index:
    md_pr_logger.debug(f"Processing record #{md_pr_processed}: {df['_PIVA'][contact_nr]}, {df['Denominazione'][contact_nr]}, {df['Telefono'][contact_nr]}, {df['Email'][contact_nr]}, {df['PEC'][contact_nr]}")

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

    last_row = db.md_insert_recipients(md_db_con, values)

    md_pr_logger.debug(f"Record #{md_pr_processed}/{last_row} successful inserted into RECIPIENTS table.")

    # Check record's emails
    email = md_check_email(df['PEC'][contact_nr], df['Email'][contact_nr])

    if ("".__eq__(email)):
      md_pr_logger.warning(f"Record #{md_pr_processed} with no email nor PEC: {contact_nr}, {df['_PIVA'][contact_nr]}, {df['Denominazione'][contact_nr]}, {df['Telefono'][contact_nr]}, {email}")
      process_status = c.PROCESSING_RECIPIENTS_PARTIAL
      md_pr_anomalies += 1
    else:
      if (md_process_record(md_db_con, email, values)):
        md_pr_logger.info(f"Record #{md_pr_processed}: {contact_nr}, {df['_PIVA'][contact_nr]}, {df['Denominazione'][contact_nr]}, {df['Telefono'][contact_nr]}, {email}")
        process_status = c.PROCESSING_RECIPIENTS_COMPLETE
        md_pr_processed += 1
      else:
        md_pr_logger.warning(f"Record #{md_pr_processed}: with no email nor PEC: #{contact_nr}: {df['_PIVA'][contact_nr]}, {df['Denominazione'][contact_nr]}, {df['Telefono'][contact_nr]}, {email}")
        process_status = c.PROCESSING_RECIPIENTS_SEND_FAIL
        md_pr_send_fail += 1

  md_pr_logger.debug('md_process_recipients - END')

  return process_status, md_pr_processed, md_pr_anomalies, md_pr_send_fail
