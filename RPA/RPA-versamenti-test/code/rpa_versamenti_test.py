""" Generazione record set per ambiente di test """

"""
    --------------------------------------------------------------------
    ---                   RPA versamenti test                        ---
    ---        Generazione record set per ambiente di test           ---
    --------------------------------------------------------------------

    Workflow:

        1) Read configuration file
        2) Initialize rules set
        3) Read the original records file
        4) For each record:
            a) Validate the record
            b) Choose the rule to apply
            c) Apply the rule to the current record
            d) Write the record to the modified records file

	Parameter(s):
        None

    Results:
        a) Modified records file ($(CONTI_TEST)-yyyymmdd.txt)
        b) Log file (RPA-versamenti-test-yyyymmdd.log)

	History:

        v0.1 :	Project start

__author__ = "Furio Angelo Borgonovo"
__copyright__ = ""
__date__ = "Dec 2021"
__credits__ = [""]
__license__ = ""
__version__ = "0.1"
__maintainer__ = "Furio Angelo Borgonovo"
__email__ = "furio.borgonovo@snaitech.it"
__status__ = "Prototype"

"""

import yaml
import sys

from collections import deque

_CONFIGURATION_FN = "F:/SNAITECH dev/Workspaces/RPA/RPA-versamenti-test/code/rpa_versamenti_test.yaml"
_EQUAL = '{:=>115}'
_DASH = '{:-<118}'

ini_dict = {}

def read_yaml(file_path):
    with open(file_path, "r") as f:
        return yaml.safe_load(f)

def pop_frontrows(q, limit=None):
    return [q.popleft() for _ in range(min(limit or sys.maxsize, len(q)))]

def pop_backrows(q, limit=None):
    return [q.pop() for _ in range(min(limit or sys.maxsize, len(q)))]

def split_row(row_no, cuts, line):
    fields = lambda string,split_at:[string[i:j] for i, j in zip([0]+split_at, split_at+[None])]
    f1, f2, f3, drop_trail = fields(line, cuts)
    print('{}{:02d} '.format('--- Row #', row_no)+_DASH.format(''))
    print('\033[1m'+line+'\033[0m')
    print('[{:<60}]'.format(f1.strip()))
    print('[{:<26}]'.format(f2.strip()))
    print('[{:<35}]'.format(f3.strip()))
    return f1, f2, f3

ini_dict = read_yaml(_CONFIGURATION_FN)

environment = ini_dict['APP']['ENVIRONMENT']
debug       = ini_dict['APP']['DEBUG']

data_path   = ini_dict['DATA']['DATA_PATH']
conti_prova = ini_dict['DATA']['CONTI_PROVA']
conti_reali = ini_dict['DATA']['CONTI_REALI']
conti_test  = ini_dict['DATA']['CONTI_TEST']

cuts = [[60,59+26,59+25+35],
        [40,39+41,39+40+41],
        [16,15+51,15+50+55],
        [13,12+39,23+39+70],
        [13,12+3,12+2+105],
        [13,12+40,0]]

fn = data_path+'/'+conti_reali

contents=None
with open(fn) as f:
    contents=deque(f)

pop_frontrows(contents, 33)
pop_backrows(contents, 5)

#contents = [line[1:].rstrip('\n') for line in open(fn)]
#del contents[:33]
#del contents[239:]

row_no = 1
record_no = 1
print('{}{:02d} '.format('=== Record #', record_no)+_EQUAL.format(''))

for line in contents:
    if (line.startswith("#") or line in ['\n', '\r\n'] or not line.strip()):  # Drop comments or empty lines
        continue
    split_row(row_no, cuts[row_no-1], line)
    row_no += 1
    if (row_no == 7):
        row_no = 1
        record_no += 1
        print('{}{:02d} '.format('=== Record #', record_no)+_EQUAL.format(''))

exit()

"""
==============================================================================================================
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
620000001002011221011221C000000000020,00480                 @60
MB0B30073452             @26
BONIF. VS. FAVORE                 @35
0,60:61,87:88,123
==============================================================================================================
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
630000001002YYY01122021                @40
VIROLI NICHOLAS                         @41
47034                                   @41

==============================================================================================================
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
630000001002YY2@16
VIA TOBIA ALDINI 6                                @51
IT16D0306967793100000004217                           @55

==============================================================================================================
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
630000001002@13
ID1                                   @39
NOTPROVIDED                                                          @70

==============================================================================================================
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
630000001002@13
RI1@3
ricarica conto gioco n 21286710 intestato a viroli nicholas                                             @105

==============================================================================================================
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
630000001002@13
CODICE ABI/CAB ORDINANTE: 03069/67793  @40
"""

