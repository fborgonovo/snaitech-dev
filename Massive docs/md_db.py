import sqlite3 as sl
import md_logs as log

from urllib.request import pathname2url

import md_constants as c

md_db_logger = log.md_get_logger(__name__)

def md_truncate_table(md_db_con, table):
  md_db_logger.debug('md_truncate_table - BEGIN')

  sql = f"DELETE FROM {table};"
  with md_db_con:
    try:
      md_db_con.execute(sql)
      md_db_con.commit()
      md_db_logger.info(f"\n{table} table truncated:\n{sql}")
    except Exception as err:
      md_db_logger.error(f"\nFailed to truncate {table} table:\n")
      md_db_logger.error(f"\n{Exception} -> {err}")

  md_db_logger.debug('md_truncate_table - END')

def md_truncate_all(md_db_con):
  md_db_logger.debug('md_truncate_all - BEGIN')

  md_truncate_table(md_db_con, c.RECIPIENTS)
  md_truncate_table(md_db_con, c.PROCESSED)
  md_truncate_table(md_db_con, c.ANOMALIES)

  md_db_logger.debug('md_truncate_all - END')

def md_create_table(md_db_con, table_name, table):
  md_db_logger.debug('md_create_table - BEGIN')

  # Drop the table if already exists.
  md_db_cur1 = md_db_con.cursor()

  md_db_logger.info(f"Dropping table {table_name} if exists")
  md_db_cur1.execute(f"DROP TABLE IF EXISTS {table_name}")

  md_db_logger.info(f"Creating table in {c.MD_DB_FN}:\n\n{table}")

  md_db_cur1.execute(table)

  md_db_cur1.close()

  md_db_logger.debug('md_create_table - END')

def md_connect_db(opt=c.APPEND, md_db_fn = c.MD_DB_FN):
  md_db_logger.debug('md_connect_db - BEGIN')

  try:
    dburi = 'file:{}?mode=rw'.format(pathname2url(md_db_fn))
    md_db_con = sl.connect(dburi, uri=True)

    md_db_logger.info("Connected to an existing md DB")
    if (opt == c.TRUNCATE):
      md_db_logger.info("Truncate all tables in md DB")
      md_truncate_all(md_db_con)
  except sl.OperationalError:
    # Create database if not present
    md_db_logger.info(f"{c.MD_DB_FN} not present. Creating")
    md_db_con = sl.connect(md_db_fn)

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
    md_create_table(md_db_con, c.RECIPIENTS, table)

    # PROCESSED table
    table = f"""CREATE TABLE {c.PROCESSED} (
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
    md_create_table(md_db_con, c.PROCESSED, table)

    # ANOMALIES table
    table = f"""CREATE TABLE {c.ANOMALIES} (
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
    md_create_table(md_db_con, c.ANOMALIES, table)

  md_db_logger.debug('md_connect_db - END')

  return md_db_con

def md_insert_recipients(md_db_con, values):
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
  md_cursor1 = md_db_con.cursor()
  md_cursor1.execute(sql, values)
  md_db_con.commit()

  return md_cursor1.lastrowid

def md_insert_processed(md_db_con, values):
  sql = ''' INSERT INTO processed
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
  md_cursor1 = md_db_con.cursor()
  md_cursor1.execute(sql, values)
  md_db_con.commit()

  return md_cursor1.lastrowid

def md_insert_anomalies(md_db_con, values):
  sql = ''' INSERT INTO anomalies
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
  md_cursor1 = md_db_con.cursor()
  md_cursor1.execute(sql, values)
  md_db_con.commit()

  return md_cursor1.lastrowid

def md_query(md_db_con, sql):
  md_db_logger.debug(f"Querying mm DB: {sql}")

  with md_db_con:
    global row, _piva

    data = md_db_con.execute(sql)

    nrows = 0

    for row in data:
      (a99, ragione_sociale, _piva, _cf, sede, posizione_incrociata, posizione_duplicata, crif_number, denominazione, partita_iva,
       rea, cciaa, codice_fiscale, indirizzo_societa, cap_societa, comune_societa, frazione_societa, provincia_societa, regione,
       stato_impresa_cribis, natura_giuridica, tipo_natura_giuridica, dummy, cognome_esponente, nome_esponente, sesso, data_di_nascita,
       provincia_di_nascita, comune_di_nascita, nazione_di_nascita, cittadinanza, indirizzo_rl, cap_rl, comune_rl, provincia_rl,
       frazione_rl, altre_indicazioni, nazione, telefono, email, pec, status) = row
      nrows += 1

    if (nrows == 0):
      md_db_logger.error(f"Record not found!/n{sql}")
      rc = c.RECORD_NOT_FOUND
    elif (nrows == 1):
        md_db_logger.debug(f"Record with partita IVA #{_piva} found")
        rc = c.RECORD_FOUND
    else:
      md_db_logger.error(f"Multiple records found: #{nrows}")
      rc = c.MULTIPLE_RECORDS_FOUND

  return rc, row
