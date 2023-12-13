import sqlite3 as sl
import pg_logs as log

from urllib.request import pathname2url

import pg_constants as c

pg_db_logger = log.pg_get_logger(__name__)

def pg_truncate_table(pg_db_con, table):
  pg_db_logger.debug('pg_truncate_table - BEGIN')

  sql = f"DELETE FROM {table};"
  with pg_db_con:
    try:
      pg_db_con.execute(sql)
      pg_db_con.commit()
      pg_db_logger.debug(f"\n{table} table truncated:\n{sql}")
    except Exception as err:
      pg_db_logger.error(f"\nFailed to truncate {table} table:\n")
      pg_db_logger.warning(f"\n{Exception} -> {err}")

  pg_db_logger.debug('pg_truncate_table - END')

def pg_truncate_all(pg_db_con):
  pg_db_logger.debug('pg_truncate_all - BEGIN')

  pg_truncate_table(pg_db_con, c.RECIPIENTS)
  pg_truncate_table(pg_db_con, c.PROCESSED)
  pg_truncate_table(pg_db_con, c.ANOMALIES)

  pg_db_logger.debug('pg_truncate_all - END')

def pg_create_table(pg_db_con, table_name, table):
  pg_db_logger.debug('pg_create_table - BEGIN')

  # Drop the table if already exists.
  pg_db_cur1 = pg_db_con.cursor()

  pg_db_logger.debug(f"Dropping table {table_name} if exists")
  pg_db_cur1.execute(f"DROP TABLE IF EXISTS {table_name}")

  pg_db_logger.debug(f"Creating table in {c.PG_DB_FN}:\n\n{table}")

  pg_db_cur1.execute(table)

  pg_db_cur1.close()

  pg_db_logger.debug('pg_create_table - END')

def pg_connect_db(opt=c.APPEND, pg_db_fn = c.PG_DB_FN):
  pg_db_logger.debug('pg_connect_db - BEGIN')

  try:
    dburi = 'file:{}?mode=rw'.format(pathname2url(pg_db_fn))
    pg_db_con = sl.connect(dburi, uri=True)
    pg_db_logger.debug("Connected to existing mm DB")
    if (opt == c.TRUNCATE):
      pg_truncate_all(pg_db_con)
  except sl.OperationalError:
    # Create database if not present
    pg_db_logger.debug(f"{c.pg_DB_FN} not present. Creating")
    pg_db_con = sl.connect(pg_db_fn)

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
    pg_create_table(pg_db_con, c.RECIPIENTS, table)

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
    pg_create_table(pg_db_con, c.PROCESSED, table)

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
    pg_create_table(pg_db_con, c.ANOMALIES, table)

  pg_db_logger.debug('pg_connect_db - END')

  return pg_db_con

def pg_insert_recipients(pg_db_con, values):
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
  pg_cursor1 = pg_db_con.cursor()
  pg_cursor1.execute(sql, values)
  pg_db_con.commit()

  return pg_cursor1.lastrowid

def pg_insert_processed(pg_db_con, values):
  sql = ''' INSERT INTO processed
            VALUES(?,?,?,?,?,?)
        '''
  pg_cursor1 = pg_db_con.cursor()
  pg_cursor1.execute(sql, values)
  pg_db_con.commit()

  return pg_cursor1.lastrowid

def pg_insert_anomalies(pg_db_con, values):
  sql = ''' INSERT INTO anomalies
            VALUES(?,?,?,?,?,?,?)
        '''
  pg_cursor1 = pg_db_con.cursor()
  pg_cursor1.execute(sql, values)
  pg_db_con.commit()

  return pg_cursor1.lastrowid

def pg_query(pg_db_con, sql):
  pg_db_logger.debug(f"Querying mm DB: {sql}")

  with pg_db_con:
    data = pg_db_con.execute(sql)

    nrows = 0

    for row in data:
      (piva, email, voucher, sent_data, activation_data, status) = row
      nrows += 1

    if (nrows == 0):
      pg_db_logger.error(f"Record not found!/n{sql}")
      (piva, email, voucher, sent_data, activation_data, status) = '', '', '', '', '', ''
    elif (nrows == 1):
        pg_db_logger.debug(f"Record with piva #{piva} found")
    else:
      pg_db_logger.error(f"Multiple records found: #{nrows}")
      (piva, email, voucher, sent_data, activation_data, status) = '', '', '', '', '', ''

  return piva, email, voucher, sent_data, activation_data, status
