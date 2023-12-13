DEBUG = 1 # 1: DEBUG ON - 0: DEBUG OFF

OAUTH_URL          = "https://webapp.gosign.digital/gosign/oauth/token"
INSERT_DOSSIER_URL = "https:// /dossiers"
INFOCERT_API       = "api.infocert.digital"
GOSIGN_DOSSIERS    = "/gosign/v5/dossiers"

PREFIX = "pg_"
ROOT = "C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Polizze Generali/"

OAUTH              = ROOT + 'data/' + PREFIX + 'oauth.json'
DOSSIER_TEMPLATE   = ROOT + 'data/' + PREFIX + 'dossier_template.json'
INSERT_ENVELOPE_1S = ROOT + 'data/' + PREFIX + 'insert_envelope_1s.json'
POST_DOSSIER       = ROOT + 'data/' + PREFIX + 'post_dossier.json'

APPEND   = 0
TRUNCATE = 1

SEND_STATUS_NOK = 1
SEND_STATUS_OK  = 0

PROCESSING_RECIPIENTS_COMPLETE  = 0
PROCESSING_RECIPIENTS_PARTIAL   = -1
PROCESSING_RECIPIENTS_SEND_FAIL = -2

CONTACTS_FN = ROOT + 'data/' + PREFIX + 'contacts work - partial.xlsx'
LOGS_FN     = ROOT + 'logs/' + PREFIX + '.log'
DB_FN    = ROOT + 'data/' + PREFIX + 'db.db'

RECIPIENTS = 'RECIPIENTS'
PROCESSED  = 'PROCESSED'
ANOMALIES  = 'ANOMALIES'

VOUCHER_RESERVED = 'RESERVED'
VOUCHER_SENDING  = 'SENDING'
VOUCHER_SENT     = 'SENT'
