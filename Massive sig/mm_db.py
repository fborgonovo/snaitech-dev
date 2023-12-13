import sqlite3 as sl
import mm_logs as log

from urllib.request import pathname2url

import mm_constants as c

mm_db_logger = log.mm_get_logger(__name__)

def mm_truncate_table(mm_db_con, table):
  mm_db_logger.debug('mm_truncate_table - BEGIN')

  sql = f"DELETE FROM {table};"
  with mm_db_con:
    try:
      mm_db_con.execute(sql)
      mm_db_con.commit()
      mm_db_logger.debug(f"\n{table} table truncated:\n{sql}")
    except Exception as err:
      mm_db_logger.error(f"\nFailed to truncate {table} table:\n")
      mm_db_logger.warning(f"\n{Exception} -> {err}")

  mm_db_logger.debug('mm_truncate_table - END')

def mm_truncate_all(mm_db_con):
  mm_db_logger.debug('mm_truncate_all - BEGIN')

  mm_truncate_table(mm_db_con, c.RECIPIENTS)
  mm_truncate_table(mm_db_con, c.PROCESSED)
  mm_truncate_table(mm_db_con, c.ANOMALIES)

  mm_db_logger.debug('mm_truncate_all - END')

def mm_create_table(mm_db_con, table_name, table):
  mm_db_logger.debug('mm_create_table - BEGIN')

  # Drop the table if already exists.
  mm_db_cur1 = mm_db_con.cursor()

  mm_db_logger.debug(f"Dropping table {table_name} if exists")
  mm_db_cur1.execute(f"DROP TABLE IF EXISTS {table_name}")

  mm_db_logger.debug(f"Creating table in {c.MM_DB_FN}:\n\n{table}")

  mm_db_cur1.execute(table)

  mm_db_cur1.close()

  mm_db_logger.debug('mm_create_table - END')

def mm_connect_db(opt=c.APPEND, mm_db_fn = c.MM_DB_FN):
  mm_db_logger.debug('mm_connect_db - BEGIN')

  try:
    dburi = 'file:{}?mode=rw'.format(pathname2url(mm_db_fn))
    mm_db_con = sl.connect(dburi, uri=True)
    mm_db_logger.debug("Connected to existing mm DB")
    if (opt == c.TRUNCATE):
      mm_truncate_all(mm_db_con)
  except sl.OperationalError:
    # Create database if not present
    mm_db_logger.debug(f"{c.MM_DB_FN} not present. Creating")
    mm_db_con = sl.connect(mm_db_fn)

    # RECIPIENT table
    table = f"""CREATE TABLE {c.RECIPIENTS} (
                '99' TEXT,
                'RAGIONE SOCIALE' TEXT,
                '_PIVA' TEXT NOT NULL PRIMARY KEY,
                '_CF' TEXT,
                'SEDE' TEXT,
                'Posizione incrociata' TEXT,
                'Posizione Duplicata' TEXT,
                'Crif Number' TEXT,
                'Denominazione' TEXT,
                'Partita Iva' TEXT,
                'REA' TEXT,
                'CCIAA' TEXT,
                'Codice fiscale' TEXT,
                'Indirizzo societa' TEXT,
                'Cap societa' TEXT,
                'Comune societa' TEXT,
                'Frazione societa' TEXT,
                'Provincia societa' TEXT,
                'Regione' TEXT,
                'Stato Impresa Cribis' TEXT,
                'Natura giuridica' TEXT,
                'Tipo natura giuridica' TEXT,
                'dummy' TEXT,
                'Cognome Esponente' TEXT,
                'Nome Esponente' TEXT,
                'Sesso' TEXT,
                'Data di nascita' TEXT,
                'Provincia di Nascita' TEXT,
                'Comune di Nascita' TEXT,
                'Nazione di Nascita' TEXT,
                'Cittadinanza' TEXT,
                'Indirizzo RL' TEXT,
                'CAP RL' TEXT,
                'Comune RL' TEXT,
                'Provincia RL' TEXT,
                'Frazione RL' TEXT,
                'Altre indicazioni' TEXT,
                'Nazione' TEXT,
                'Telefono' TEXT,
                'Email' TEXT,
                'PEC' TEXT,
                'status' TEXT
              );
          """
    mm_create_table(mm_db_con, c.RECIPIENTS, table)

    # PROCESSED table
    table = f"""CREATE TABLE {c.PROCESSED} (
                'piva' TEXT NOT NULL PRIMARY KEY,
                'email' TEXT,
                'voucher' TEXT,
                'sent_date' TEXT,
                'activation_date' TEXT,
                'status' TEXT
                );
            """
    mm_create_table(mm_db_con, c.PROCESSED, table)

    # ANOMALIES table
    table = f"""CREATE TABLE {c.ANOMALIES} (
                'piva' TEXT NOT NULL PRIMARY KEY,
                'email' TEXT,
                'pec' TEXT,
                'voucher' TEXT,
                'sent_date' TEXT,
                'activation_date' TEXT,
                'status' TEXT
                );
            """
    mm_create_table(mm_db_con, c.ANOMALIES, table)

  mm_db_logger.debug('mm_connect_db - END')

  return mm_db_con

def mm_insert_recipients(mm_db_con, values):
  sql = ''' INSERT INTO recipients
            VALUES(?,?,?,?,?,
                   ?,?,?,?,?,
                   ?,?,?,?,?,
                   ?,?,?,?,?,
                   ?,?,?,?,?,
                   ?,?,?,?,?,
                   ?,?,?,?,?,
                   ?,?,?,?,?,
                   ?,?
                   )
        '''
  mm_cursor1 = mm_db_con.cursor()
  mm_cursor1.execute(sql, values)
  mm_db_con.commit()

  return mm_cursor1.lastrowid

def mm_insert_processed(mm_db_con, values):
  sql = ''' INSERT INTO processed
            VALUES(?,?,?,?,?,?)
        '''
  mm_cursor1 = mm_db_con.cursor()
  mm_cursor1.execute(sql, values)
  mm_db_con.commit()

  return mm_cursor1.lastrowid

def mm_insert_anomalies(mm_db_con, values):
  sql = ''' INSERT INTO anomalies
            VALUES(?,?,?,?,?,?,?)
        '''
  mm_cursor1 = mm_db_con.cursor()
  mm_cursor1.execute(sql, values)
  mm_db_con.commit()

  return mm_cursor1.lastrowid

def mm_query(mm_db_con, sql):
  mm_db_logger.debug(f"Querying mm DB: {sql}")

  with mm_db_con:
    data = mm_db_con.execute(sql)

    nrows = 0

    for row in data:
      (piva, email, voucher, sent_data, activation_data, status) = row
      nrows += 1

    if (nrows == 0):
      mm_db_logger.error(f"Record not found!/n{sql}")
      (piva, email, voucher, sent_data, activation_data, status) = '', '', '', '', '', ''
    elif (nrows == 1):
        mm_db_logger.debug(f"Record with piva #{piva} found")
    else:
      mm_db_logger.error(f"Multiple records found: #{nrows}")
      (piva, email, voucher, sent_data, activation_data, status) = '', '', '', '', '', ''

  return piva, email, voucher, sent_data, activation_data, status
