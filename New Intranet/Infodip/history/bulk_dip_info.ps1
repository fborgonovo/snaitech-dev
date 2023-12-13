<#

.SYNOPSIS
Informazioni su di un gruppo di impiegati SNAITECH

.DESCRIPTION
Ritorna le informazioni relative agli impiegati richiesti
presenti sul DB del Performance Evaluation.

.INPUTS
Nome del file contenente gli identificativi dei dipendenti

.OUTPUTS
Per ogni dipendente richiesto:

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
C:\PS> ./bulk_dip_info.ps1
Ritorna le modalita' d'uso dello script

.EXAMPLE
C:\PS> ./bulk_dip_info.ps1 <nome file dipentendi>
Ritorna le informazioni sui dipendente la cui eMail e'
presente nel file in input

.NOTES
Autore:
    Furio Angelo Borgonovo (SNAITECH)
    furio.borgonovo@snaitech.it
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
	[string]$filename = ' '
)

New-Variable -Name TRACE_OFF   -Value 0 -Option ReadOnly -Force
New-Variable -Name TRACE_ON    -Value 1 -Option ReadOnly -Force
New-Variable -Name TRACE_FULL  -Value 2 -Option ReadOnly -Force

$TRACE = $TRACE_OFF


#= MAIN ==========================================================================================================================

Set-PSDebug -Trace $TRACE

$scriptPath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptPath

Set-Location -Path $dir

if ( $filename -eq '' ) {
	Write-Host " "
	Write-Host "Uso: ./pilotDip.ps1  <nome file dipentendi pilota>"
	Write-Host " "
	exit
}

$ln = 1
foreach($line in [System.IO.File]::ReadLines("$dir/$filename"))
{
       Write-Host "#$ln : $line"
       $ln = $ln + 1
       $cmd = "$dir\infodip.ps1"
       & $cmd -requestId "REQ01" -user $line
if ( $ln -eq 3 ) { break }
}

Write-Host "Done!"