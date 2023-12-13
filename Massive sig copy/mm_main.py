
from datetime import datetime, timedelta

import mm_constants as c
import mm_logs as log
import mm_db as db
import mm_process_recipients as mm_pr

mm_logger = log.mm_get_logger(__name__)

start_dt = datetime.now()
st = start_dt.strftime("%y/%m/%d %H:%M:%S")

mm_logger.debug(f"\n\n*** STARTING MASSIVE MAIL ***\n{st: ^30}\n")

mm_logger.debug("Connecting to mm_db. Creating if it does not exist")
#* mm_db_con = db.mm_connect_db(c.APPEND) # Append to DB
mm_db_con = db.mm_connect_db(c.TRUNCATE) # New DB

mm_logger.debug("Processing recipients...")

(process_status, processed, anomalies, fails) = mm_pr.mm_process_recipients(mm_db_con)

if (process_status == c.PROCESSING_RECIPIENTS_COMPLETE):
  mm_logger.debug(f"Task complete, #{processed} recipients processed.")
elif (process_status == c.PROCESSING_RECIPIENTS_PARTIAL):
    mm_logger.warning("Task complete, #{processed} recipients processed, #{anomalies} anomalies.")
elif (process_status == c.PROCESSING_RECIPIENTS_SEND_FAIL):
    mm_logger.warning("Task complete, #{processed} recipients processed, #{anomalies} anomalies, #{fails} send failed.")
else:
    mm_logger.warning("Task complete but processing status unknown, #{processed} recipients processed, #{anomalies} anomalies, #{fails} send failed.")

end_dt = datetime.now()
et = end_dt.strftime("%y/%m/%d %H:%M:%S")

elapsed = end_dt - start_dt

mm_logger.debug(f"\n\n*** MASSIVE MAIL COMPLETE ***\n{et: ^30}\nProcessed: {processed} - Anomalies: {anomalies}\nElapsed: {elapsed}\n")