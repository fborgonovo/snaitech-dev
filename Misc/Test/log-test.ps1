# https://www.scalyr.com/blog/getting-started-quickly-powershell-logging/

<#
Alternative:
    $logFile = Join-Path -path "C:\Users\Utente\OneDrive\Documenti\SNAITECH\Workspaces\Misc\ps-utilities" -ChildPath "log-$(Get-date -f 'yyyyMMddHHmmss').txt";
    Set-PSFLoggingProvider -Name logfile -FilePath $logFile -Enabled $true;
Note:
    Install as admin PSFramework:
        Install-Module PSFramework
#>

param (
    [Parameter(Mandatory=$true)][int]$number
)

. "C:\Users\Utente\OneDrive\Documenti\SNAITECH\Workspaces\Misc\ps-utilities\Write-Log.ps1"

$logFile = "C:\Users\Utente\OneDrive\Documenti\SNAITECH\Workspaces\Misc\Test\log.txt"
$digits = $number.ToString().ToCharArray()
$sum = 0
#$logFile = Join-Path -path "C:\Users\Utente\OneDrive\Documenti\SNAITECH\Workspaces\Misc\Test" -ChildPath "log-$(Get-date -f 'yyyyMMddHHmmss').txt";
#Set-PSFLoggingProvider -Name logfile -FilePath $logFile -Enabled $true

While ($digits.Length -ne 1) {
    $sum = 0
    $digits | ForEach-Object { $sum += [int]$_.ToString() }
    $digits = $sum.ToString().ToCharArray()
#    Write-PSFMessage -Level Output -Message "Intermediate result: $($sum)"
    Write-Log -Message "Intermediate result: $($sum)" -Level Info -Path $logFile
}

Write-Output $digits