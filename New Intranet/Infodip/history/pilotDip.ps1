
#= GLOBAL ========================================================================================================================

param (
    [string]$pilotDipList = ' '
)

New-Variable -Name TRACE_OFF   -Value 0 -Option ReadOnly -Force
New-Variable -Name TRACE_ON    -Value 1 -Option ReadOnly -Force
New-Variable -Name TRACE_FULL  -Value 2 -Option ReadOnly -Force

$TRACE = $TRACE_OFF

#= FUNCTIONS =====================================================================================================================

#= MAIN ==========================================================================================================================

Set-PSDebug -Trace $TRACE

$scriptPath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptPath
$listaDipendenti = "Caricamento dipendenti su AD.csv"
$elencoDipPilota = "elencoDipPilota.csv"

Add-Content -Path $dir/$elencoDipPilota -Value '"company", "sn", "givenName", "mail", "department", "description", "office", "jobTitle", "manager", "l", "streetAddress", "telephoneNumber", "mobile", "thumbnailphoto", "customAttribute6"'

Set-Location -Path $dir

if ( $filename -eq '' ) {
	Write-Host " "
	Write-Host "Uso: ./pilotDip.ps1  <nome file dipentendi>"
	Write-Host " "
	exit
}

$ln = 1
foreach($linePilot in [System.IO.File]::ReadLines("$dir/$pilotDipList")) {
	Write-Host "#$ln : $linePilot"
	$ln = $ln + 1
	$csv = Import-Csv "$dir/$listaDipendenti"
	$csv | ForEach-Object {
		if ( $_.mail -eq $linePilot ) {
#			Add-Content -Path "$dir/$elencoDipPilota" -Value '"$_.company", "$_.sn", '$_.givenName', '$_.mail', '$_.department', '$_.description', '$_.office', '$_.jobTitle', '$_.manager', '$_.l', '$_.streetAddress', '$_.telephoneNumber', '$_.mobile', '$_.thumbnailphoto', '$_.customAttribute6"'
			Add-Content -Path "$dir/$elencoDipPilota" -Value '"$_.company", "$_.sn"'
		}
	}
}

Write-Host "Done!"