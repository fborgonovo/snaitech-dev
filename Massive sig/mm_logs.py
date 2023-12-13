import logging
import coloredlogs
import sys

from logging.handlers import TimedRotatingFileHandler

import mm_constants as c

# FORMATTER = logging.Formatter("%(levelname)s <PID %(process)d:%(processName)s> %(name)s.%(funcName)s(): %(message)s")
#FORMATTER = logging.Formatter(fmt='%(asctime)s %(levelname)-8s %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
FORMATTER = logging.Formatter(fmt='%(asctime)s %(levelname)-8s <PID %(process)d:%(processName)s> %(name)s.%(funcName)s() %(pathname)s:%(lineno)d:\n\t%(message)s', datefmt='%Y-%m-%d %H:%M:%S')

def mm_get_console_handler():
   console_handler = logging.StreamHandler(sys.stdout)
   console_handler.setFormatter(FORMATTER)
   return console_handler

def mm_get_file_handler():
   file_handler = TimedRotatingFileHandler(c.LOGS_FN, when='midnight', delay=True)
   file_handler.setFormatter(FORMATTER)
   return file_handler

def mm_get_logger(logger_name):
   logger = logging.getLogger(logger_name)
   logger.setLevel(logging.DEBUG)
   logger.addHandler(mm_get_console_handler())
   logger.addHandler(mm_get_file_handler())
   logger.propagate = False
   coloredlogs.install(logger=logger, level=logging.DEBUG)
   return logger