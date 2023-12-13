from datetime import datetime

import md_constants as c
import md_logs as log
import md_db as db
import md_process_recipients as md_pr

md_logger = log.md_get_logger(__name__)

# md_logger.debug(msg="this is a debug message")
# md_logger.info(msg="this is an info message")
# md_logger.warning(msg="this is a warning message")
# md_logger.error(msg="this is an error message")
# md_logger.critical(msg="this is a critical message")

start_dt = datetime.now()
st = start_dt.strftime("%y/%m/%d %H:%M:%S")

log_header = f"\n\n*** STARTING MASSIVE DOCS ***\n{st: ^30}\n"

md_logger.info(log_header)

#* md_logger.debug("Connecting to md_db. Creating if it does not exist")
#* md_db_con = db.md_connect_db(c.APPEND) # Append to DB

md_logger.info("Creating md_db")
md_db_con = db.md_connect_db(c.TRUNCATE)

md_logger.info("Processing recipients...")

(process_status, processed, anomalies, fails) = md_pr.md_process_recipients(md_db_con)

if (process_status == c.PROCESSING_RECIPIENTS_COMPLETE):
    md_logger.info(f"Task complete, #{processed} recipients processed.", processed)
elif (process_status == c.PROCESSING_RECIPIENTS_PARTIAL):
    md_logger.warning("Task complete, #{processed} recipients processed, #{anomalies} anomalies.")
elif (process_status == c.PROCESSING_RECIPIENTS_SEND_FAIL):
    md_logger.error("Task complete, #{processed} recipients processed, #{anomalies} anomalies, #{fails} send failed.")
else:
    md_logger.warning("Task complete but processing status unknown, #{processed} recipients processed, #{anomalies} anomalies, #{fails} send failed.")

end_dt = datetime.now()
et = end_dt.strftime("%y/%m/%d %H:%M:%S")

elapsed = end_dt - start_dt

md_logger.info(f"\n\n*** MASSIVE MAIL COMPLETE ***\n{et: ^30}\nProcessed: {processed} - Anomalies: {anomalies}\nElapsed: {elapsed}\n")