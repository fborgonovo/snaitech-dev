$excel_file_path = 'C:\ChangeLog.xlsx'

## Instantiate the COM object
$Excel = New-Object -ComObject Excel.Application
$ExcelWorkBook = $Excel.Workbooks.Open($excel_file_path)
$ExcelWorkSheet = $Excel.WorkSheets.item("sheet1")
$ExcelWorkSheet.activate()

## Find the first row where the first 7 columns are empty
$row = ($ExcelWorkSheet.UsedRange.Rows | ? { ($_.Value2 | ? {$_ -eq $null}).Count -eq 7 } | select -first 1).Row
$ExcelWorkSheet.Cells.Item($row,1) = 'COLUMN 1 Text'
$ExcelWorkSheet.Cells.Item($row,2) = 'COLUMN 2 Text'
$ExcelWorkSheet.Cells.Item($row,3) = 'COLUMN 3 Text'
$ExcelWorkSheet.Cells.Item($row,4) = 'COLUMN 4 Text'
$ExcelWorkSheet.Cells.Item($row,5) = 'COLUMN 5 Text' 
$ExcelWorkBook.Save()
$ExcelWorkBook.Close()
$Excel.Quit(
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
Stop-Process -Name EXCEL -Force


#= MAIN ==========================================================================================================================

Set-PSDebug -Trace $TRACE

$scriptPath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptPath
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


$Server = ".\sql2019";              
$Database = "FileStreamDemoDB_test";
$Dest = "C:\Export\";     
$bufferSize = 8192;

$Sql = "SELECT [Document_Name],[DocumentBin] FROM [FileStreamDemoDB_test].[dbo].[Tbl_Support_Documents]";

$con = New-Object Data.SqlClient.SqlConnection; 
$con.ConnectionString = "Data Source=$Server;" + "Integrated Security=True;" + "Initial Catalog=$Database"; 
$con.Open();

Write-Output ((Get-Date -format yyyy-MM-dd-HH:mm:ss) + ": Export FILESTREAM objects Started ...");

$cmd = New-Object Data.SqlClient.SqlCommand $Sql, $con; 
$rd = $cmd.ExecuteReader();

$out = [array]::CreateInstance('Byte', $bufferSize) 
  
  While ($rd.Read()) 
{ 
 try 
  { 
   Write-Output ("Exporting Objects from FILESTREAM container: {0}" -f $rd.GetString(0)); 
   # New BinaryWriter 
   $fs = New-Object System.IO.FileStream ($Dest + $rd.GetString(0)), Create, Write; 
   $bw = New-Object System.IO.BinaryWriter $fs; 
 
   $start = 0; 
   # Read first byte stream 
   $received = $rd.GetBytes(1, $start, $out, 0, $bufferSize - 1); 
   While ($received -gt 0) 
   { 
    $bw.Write($out, 0,      $received); 
    $bw.Flush(); 
    $start += $received; 
    # Read next byte stream 
    $received = $rd.GetBytes(1, $start, $out, 0, $bufferSize - 1); 
   } 
   $bw.Close(); 
   $fs.Close(); 
  } 
  catch 
  { 
   Write-Output ($_.Exception.Message) 
  } 
  finally 
  { 
   $fs.Dispose();         
  }
 }