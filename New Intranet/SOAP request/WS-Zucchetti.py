"""
* Comment
Highlights
 TODOs 
! Alerts
? Queries
// Removed
"""

import requests
from requests.exceptions import HTTPError
import gzip

url = "https://saas.hrzucchetti.it:443/hrpsnaitech-test/servlet/SQLDataProviderServer/a_gv_retry_date"

#headers = {"content-type" : "application/soap+xml"}
headers = {
	'User-agent'  : 'Apache-HttpClient/4.5.5 (Java/12.0.1)',
	'Content-type': 'application/soap+xml'
}

body = """
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:a="http://a_gv_retry_date.ws.localhost/">
<soapenv:Header/>
<soapenv:Body>
	<a:a_gv_retry_date_TabularQuery>
		<a:m_UserName>usr_ws_date</a:m_UserName>
		<a:m_Password>Snaitech01!</a:m_Password>
		<a:m_Company>000001</a:m_Company>
		<a:pIDCOMPANY>000028</a:pIDCOMPANY>
		<a:pIDEMPLOY>0001246</a:pIDEMPLOY>
	</a:a_gv_retry_date_TabularQuery>
</soapenv:Body>
</soapenv:Envelope>
"""

try:
	response = requests.post(url, data = body, headers = headers)
	response.raise_for_status()
except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
	print(f'Other error occurred: {err}')
else:
	print('Success!\n')
	deflatedContent = gzip.GzipFile(fileobj=response)
	print(f'deflatedContent:\n\t{deflatedContent}')
	print(f'status_code:\n\t{response.status_code}')
	print(f'headers\n\t{response.headers}')
	print(f'json:\n\t{response.json}')
	print(f'raw:\n\t{response.raw}')
	print(f'text:\n\t{response.text}')
	print(f'content:\n\t{response.content}')
