
#! Common

#DEBUG      =  1     # 1: DEBUG ON - 0: DEBUG OFF
#DBG_LEVEL  = 10
#*DBG_LEVEL  = "INFO"
DBG_LEVEL  = "DEBUG"
#*DBG_LEVEL  = "WARNING"
#*DBG_LEVEL  = "ERROR"
#*DBG_LEVEL  = "CRITICAL"

NORMAL     = 0
TRUNCATE   = 1
DROP       = 2

STATUS_OK  =  0
STATUS_NOK = -1

#! Paths

TT_LOGS_FN          = 'C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/logs/tt_logs.log'
TT_DB_FN            = 'C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/data/tt_db.db'
TT_TEST_DB_FN       = 'C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/data/tt_test_db.db'
TT_ANOMALIES_TBL_FN = 'C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/config/tt_anomalies_tbl_data.ini'

#! DB

PROCESSED_TBL = 'PROCESSED'
ANOMALIES_TBL = 'ANOMALIES'

PROCESSED_DATA = 'PROCESSED_DATA'
ANOMALIES_DATA = 'ANOMALIES_DATA'

RECORD_FOUND            =  0
RECORD_NOT_FOUND        = -1
MULTIPLE_RECORDS_FOUND  = -2

PROCESSED_FIELDS = """
                'PF01' TEXT,
                'PF02' TEXT,
                'PF03' TEXT NOT NULL PRIMARY KEY,
                'PF04' TEXT,
                'PF05' TEXT,
                'PF06' TEXT,
                'PF07' TEXT,
                'PF08' TEXT,
                'PF09' TEXT,
                'PF10' TEXT
            """

ANOMALIES_FIELDS = """
                'AF01' TEXT,
                'AF02' TEXT,
                'AF03' TEXT NOT NULL PRIMARY KEY,
                'AF04' TEXT,
                'AF05' TEXT,
                'AF06' TEXT,
                'AF07' TEXT,
                'AF08' TEXT,
                'AF09' TEXT,
                'AF10' TEXT
            """