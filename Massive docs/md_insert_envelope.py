import md_logs as log

md_ie_logger = log.md_get_logger(__name__)

def md_insert_envelope():
  md_ie_logger.debug('mm_send_record - BEGIN')

  md_status = True

  md_ie_logger.debug('mm_send_record - END')

  return md_status