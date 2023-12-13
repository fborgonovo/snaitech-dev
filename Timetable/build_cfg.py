from configparser import ConfigParser

# creating object of configparser
config = ConfigParser()

config["DEFAULT"] = {
    "DEBUG":         '1',     # 1: DEBUG ON - 0: DEBUG OFF
    "DBG_LEVEL":    '10',
    "NORMAL":        '0',
    "TRUNCATE":      '1',
    "DROP":          '2',
    "STATUS_OK":     '0',
    "STATUS_NOK":   '-1'
}

config["PATHS"] = {
    "TT_LOGS_FN":           'C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/logs/tt_logs.log',
    "TT_DB_FN":             'C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/data/tt_db.db',
    "TT_TEST_DB_FN":        'C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/data/tt_test_db.db',
    "TT_ANOMALIES_TBL_FN":  'C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/config/tt_anomalies_tbl_data.ini'
}

config["DB"] = {
    "PROCESSED_DATA":           'PROCESSED_DATA',
    "ANOMALIES_DATA":           'ANOMALIES_DATA',
    "RECORD_FOUND":              '0',
    "RECORD_NOT_FOUND":         '-1',
    "MULTIPLE_RECORDS_FOUND":   '-2'
}

config["PROCESSED_TBL"] = {
    'TABLE_NAME':                "PROCESSED",
    'R01':                       "TEXT",
    'R02':                       "TEXT",
    'R03':                       "TEXT NOT NULL PRIMARY KEY",
    'R04':                       "TEXT",
    'R05':                       "TEXT",
    'R06':                       "TEXT",
    'R07':                       "TEXT",
    'R08':                       "TEXT",
    'R09':                       "TEXT",
    'R10':                       "TEXT"
}

config["ANOMALIES_TBL"] = {
    'TABLE_NAME':                "ANOMALIES",
    'R01':                       "TEXT",
    'R02':                       "TEXT",
    'R03':                       "TEXT NOT NULL PRIMARY KEY",
    'R04':                       "TEXT",
    'R05':                       "TEXT",
    'R06':                       "TEXT",
    'R07':                       "TEXT",
    'R08':                       "TEXT",
    'R09':                       "TEXT",
    'R10':                       "TEXT"
}

with open("C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/config/tt_config.ini", 'w') as tt_config:
    config.write(tt_config)