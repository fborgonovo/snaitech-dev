
#from pickle import FALSE, TRUE

import mm_logs as log

mm_ie_logger = log.mm_get_logger(__name__)

def mm_insert_envelope():
  mm_ie_logger.debug('mm_send_record - BEGIN')

  mm_status = True

  mm_ie_logger.debug('mm_send_record - END')

  return mm_status