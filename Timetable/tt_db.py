import tt_constants as c
import sqlite3 as sl
import tt_logs as logs

from urllib.request import pathname2url

tt_db_logger = logs.tt_get_logger(__name__)

def tt_truncate_table(tt_db_con, table):
  tt_db_logger.debug('tt_truncate_table - BEGIN')

  sql = f"DELETE FROM {table};"

  tt_db_logger.debug(f"\n{sql}")

  with tt_db_con:
    try:
      tt_db_con.execute(sql)
      tt_db_con.commit()
    except Exception as err:
      tt_db_logger.error(f"\nTruncate failed:\n")
      tt_db_logger.error(f"\n{Exception} -> {err}")
      return c.STATUS_NOK

  tt_db_logger.debug('tt_truncate_table - END')

  return c.STATUS_NOK

def tt_create_table(tt_db_con, table, fields):
  tt_db_logger.debug('tt_create_table - BEGIN')

  # Drop the table if already exists.
  tt_db_cur = tt_db_con.cursor()

  tt_db_logger.debug(f"Dropping table {table} if exists")
  tt_db_cur.execute(f"DROP TABLE IF EXISTS {table}")

  tt_db_logger.info(f"\nCreating table: {table}\n            in: {c.TT_DB_FN}")
  
  sql = f"""CREATE TABLE {table} ({fields});"""
  tt_db_cur.execute(sql)

  tt_db_cur.close()

  tt_db_logger.debug('tt_create_table - END')

def tt_connect_db(opt=c.NORMAL, tt_db_fn = c.TT_DB_FN):
  tt_db_logger.debug('tt_connect_db - BEGIN')

  try:
    dburi = 'file:{}?mode=rw'.format(pathname2url(tt_db_fn))
    tt_db_con = sl.connect(dburi, uri=True)
    tt_db_logger.info("Connected to existing tt DB")
    if (opt == c.TRUNCATE):
      tt_db_logger.debug(f"{c.TT_DB_FN} Truncate table")
      tt_truncate_table(tt_db_con, c.PROCESSED_TBL)
      tt_truncate_table(tt_db_con, c.ANOMALIES_TBL)
    if (opt == c.DROP):
      tt_db_logger.debug(f"{c.TT_DB_FN} Dropping table")
      # PROCESSED table
      tt_create_table(tt_db_con, c.PROCESSED_TBL, c.PROCESSED_FIELDS)
      # ANOMALIES table
      tt_create_table(tt_db_con, c.ANOMALIES_TBL, c.ANOMALIES_FIELDS)
  except sl.OperationalError:
    # Create database if not present
    tt_db_logger.debug(f"{c.TT_DB_FN} not present. Creating")
    tt_db_con = sl.connect(tt_db_fn)
    # PROCESSED table
    tt_create_table(tt_db_con, c.PROCESSED_TBL, c.PROCESSED_FIELDS)
    # ANOMALIES table
    tt_create_table(tt_db_con, c.ANOMALIES_TBL, c.ANOMALIES_FIELDS)

  tt_db_logger.debug('tt_connect_db - END')

  return tt_db_con

def tt_insert_dbrow(tt_db_con, table, values):
    tt_db_logger.debug('tt_insert_dbrow - BEGIN')
    
    placeholders = ''.join('?,' for value in values)
    placeholders = placeholders[:-1]
    
    sql = f" INSERT INTO {table} VALUES({placeholders})"

    tt_db_logger.info('tt_insert_dbrow - Inserting row:\n{sql}')

    tt_cursor = tt_db_con.cursor()
    tt_cursor.execute(sql, values)
    tt_db_con.commit()

    tt_db_logger.debug('tt_insert_dbrow - END')

    return tt_cursor.lastrowid

def dd_query(tt_db_con, sql):
  tt_db_logger.debug(f"Querying mm DB: {sql}")

  with tt_db_con:
    data = tt_db_con.execute(sql)

    if (len(data) == 0):
      tt_db_logger.error(f"Record not found!/n{sql}")
      rc = c.RECORD_NOT_FOUND
    elif (len(data) == 1):
        tt_db_logger.debug(f"Record with partita IVA #{data[c.PIVA]} found")
        rc = c.RECORD_FOUND
    else:
      tt_db_logger.error(f"Multiple records found: #{len(data)}")
      rc = c.MULTIPLE_RECORDS_FOUND

  return rc, data
