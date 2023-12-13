import json
import http.client
from turtle import title

from requests_oauthlib import OAuth2Session

import md_constants as c
import md_logs as log

md_id_logger = log.md_get_logger(__name__)

def md_get_payload():
  with open(c.OAUTH, "r", encoding='utf-8') as md_oauth:
    md_authorization = json.load(md_oauth)

#! DEBUG
  md_auth                           = md_authorization['auth']
  md_auth_type                      = md_auth['type']
  md_oauth2                         = md_auth['oauth2']
  md_oauth2_k01_token_name          = md_oauth2[0]['key']
  md_oauth2_k01_value               = md_oauth2[0]['value']
  md_oauth2_k01_type                = md_oauth2[0]['type']
  md_oauth2_k02_token_type          = md_oauth2[1]['key']
  md_oauth2_k02_value               = md_oauth2[1]['value']
  md_oauth2_k02_type                = md_oauth2[1]['type']
  md_oauth2_k03_access_token        = md_oauth2[2]['key']
  md_oauth2_k03_value               = md_oauth2[2]['value']
  md_oauth2_k03_type                = md_oauth2[2]['type']
  md_oauth2_k04_access_token_url    = md_oauth2[3]['key']
  md_oauth2_k04_value               = md_oauth2[3]['value']
  md_oauth2_k04_type                = md_oauth2[3]['type']
  md_oauth2_k05_password            = md_oauth2[4]['key']
  md_oauth2_k05_value               = md_oauth2[4]['value']
  md_oauth2_k05_type                = md_oauth2[4]['type']
  md_oauth2_k06_username            = md_oauth2[5]['key']
  md_oauth2_k06_value               = md_oauth2[5]['value']
  md_oauth2_k06_type                = md_oauth2[5]['type']
  md_oauth2_k07_client_secret       = md_oauth2[6]['key']
  md_oauth2_k07_value               = md_oauth2[6]['value']
  md_oauth2_k07_type                = md_oauth2[6]['type']
  md_oauth2_k08_client_id           = md_oauth2[7]['key']
  md_oauth2_k08_value               = md_oauth2[7]['value']
  md_oauth2_k08_type                = md_oauth2[7]['type']
  md_oauth2_k09_grant_type          = md_oauth2[7]['key']
  md_oauth2_k09_value               = md_oauth2[7]['value']
  md_oauth2_k09_type                = md_oauth2[7]['type']
  md_oauth2_k10_client_authentication      = md_oauth2[7]['key']
  md_oauth2_k10_value               = md_oauth2[7]['value']
  md_oauth2_k10_type                = md_oauth2[7]['type']
  md_oauth2_k11_add_token_to        = md_oauth2[7]['key']
  md_oauth2_k11_value               = md_oauth2[7]['value']
  md_oauth2_k11_type                = md_oauth2[7]['type']
#!

  with open(c.INSERT_ENVELOPE_1S, "r", encoding='utf-8') as md_dossier_template:
    md_payload = json.load(md_dossier_template)

#! DEBUG
  md_envelope                   = md_payload['envelope']
  md_use_type                   = md_envelope['useType']
  md_external_id                = md_envelope['externalId']
  md_subject                    = md_envelope['subject']
  md_sys_gnerator               = md_envelope['sysGenerator']
  md_sending_mode               = md_envelope['sendingMode']
  md_trust_level                = md_envelope['trustLevel']
  md_starred                    = md_envelope['starred']
  md_expiration_first_reminder  = md_envelope['expirationFirstReminder']
  md_expire_at                  = md_envelope['expireAt']
  md_conf_string                = md_envelope['confString']
  md_join_documents             = md_envelope['joinDocuments']
  md_documents                  = md_envelope['documents']
  md_external_id                = md_documents[0]['externalId']
  md_title                      = md_documents[0]['title']
  md_mime_type                  = md_documents[0]['mimeType']
  md_uri                        = md_documents[0]['uri']
  md_bytes                      = md_documents[0]['bytes']
  md_doc_class                  = md_envelope['docClass']
  md_common_messages            = md_envelope['commonMessages']
  md_text                       = md_common_messages['text']
  md_user_messages              = md_common_messages['userMessages']
  md_proc_def                   = md_envelope['procDef']
  md_tasks                      = md_proc_def['tasks']
  md_task_type                  = md_tasks[0]['type']
  md_task_conf_string           = md_tasks[0]['confString']
  md_task_order                 = md_tasks[0]['order']
  md_task_actor_expr            = md_tasks[0]['actorExpr']
  md_task_action                = md_tasks[0]['action']
  md_task_how_many              = md_tasks[0]['howMany']
  md_task_action_defs           = md_tasks[0]['actionDefs']
  md_task_ad_doc_external_id    = md_task_action_defs[0]['docExternalId']
  md_task_ad_type               = md_task_action_defs[0]['type']
  md_task_ad_mandatory          = md_task_action_defs[0]['mandatory']
  md_task_ad_conf_string        = md_task_action_defs[0]['confString']
  md_task_ad_appearance         = md_task_action_defs[0]['appearance']
  md_task_ad_app_invisible      = md_task_ad_appearance['invisible']
  md_task_ad_app_annotation_content = md_task_ad_appearance['annotationContent']
  md_task_ad_app_ta             = md_task_ad_appearance['tagAppearance']
  md_task_ad_app_ta_corner_type = md_task_ad_app_ta['cornerType']
  md_task_ad_app_ta_start_tag_pattern = md_task_ad_app_ta['startTagPattern']
  md_task_ad_app_ta_xoffset     = md_task_ad_app_ta['xoffset']
  md_task_ad_app_ta_yoffset     = md_task_ad_app_ta['yoffset']
  md_tasks_new_users            = md_proc_def['newUsers']
  md_tasks_nu_username          = md_tasks_new_users[0]['username']
  md_tasks_nu_name              = md_tasks_new_users[0]['name']
  md_tasks_nu_surname           = md_tasks_new_users[0]['surname']
  md_tasks_nu_phone_number      = md_tasks_new_users[0]['phoneNumber']
  md_tasks_nu_email             = md_tasks_new_users[0]['email']
  md_tasks_nu_email_language    = md_tasks_new_users[0]['emailLanguage']
  md_tasks_nu_timezone          = md_tasks_new_users[0]['timezone']
  md_tasks_nu_country_code      = md_tasks_new_users[0]['countryCode']
  md_tasks_nu_serial_type       = md_tasks_new_users[0]['serialType']
  md_tasks_nu_fiscal_code       = md_tasks_new_users[0]['fiscalCode']
  md_tasks_nu_external_id       = md_tasks_new_users[0]['externalId']
  md_tasks_nu_new_user_strategy = md_tasks_new_users[0]['newUserStrategy']
  md_tasks_nu_roles             = md_tasks_new_users[0]['roles']
  md_tasks_nu_role_1            = md_tasks_nu_roles[0]
  md_add_users_in_cc            = md_payload['addUsersInCC']
  md_add_ucc_external_id        = md_add_users_in_cc[0]['externalId']
  md_add_ucc_email              = md_add_users_in_cc[0]['email']
  md_add_ucc_surname            = md_add_users_in_cc[0]['surname']
  md_add_ucc_surname            = md_add_users_in_cc[0]['name']
  md_add_ucc_strategy           = md_add_users_in_cc[0]['addUsersInCCStrategy']
  md_response_with_envelope     = md_payload['responseWithEnvelope']
#!

  return md_authorization, md_payload

def get_access_token(md_password, md_username, md_client_secret, md_client_id):
  md_url = f"{c.OAUTH_URL}?grant_type=password&username={md_username}&password={md_password}&client_id={md_client_id}&client_secret={md_client_secret}"
  md_oauth_session = OAuth2Session(md_client_id, redirect_uri = md_url)
  md_token = md_oauth_session.fetch_token(md_url, client_secret = md_client_secret)

  return md_oauth_session, md_token

def md_insert_dossier():
  md_id_logger.debug('md_insert_dossier - BEGIN')

  md_status = False

  (md_authorization, md_payload) = md_get_payload()

  md_headers = {
    'accept': "text/plain",
    'content-type': "application/json"
    }

  md_password      = md_authorization['auth']['oauth2'][4]['key']
  md_username      = md_authorization['auth']['oauth2'][5]['key']
  md_client_secret = md_authorization['auth']['oauth2'][6]['key']
  md_client_id     = md_authorization['auth']['oauth2'][7]['key']

  if ( c.DEBUG ):
    md_status = 200
    md_id_logger.debug(    f"Dossier inserted: {md_payload['envelope']['subject']}")
    for i in range(len(md_payload['envelope']['documents'])):
      md_id_logger.debug(  f"                  {md_payload['envelope']['documents'][i]['title']}")
    for i in range(len(md_payload['envelope']['procDef']['tasks'])):
      md_id_logger.debug(  f"                  {md_payload['envelope']['procDef']['tasks'][i]['actorExpr']}")
      for j in range(len(md_payload['envelope']['procDef']['tasks'][i]['actionDefs'])):
        md_id_logger.debug(f"                  {md_payload['envelope']['procDef']['tasks'][i]['actionDefs'][j]['docExternalId']}")
        md_id_logger.debug(f"                  {md_payload['envelope']['procDef']['tasks'][i]['actionDefs'][j]['type']}")
  else:
    (oauth_session, md_token) = get_access_token(md_password, md_username, md_client_secret, md_client_id)
    md_response = oauth_session.post(c.INSERT_DOSSIER_URL, data=json.dumps(md_payload), headers=md_headers)
    if (md_response.status_code == 200):
      md_id_logger.debug(f"Dossier inserted: {md_payload['envelope']['subject']}")
      for i in md_payload['envelope']['documents']:
        md_id_logger.debug(f"                  {md_payload['envelope']['documents'][i][title]}")
      md_status = True
    elif (md_response.status_code == 400):
      md_id_logger.warning(f"{md_response.status_code} - Malformed parameters or bad request")
    elif (md_response.status_code == 401):
      md_id_logger.warning(f"{md_response.status_code} - Access token not valid")
    elif (md_response.status_code == 422):
      md_id_logger.warning(f"{md_response.status_code} - One or more request field are wrong or illegal")
    else:
      md_id_logger.warning(f"{md_response.status_code} - An unexpected server error has occurred")

  md_id_logger.debug('md_insert_dossier - END')

  return md_status