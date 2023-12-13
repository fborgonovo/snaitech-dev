import sys
import logging
import coloredlogs

from logging.handlers import TimedRotatingFileHandler

import md_constants as c

CONSOLE_FORMATTER = logging.Formatter(fmt='%(asctime)s %(levelname)-8s <PID %(process)d:%(processName)s> %(name)s.%(funcName)s() %(pathname)s:%(lineno)d:\n\t%(message)s', datefmt='%Y-%m-%d %H:%M:%S')
FILE_FORMATTER = logging.Formatter(fmt='%(asctime)s %(levelname)-8s %(name)s.%(funcName)s() %(pathname)s:%(lineno)d:\n\t%(message)s', datefmt='%Y-%m-%d %H:%M:%S')

def md_get_console_handler():
   console_handler = logging.StreamHandler(sys.stdout)
   console_handler.setFormatter(CONSOLE_FORMATTER)
   return console_handler

def md_get_file_handler():
   file_handler = TimedRotatingFileHandler(c.LOGS_FN, when='midnight', delay=True)
   file_handler.setFormatter(FILE_FORMATTER)
   return file_handler

def md_get_logger(logger_name):
   logger = logging.getLogger(logger_name)
   logger.setLevel(c.DBG_LEVEL)
   logger.addHandler(md_get_console_handler())
   logger.addHandler(md_get_file_handler())
   logger.propagate = False
   coloredlogs.install(logger=logger, level=c.DBG_LEVEL)
   return logger