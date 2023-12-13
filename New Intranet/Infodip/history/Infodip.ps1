<#

.SYNOPSIS
Informazioni su di un impiegato SNAITECH

.DESCRIPTION
Ritorna le informazioni relative all'impiegato richiesto
presenti sul DB del Performance Evaluation.

Il servizio si trova alla URL:
http://10.177.111.32:8080

con i parametri:

/Employee/getDipendente?caller=$caller&codiceFiscale=$codiceFiscale&firma=$firma&requestId=$requestId
                                       -------------
oppure

/Employee/getDipendente?caller=$caller&email=$email&firma=$firma&requestId=$requestId
                                       -----

.INPUTS
Identificativo della richiesta
eMail del dipendente oppure Codice fiscale del dipendente

.OUTPUTS
Codice Azienda
Codice Dipendente
Nome Dipendente
Cognome Dipendente
Codice Fiscale
eMail
Codice Azienda Responsabile
Codice Dipendente Responsabile
ID Avatar
ID Divisione
Divisione
ID Squadra
Squadra
ID Reparto
Reparto
ID Mansione
Mansione
Nome Responsabile
eMail Responsabile
unitaLocale
unitaProduttiva
Responsabile

.EXAMPLE
C:\PS> ./Infodip.ps1
Ritorna le modalita' d'uso dello script

.EXAMPLE
C:\PS> ./Infodip.ps1 <requestId> <codiceFiscale>
Ritorna le informazioni sul dipendente il cui codice fiscale e' <codiceFiscale>

.EXAMPLE
C:\PS> ./Infodip.ps1 <requestId> <email>
Ritorna le informazioni sul dipendente la cui eMail e' <email>

.NOTES
Autore:
    Furio Angelo Borgonovo (SNAITECH)
    furio.borgonovo@snaitech.it

Le corrispondenze tra identificativo e descrizione dei campi "Unita' locale" e
"Unita' produttiva" sono tabellata nei file "..\Unita locale.txt" e
"..\Unita produttiva.txt" rispettivamente.

I dati presenti nelle tabelle "Unita' locale" e "Unita' produttiva" non sono
validi per lo scopo suggerito intuitivamente dal loro nome. Verranno sostituiti
a breve

.LINK
http://10.177.111.32:8080

#>

<#
Trace level:

0 Turns off script tracing.

1 Traces each line of the script as it is executed. Lines in the script that are
  not executed are not traced. Does not display variable assignments, function
  calls, or external scripts.

2 Traces each line of the script as it is executed. Lines in the script that are
  not executed are not traced. Displays variable assignments, function calls, and
  external scripts.
#>

#= GLOBAL ========================================================================================================================

param (
    [string]$requestId = ' ',
	[string]$user = ''
)

New-Variable -Name TRACE_OFF   -Value 0 -Option ReadOnly -Force
New-Variable -Name TRACE_ON    -Value 1 -Option ReadOnly -Force
New-Variable -Name TRACE_FULL  -Value 2 -Option ReadOnly -Force

$TRACE = $TRACE_OFF

#= FUNCTIONS =====================================================================================================================

function IsValidEmail {
# TBD
    return $true
}

function IsValidCF {
# TBD
    return $true
}

function displayUserData {
    param (
        [xml]$result
    )

    Write-Host " "
    Write-Host "Informazioni dipendente:"
    Write-Host " "
    Write-Host "Codice Azienda:                   "$result.Risposta.dipendente.codAzienda
    Write-Host "Codice Dipendente:                "$result.Risposta.dipendente.codDipendente
    Write-Host "Nome Dipendente:                  "$result.Risposta.dipendente.nome
    Write-Host "Cognome Dipendente:               "$result.Risposta.dipendente.cognome
    Write-Host "Codice Fiscale:                   "$result.Risposta.dipendente.codFisc
    Write-Host "eMail:                            "$result.Risposta.dipendente.mail
    Write-Host "Codice Azienda Responsabile:      "$result.Risposta.dipendente.codAzResp
    Write-Host "Codice Dipendente Responsabile:   "$result.Risposta.dipendente.codDipResp
    Write-Host "ID Avatar:                        "$result.Risposta.dipendente.id_avatar
    Write-Host "ID Divisione:                     "$result.Risposta.dipendente.idDivisione
    Write-Host "Divisione:                        "$result.Risposta.dipendente.divisione
    Write-Host "ID Squadra:                       "$result.Risposta.dipendente.idSquadra
    Write-Host "Squadra:                          "$result.Risposta.dipendente.squadra
    Write-Host "ID Reparto:                       "$result.Risposta.dipendente.idReparto
    Write-Host "Reparto:                          "$result.Risposta.dipendente.reparto
    Write-Host "ID Mansione:                      "$result.Risposta.dipendente.idMansione
    Write-Host "Mansione:                         "$result.Risposta.dipendente.mansione
    Write-Host "Nome Responsabile:                "$result.Risposta.dipendente.nomeResponsabile
    Write-Host "eMail Responsabile:               "$result.Risposta.dipendente.mailResponsabile
    Write-Host "Responsabile:                     "$result.Risposta.dipendente.responsabile
    Write-Host "Cognome Responsabile:             "$result.Risposta.dipendente.cognomeResponsabile
    Write-Host "Codice locale:                    "$result.Risposta.dipendente.codiceLocale
    Write-Host "Codice descrizioneLocale:         "$result.Risposta.dipendente.descrizioneLocale
    Write-Host "Codice codiceFiliale:             "$result.Risposta.dipendente.codiceFiliale
    Write-Host "Codice descrizioneFiliale:        "$result.Risposta.dipendente.descrizioneFiliale
    Write-Host "Codice codiceStato:               "$result.Risposta.dipendente.codiceStato
    Write-Host "Codice codiceCitta:               "$result.Risposta.dipendente.codiceCitta
    Write-Host "Codice descrizioneCitta:          "$result.Risposta.dipendente.descrizioneCitta
    Write-Host "Codice codiceProvincia:           "$result.Risposta.dipendente.codiceProvincia
    Write-Host "Codice codiceStatoResidenza:      "$result.Risposta.dipendente.codiceStatoResidenza
    Write-Host "Codice descrizioneCittaResidenza: "$result.Risposta.dipendente.descrizioneCittaResidenza
    Write-Host "Codice codiceProvinciaResidenza:  "$result.Risposta.dipendente.codiceProvinciaResidenza

    Write-Host " "
}
function Read-Get-RestAPICall {
    param(
        [Parameter(Position=0, Mandatory = $true, ValueFromPipeline = $true)] `
            [string]$url,
        [Parameter(Position=1, Mandatory = $false, ValueFromPipeline = $true)] `
            [System.Collections.Generic.Dictionary[[String],[String]]]$headers
    )
    try {
        if ($headers) {
            $request = Invoke-RestMethod -Method GET -Headers $headers -Uri $url
        } else {
            $request = Invoke-RestMethod -Uri $url
        }
    } catch [System.Net.WebException] {
        $exceptionError = $_.Exception

        switch ($exceptionError.Response.StatusCode.value__) {
            "200"   {
                Write-Host "=> Get-RestAPICall -> OK - $url <=" `
                    -ForegroundColor Green
            }
            "400"   {
                Write-Host "=> Get-RestAPICall -> Bad Request - $url <=" `
                    -ForegroundColor Red
                $request = $null
            }
            "404"   {
                Write-Host "=> Get-RestAPICall -> Not Found - $url <=" `
                    -ForegroundColor Red
                $request = $null
            }
            "405"   {
                Write-Host "=> Get-RestAPICall -> Invalid Method - $url <=" `
                    -ForegroundColor Red
                Write-Host "=> StatusCode:" $exceptionError.Response.StatusCode.value__ `
                    -ForegroundColor Yellow
                Write-Host "=> StatusDescription:" $exceptionError.Response.StatusDescription `
                    -ForegroundColor Yellow
                Write-Host "=> Type:" $exceptionError.GetType() -ForegroundColor Yellow
                Exit
            }
            "500"   {
                Write-Host "=> Get-RestAPICall -> Internal Server Error - $url <=" `
                    -ForegroundColor Red
                Write-Host "=> StatusCode:" $exceptionError.Response.StatusCode.value__ `
                    -ForegroundColor Yellow
                Write-Host "=> StatusDescription:" $exceptionError.Response.StatusDescription `
                    -ForegroundColor Yellow
                Write-Host "=> Type:" $exceptionError.GetType() -ForegroundColor Yellow
                Exit
            }
            "503"   {
                Write-Host "=> Get-RestAPICall -> Service Unavailable - $url <=" `
                    -ForegroundColor Red
                Write-Host "=> StatusCode:" $exceptionError.Response.StatusCode.value__ `
                    -ForegroundColor Yellow
                Write-Host "=> StatusDescription:" $exceptionError.Response.StatusDescription `
                    -ForegroundColor Yellow
                Write-Host "=> Type:" $exceptionError.GetType() -ForegroundColor Yellow
                Exit
            }
            default  {
                Write-Host "=> Get-RestAPICall -> Unspecified Error - $url <=" `
                    -ForegroundColor Red
                Write-Host "=> StatusCode:" $exceptionError.Response.StatusCode.value__ `
                    -ForegroundColor Yellow
                Write-Host "=> StatusDescription:" $exceptionError.Response.StatusDescription `
                    -ForegroundColor Yellow
                Write-Host "=> Type:" $exceptionError.GetType() -ForegroundColor Yellow
                Exit
            }
        }
    }

    return $request
}

#= MAIN ==========================================================================================================================

Set-PSDebug -Trace $TRACE

<#
if ($TRACE -ne $TRACE_OFF) {
    Write-Host "My directory is: $dir"
    $requestId = 'REQID-A01'
    #$user      = 'BRGFNG58C28F205D'
    $user      = 'furio.borgonovo@snaitech.it'
}
#>
if ( $requestId -eq '' ) {
	Write-Host " "
	Write-Host "Uso: ./Infodip.ps1  <requestId> <eMail> / <Codice fiscale del dipendente>"
	Write-Host " "
	exit
}

$caller        = 'intranet'
$email         = ''
$codiceFiscale = ''
$firma         = ''
$secretKey     = 'Intranet2019Test'

$sigString     = "$caller"+"$requestId"+"$secretKey"
$md5           = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8          = new-object -TypeName System.Text.UTF8Encoding

$firma = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($sigString)))
$firma = $firma.Replace('-', '')

if (($user.ToCharArray()) -contains [char]'@') {
    $email = $user
    if ( IsValidEmail($email) ) {
        $result = Read-Get-RestAPICall ("http://10.177.111.32:8080/Employee/getDipendente?caller=$caller&email=$email&firma=$firma&requestId=$requestId")
    } else {
        Write-Host "<FATAL> Invalid eMail: "$email
        exit
    }
} else {
    $codiceFiscale = $user
    if ( IsValidEmail($email) ) {
        $result = Read-Get-RestAPICall ("http://10.177.111.32:8080/Employee/getDipendente?caller=$caller&codiceFiscale=$codiceFiscale&firma=$firma&requestId=$requestId")
    } else {
        Write-Host "<FATAL> Invalid CF: "$codiceFiscale
        exit
    }
}

Write-Host " "
Write-Host "Esito richiesta per <"$email">: "$result.Risposta.esito" -> "$result.Risposta.desc

if (($result.Risposta.desc) -like '*non*') {
    Write-Host " "
    Write-Host "<FATAL> Program terminated"
    Write-Host " "
    $retCode = 0
} else {
    Write-Host " "
    Write-Host "Retrieving" $user "info..."
    displayUserData($result)
    $retCode = 1
}

exit $retCode

#= END ===========================================================================================================================
