
#= GLOBAL ========================================================================================================================

param(
#    [Parameter(Mandatory)]
    [string]$iis_log_file = "u_ex191214.log"
)

$scriptPath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptPath
$log_fn = "$dir\$iis_log_file"

New-Variable -Name TRACE_OFF   -Value 0 -Option ReadOnly -Force
New-Variable -Name TRACE_ON    -Value 1 -Option ReadOnly -Force
New-Variable -Name TRACE_FULL  -Value 2 -Option ReadOnly -Force

$TRACE = $TRACE_OFF

#= MAIN ==========================================================================================================================

function Main
{
    Set-PSDebug -Trace $TRACE

    Set-Location -Path $dir
    
    fn_Log_Info

    fn_Banner

    fn_List

    #Write-Host $log_fields

    #while($null -ne ($line = $stream_File_Reader.ReadLine())) {
    #    $line | Format-List $header
    #}
}

#= FUNCTIONS =====================================================================================================================

function fn_Log_Info
{
#Software: Microsoft Internet Information Services 10.0
#Version: 1.0
#Date: 2019-12-14 00:00:01
    $stream_File_Reader = New-Object System.IO.StreamReader($log_fn)

    $iis_software = $stream_File_Reader.ReadLine().Split("#")[1]
    $iis_version = $stream_File_Reader.ReadLine().Split("#")[1]
    $log_date = $stream_File_Reader.ReadLine().Split("#")[1]

    Write-Host $('=' * ($log_fn.length+31))
    Write-Host "=== IIS Log File Info: $log_fn ==="
    Write-Host $('=' * ($log_fn.length + 4))
    Write-Host

    Write-Host $iis_software
    Write-Host $iis_version
    Write-Host $log_date

    Write-Host $('=' * ($log_fn.length+31))

    $stream_File_Reader.Dispose()
}

function fn_Banner
{
    Write-Host
    Write-Host $('=' * ($log_fn.length+31))
    Write-Host "=== IIS Log File Analyzer: $log_fn ==="
    Write-Host $('=' * ($log_fn.length+31))
    Write-Host
}

function fn_Footer
{
    Write-Host
    Write-Host $('=' * ($log_fn.length+42))
    Write-Host "=== IIS Log File Analyzer: $log_fn - COMPLETE ==="
    Write-Host $('=' * ($log_fn.length+42))
    Write-Host
}

function fn_List
{
    $stream_File_Reader = New-Object System.IO.StreamReader("$log_fn")
    $line = $stream_File_Reader.ReadLine()
    $line = $stream_File_Reader.ReadLine()
    $line = $stream_File_Reader.ReadLine()

#    $header = $stream_File_Reader.ReadLine().Split(":")[1].Trim().Split(" ")
    $header = $stream_File_Reader.ReadLine().Split(":")[1].Trim().Replace(" ",",")

    Write-Host $header

    while($null -ne ($line = $stream_File_Reader.ReadLine() | Format-List -Property $header)) {
        $line
    }

    $stream_File_Reader.Dispose()
}

function fn_Table
{
    Write-Host $header
    while($null -ne ($line = $reader.ReadLine())) {
        $line | Format-Table $header
    }
}

function fn_Report_Daily_Users
{

}

function fn_Report_Hourly_Users ()
{

}

function fn_Report_Top_Hit_Pages ()
{

}

#=================================================================================================================================

. Main
