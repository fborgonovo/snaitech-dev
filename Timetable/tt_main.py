
#*** Timetable main

from datetime import datetime

import tt_constants as c
import tt_logs as logs
import tt_db as db

tt_logger = logs.tt_get_logger(__name__)

#! DEBUG START
# tt_logger.debug(msg="this is a debug message")
# tt_logger.info(msg="this is an info message")
# tt_logger.warning(msg="this is a warning message")
# tt_logger.error(msg="this is an error message")
# tt_logger.critical(msg="this is a critical message")
#! DEBUG END

#! INIT
processed = 0
anomalies = 0

start_dt = datetime.now()
st = start_dt.strftime("%y/%m/%d %H:%M:%S")

HEADER = "\n\n***  STARTING  TIMETABLE  ***\n"
print(f"{HEADER}" + f"{st}".center(len(HEADER) - 2) + "\n")

tt_logger.debug("Connecting to tt_db. Creating if it does not exist")
#* db_con = db.tt_connect_db() # Append to DB
db_con = db.tt_connect_db(c.TRUNCATE) # New DB

#! LOAD STUDENTS
tt_logger.info("Loading students...")


#! LOAD TEACHERS
tt_logger.info("Loading teachers...")


#! LOAD RULES
tt_logger.info("Loading rules...")


#! LOAD CONSTRAINTS
tt_logger.info("Loading constraints...")


#! LOAD EXCEPTIONS
tt_logger.info("Loading exceptions...")


#! BUILD TIMETABLE
tt_logger.info("Building timetable...")


#! SAVE TIMETABLE
tt_logger.info("Saving timetable...")


end_dt = datetime.now()
et = end_dt.strftime("%y/%m/%d %H:%M:%S")

elapsed = end_dt - start_dt

tt_logger.info(f"\n\n***  TIMETABLE  COMPLETE  ***\n\nStart time: {st}\nEnd time:   {et}\n"\
    f"Elapsed: {elapsed}\nProcessed: {processed} - Anomalies: {anomalies}\n")
