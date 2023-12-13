import configparser as cfg

import tt_constants as c
import tt_logs as logs
import tt_db as db

db_con = db.tt_connect_db(c.DROP, c.TT_TEST_DB_FN) # New DB

def load_table_data(table):
    table_vals = cfg.ConfigParser()
    table_vals.read(table)
    return table_vals[c.ANOMALIES_DATA]

anomalies_data = load_table_data(c.TT_ANOMALIES_TBL_FN)

anomalies_value = []

for anomalies_field in anomalies_data:
    anomalies_value.append(anomalies_data.get(anomalies_field))

print (anomalies_value)

rc = db.tt_insert_dbrow(db_con, c.ANOMALIES_TBL, anomalies_value)
print(rc)