"""
    1xx Informational – Indicates that a request has been received and that the client should continue to make the requests for the data payload. You likely won’t need to worry about these status codes while working with Python Requests.
    2xx Successful – Indicates that a requested action has been received, understood, and accepted. You can use these codes to verify the existence of data before attempting to act on it.
    3xx Redirection – Indicates that the client must make an additional action to complete the request like accessing the resource via a proxy or a different endpoint. You may need to make additional requests, or modify your requests to deal with these codes.
    4xx Client Error – Indicates problems with the client, such as a lack of authorization, forbidden access, disallowed methods, or attempts to access nonexistent resources. This usually indicates configuration errors on the client application.
    5xx Server Error – Indicates problems with the server that provides the API. There are a large variety of server errors and they often require the API provider to resolve.
"""
 xml="""<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ones="https://wstest.gosign.lt/unisign/service/onesignservice.wsdl">
        <soapenv:Header/>
        <soapenv:Body>
            <ones:InitOneSignRequest xmlns="https://wstest.gosign.lt/unisign/service/onesignservice.wsdl">
         <ones:clientInfo>
            <!--clientId>TESTID</clientId-->
            <!--Optional:-->
            <signerPersonalCode>777777777</signerPersonalCode>
            <!--Optional:-->
            <locale>lt</locale>
            <responseUrl>http://some_url</responseUrl>
            <!--Optional:-->
            <remoteAddress></remoteAddress>
            <!--0 to 2 repetitions:-->
            <acceptableInfrastructure></acceptableInfrastructure>
         </ones:clientInfo>
         <!--Optional:-->
         <ones:signatureMetadata>
            <!--Optional:-->
            <reason></reason>
            <!--Optional:-->
            <location></location>
            <!--Optional:-->
            <contact></contact>
         </ones:signatureMetadata>
         <!--Optional:-->
         <ones:signatureDisplayProperties>
            <!--Optional:-->
            <position></position>
            <!--Optional:-->
            <displayValidity></displayValidity>
            <!--Optional:-->
            <signatureImageUrl></signatureImageUrl>
            <!--Optional:-->
            <backgroundImageUrl></backgroundImageUrl>
         </ones:signatureDisplayProperties>
         <!--Optional:-->
         <ones:mobileSigningText></ones:mobileSigningText>
         <ones:signingType>Signature</ones:signingType><ones:file>
            <fileDigest>cid:502841313118</fileDigest>
            <!--Optional:-->
            <fileName>somename</fileName>
            <content>cid:1348553326218</content>
         </ones:file>
         <ones:signature>cid:1279381531143</ones:signature>
      </ones:InitOneSignRequest>
   </soapenv:Body>
</soapenv:Envelope>
        """


protocol=ssl.PROTOCOL_TLSv1_2
ssl_context=ssl.SSLContext(protocol)
conn = httplib.HTTPSConnection('wstest.gosign.lt', context=ssl_context)
conn.connect()
conn.putrequest("POST", "https://wstest.gosign.lt/unisign/service/OneSignService/InitSigning; HTTP/1.1")
conn.putheader("SOAPAction", "https://wstest.gosign.lt/unisign/service/OneSignService/InitSigning")
conn.putheader("Content-Type", "text/xml; charset=utf-8" )
conn.putheader("Content-Length", len(xml))
conn.endheaders()
conn.send(xml)
response = conn.getresponse()
print(response.read())

=========================================================================================================

import requests

my_headers = {'Authorization' : 'Bearer {access_token}'}
response = requests.get('http://httpbin.org/headers', headers=my_headers)

session = requests.Session()
session.headers.update({'Authorization': 'Bearer {access_token}'})
response = session.get('https://httpbin.org/headers')

try:
    response = requests.get('http://api.open-notify.org/astros.json', timeout=5)
    response.raise_for_status()
    # Code here will only run if the request is successful
except requests.exceptions.HTTPError as errh:
    print(errh)
except requests.exceptions.ConnectionError as errc:
    print(errc)
except requests.exceptions.Timeout as errt:
    print(errt)
except requests.exceptions.RequestException as err:
    print(err)


