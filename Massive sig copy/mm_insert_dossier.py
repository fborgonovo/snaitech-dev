import json
import http.client
from turtle import title

from requests_oauthlib import OAuth2Session

import mm_constants as c
import mm_logs as log

mm_id_logger = log.mm_get_logger(__name__)

def mm_get_payload():
  with open(c.OAUTH, "r", encoding='utf-8') as mm_oauth:
    mm_authorization = json.load(mm_oauth)

#! DEBUG
  mm_auth                           = mm_authorization['auth']
  mm_auth_type                      = mm_auth['type']
  mm_oauth2                         = mm_auth['oauth2']
  mm_oauth2_k01_token_name          = mm_oauth2[0]['key']
  mm_oauth2_k01_value               = mm_oauth2[0]['value']
  mm_oauth2_k01_type                = mm_oauth2[0]['type']
  mm_oauth2_k02_token_type          = mm_oauth2[1]['key']
  mm_oauth2_k02_value               = mm_oauth2[1]['value']
  mm_oauth2_k02_type                = mm_oauth2[1]['type']
  mm_oauth2_k03_access_token        = mm_oauth2[2]['key']
  mm_oauth2_k03_value               = mm_oauth2[2]['value']
  mm_oauth2_k03_type                = mm_oauth2[2]['type']
  mm_oauth2_k04_access_token_url    = mm_oauth2[3]['key']
  mm_oauth2_k04_value               = mm_oauth2[3]['value']
  mm_oauth2_k04_type                = mm_oauth2[3]['type']
  mm_oauth2_k05_password            = mm_oauth2[4]['key']
  mm_oauth2_k05_value               = mm_oauth2[4]['value']
  mm_oauth2_k05_type                = mm_oauth2[4]['type']
  mm_oauth2_k06_username            = mm_oauth2[5]['key']
  mm_oauth2_k06_value               = mm_oauth2[5]['value']
  mm_oauth2_k06_type                = mm_oauth2[5]['type']
  mm_oauth2_k07_client_secret       = mm_oauth2[6]['key']
  mm_oauth2_k07_value               = mm_oauth2[6]['value']
  mm_oauth2_k07_type                = mm_oauth2[6]['type']
  mm_oauth2_k08_client_id           = mm_oauth2[7]['key']
  mm_oauth2_k08_value               = mm_oauth2[7]['value']
  mm_oauth2_k08_type                = mm_oauth2[7]['type']
  mm_oauth2_k09_grant_type          = mm_oauth2[7]['key']
  mm_oauth2_k09_value               = mm_oauth2[7]['value']
  mm_oauth2_k09_type                = mm_oauth2[7]['type']
  mm_oauth2_k10_client_authentication      = mm_oauth2[7]['key']
  mm_oauth2_k10_value               = mm_oauth2[7]['value']
  mm_oauth2_k10_type                = mm_oauth2[7]['type']
  mm_oauth2_k11_add_token_to        = mm_oauth2[7]['key']
  mm_oauth2_k11_value               = mm_oauth2[7]['value']
  mm_oauth2_k11_type                = mm_oauth2[7]['type']
#!

  with open(c.INSERT_ENVELOPE_1S, "r", encoding='utf-8') as mm_dossier_template:
    mm_payload = json.load(mm_dossier_template)

#! DEBUG
  mm_envelope                   = mm_payload['envelope']
  mm_use_type                   = mm_envelope['useType']
  mm_external_id                = mm_envelope['externalId']
  mm_subject                    = mm_envelope['subject']
  mm_sys_gnerator               = mm_envelope['sysGenerator']
  mm_sending_mode               = mm_envelope['sendingMode']
  mm_trust_level                = mm_envelope['trustLevel']
  mm_starred                    = mm_envelope['starred']
  mm_expiration_first_reminder  = mm_envelope['expirationFirstReminder']
  mm_expire_at                  = mm_envelope['expireAt']
  mm_conf_string                = mm_envelope['confString']
  mm_join_documents             = mm_envelope['joinDocuments']
  mm_documents                  = mm_envelope['documents']
  mm_external_id                = mm_documents[0]['externalId']
  mm_title                      = mm_documents[0]['title']
  mm_mime_type                  = mm_documents[0]['mimeType']
  mm_uri                        = mm_documents[0]['uri']
  mm_bytes                      = mm_documents[0]['bytes']
  mm_doc_class                  = mm_envelope['docClass']
  mm_common_messages            = mm_envelope['commonMessages']
  mm_text                       = mm_common_messages['text']
  mm_user_messages              = mm_common_messages['userMessages']
  mm_proc_def                   = mm_envelope['procDef']
  mm_tasks                      = mm_proc_def['tasks']
  mm_task_type                  = mm_tasks[0]['type']
  mm_task_conf_string           = mm_tasks[0]['confString']
  mm_task_order                 = mm_tasks[0]['order']
  mm_task_actor_expr            = mm_tasks[0]['actorExpr']
  mm_task_action                = mm_tasks[0]['action']
  mm_task_how_many              = mm_tasks[0]['howMany']
  mm_task_action_defs           = mm_tasks[0]['actionDefs']
  mm_task_ad_doc_external_id    = mm_task_action_defs[0]['docExternalId']
  mm_task_ad_type               = mm_task_action_defs[0]['type']
  mm_task_ad_mandatory          = mm_task_action_defs[0]['mandatory']
  mm_task_ad_conf_string        = mm_task_action_defs[0]['confString']
  mm_task_ad_appearance         = mm_task_action_defs[0]['appearance']
  mm_task_ad_app_invisible      = mm_task_ad_appearance['invisible']
  mm_task_ad_app_annotation_content = mm_task_ad_appearance['annotationContent']
  mm_task_ad_app_ta             = mm_task_ad_appearance['tagAppearance']
  mm_task_ad_app_ta_corner_type = mm_task_ad_app_ta['cornerType']
  mm_task_ad_app_ta_start_tag_pattern = mm_task_ad_app_ta['startTagPattern']
  mm_task_ad_app_ta_xoffset     = mm_task_ad_app_ta['xoffset']
  mm_task_ad_app_ta_yoffset     = mm_task_ad_app_ta['yoffset']
  mm_tasks_new_users            = mm_proc_def['newUsers']
  mm_tasks_nu_username          = mm_tasks_new_users[0]['username']
  mm_tasks_nu_name              = mm_tasks_new_users[0]['name']
  mm_tasks_nu_surname           = mm_tasks_new_users[0]['surname']
  mm_tasks_nu_phone_number      = mm_tasks_new_users[0]['phoneNumber']
  mm_tasks_nu_email             = mm_tasks_new_users[0]['email']
  mm_tasks_nu_email_language    = mm_tasks_new_users[0]['emailLanguage']
  mm_tasks_nu_timezone          = mm_tasks_new_users[0]['timezone']
  mm_tasks_nu_country_code      = mm_tasks_new_users[0]['countryCode']
  mm_tasks_nu_serial_type       = mm_tasks_new_users[0]['serialType']
  mm_tasks_nu_fiscal_code       = mm_tasks_new_users[0]['fiscalCode']
  mm_tasks_nu_external_id       = mm_tasks_new_users[0]['externalId']
  mm_tasks_nu_new_user_strategy = mm_tasks_new_users[0]['newUserStrategy']
  mm_tasks_nu_roles             = mm_tasks_new_users[0]['roles']
  mm_tasks_nu_role_1            = mm_tasks_nu_roles[0]
  mm_add_users_in_cc            = mm_payload['addUsersInCC']
  mm_add_ucc_external_id        = mm_add_users_in_cc[0]['externalId']
  mm_add_ucc_email              = mm_add_users_in_cc[0]['email']
  mm_add_ucc_surname            = mm_add_users_in_cc[0]['surname']
  mm_add_ucc_surname            = mm_add_users_in_cc[0]['name']
  mm_add_ucc_strategy           = mm_add_users_in_cc[0]['addUsersInCCStrategy']
  mm_response_with_envelope     = mm_payload['responseWithEnvelope']
#!

  return mm_authorization, mm_payload

def get_access_token(mm_password, mm_username, mm_client_secret, mm_client_id):
  mm_url = f"{c.OAUTH_URL}?grant_type=password&username={mm_username}&password={mm_password}&client_id={mm_client_id}&client_secret={mm_client_secret}"
  mm_oauth_session = OAuth2Session(mm_client_id, redirect_uri = mm_url)
  mm_token = mm_oauth_session.fetch_token(mm_url, client_secret = mm_client_secret)

  return mm_oauth_session, mm_token

def mm_insert_dossier():
  mm_id_logger.debug('mm_insert_dossier - BEGIN')

  mm_status = False

  (mm_authorization, mm_payload) = mm_get_payload()

  mm_headers = {
    'accept': "text/plain",
    'content-type': "application/json"
    }

  mm_password      = mm_authorization['auth']['oauth2'][4]['key']
  mm_username      = mm_authorization['auth']['oauth2'][5]['key']
  mm_client_secret = mm_authorization['auth']['oauth2'][6]['key']
  mm_client_id     = mm_authorization['auth']['oauth2'][7]['key']

  if ( c.DEBUG ):
    mm_status = 200
    mm_id_logger.debug(    f"Dossier inserted: {mm_payload['envelope']['subject']}")
    for i in range(len(mm_payload['envelope']['documents'])):
      mm_id_logger.debug(  f"                  {mm_payload['envelope']['documents'][i]['title']}")
    for i in range(len(mm_payload['envelope']['procDef']['tasks'])):
      mm_id_logger.debug(  f"                  {mm_payload['envelope']['procDef']['tasks'][i]['actorExpr']}")
      for j in range(len(mm_payload['envelope']['procDef']['tasks'][i]['actionDefs'])):
        mm_id_logger.debug(f"                  {mm_payload['envelope']['procDef']['tasks'][i]['actionDefs'][j]['docExternalId']}")
        mm_id_logger.debug(f"                  {mm_payload['envelope']['procDef']['tasks'][i]['actionDefs'][j]['type']}")
  else:
    (oauth_session, mm_token) = get_access_token(mm_password, mm_username, mm_client_secret, mm_client_id)
    mm_response = oauth_session.post(c.INSERT_DOSSIER_URL, data=json.dumps(mm_payload), headers=mm_headers)
    if (mm_response.status_code == 200):
      mm_id_logger.debug(f"Dossier inserted: {mm_payload['envelope']['subject']}")
      for i in mm_payload['envelope']['documents']:
        mm_id_logger.debug(f"                  {mm_payload['envelope']['documents'][i][title]}")
      mm_status = True
    elif (mm_response.status_code == 400):
      mm_id_logger.wanrning(f"{mm_response.status_code} - Malformed parameters or bad request")
    elif (mm_response.status_code == 401):
      mm_id_logger.warning(f"{mm_response.status_code} - Access token not valid")
    elif (mm_response.status_code == 422):
      mm_id_logger.warning(f"{mm_response.status_code} - One or more request field are wrong or illegal")
    else:
      mm_id_logger.warning(f"{mm_response.status_code} - An unexpected server error has occurred")

  mm_id_logger.debug('mm_insert_dossier - END')

  return mm_status