<#
    User data updater.

    !!! MUST BE RUN AS 'dipendenti_updater' user through the runas.ps1 script !!!
    
    Workflow:
        1) Validate preconditions
        2) Get user's data from the REST: curl -X GET "http://10.177.111.32:8080/Employee/getXMLForExcel?caller=intranet&firma=E2E38FDC09A1CAEF479F96E887D049DB&requestId=1" -H  "accept: */*"
                                          intranet - - E2E38FDC09A1CAEF479F96E887D049DB 1
        3) Convert XML user's data in table format
        4) For each record:
            a) Validate the record (see footnotes)
            b) Use the email field to search the SQL DB
            c) If 

	Parameter(s):

        User's data from the REST:
            esito
            desc
            dipendente
            elencoDip
            company
            sn
            givenName
            mail
            department
            description
            office
            jobTitle
            manager
            l
            streetAddress
            telephoneNumber
            mobile
            thumbnailphoto
            customAttribute6
            gruppoSPOwner
            gruppoSPReader
            mailDelResponsabile
            codAzienda
            codDipendente
            codBu

        User's fields in the Intranet DB:
            [samAccountName]    [varchar](255) NULL,
            [dataCreazione]     [nvarchar](50) NULL,
            [mailResp]          [nvarchar](50) NULL,
            [codAzienda]        [tinyint] NULL,
            [codDipendente]     [smallint] NULL,
            [cognome]           [nvarchar](50) NULL,
            [nome]              [nvarchar](50) NULL,
            [mail]              [nvarchar](50) NULL,
            [id_reparto]        [int] NULL,
            [id_squadra]        [int] NULL,
            [id_divisione]      [int] NULL,
            [id_mansione]       [int] NULL,
            [codBU]             [smallint] NULL,
            [codRespStringa]    [nvarchar](50) NULL,
            [samResp]           [nvarchar](50) NULL,
            [codAzResp]         [tinyint] NULL,
            [codDipResp]        [smallint] NULL,
            [id_avatar]         [nvarchar](1) NULL,
            [dataAssunzione]    [date] NULL,
            [dataNascita]       [date] NULL,
            [inquadramento]     [nvarchar](1) NULL,
            [unitaLocale]       [int] NULL,
            [unitaProduttiva]   [int] NULL,
            [cellulare]         [nvarchar](50) NULL,
            [interno]           [nvarchar](50) NULL,
            [sede]              [nvarchar](50) NULL,
            [Azienda]           [varchar](255) NULL,
            [Reparto]           [varchar](255) NULL,
            [Squadra]           [varchar](255) NULL,
            [Divisione]         [varchar](255) NULL,
            [Mansione]          [varchar](255) NULL,
            [Thumbnailphoto]    [varchar](255) NULL,
            [customAttribute6]  [varchar](255) NULL,
            [gruppoSPOwner]     [varchar](255) NULL,
            [gruppoSPReader]    [varchar](255) NULL
	
	History:

	v0.1 :	Project start
#>

<#
__author__ = "Furio Angelo Borgonovo"
__copyright__ = ""
__date__ = "Jan 2020"
__credits__ = [""]
__license__ = ""
__version__ = "0.1"
__maintainer__ = "Furio Angelo Borgonovo"
__email__ = "furio.borgonovo@snaitech.it"
__status__ = "Prototype"
#>

# Constants
$samAccountName_idx   = 1
$dataCreazione_idx    = 2
$mailResp_idx         = 3
$codAzienda_idx       = 4
$codDipendente_idx    = 5
$cognome_idx          = 6
$nome_idx             = 7
$mail_idx             = 8
$id_reparto_idx       = 9
$id_squadra_idx       = 10
$id_divisione_idx     = 11
$id_mansione_idx      = 12
$codBU_idx            = 13
$codRespStringa_idx   = 14
$samResp_idx          = 15
$codAzResp_idx        = 16
$codDipResp_idx       = 17
$id_avatar_idx        = 18
$dataAssunzione_idx   = 19
$dataNascita_idx      = 20
$inquadramento_idx    = 21
$unitaLocale_idx      = 22
$unitaProduttiva_idx  = 23
$cellulare_idx        = 24
$interno_idx          = 25
$sede_idx             = 26
$Azienda_idx          = 27
$Reparto_idx          = 28
$Squadra_idx          = 29
$Divisione_idx        = 30
$Mansione_idx         = 31
$Thumbnailphoto_idx   = 32
$customAttribute6_idx = 33
$gruppoSPOwner_idx    = 34
$gruppoSPReader_idx   = 35

# Utility functions

function addRecord ($employee)
{
    Write-Host '*** ADDING NEW RECORD'

}

function modifyRecord ($employee)
{
    Write-Host '*** MODIFYING RECORD'
}

function delRecord ($employee)
{
    Write-Host '*** DELETING RECORD'
}
function logRESTData ($employee)
{
    Write-Host '*** LOG REST DATA'

    Write-Host 'company:             '$employee.company
    Write-Host 'sn:                  '$employee.sn
    Write-Host 'givenName:           '$employee.givenName
    Write-Host 'mail:                '$employee.mail
    Write-Host 'department:          '$employee.department
    Write-Host 'description:         '$employee.description
    Write-Host 'office:              '$employee.office
    Write-Host 'jobTitle:            '$employee.jobTitle
    Write-Host 'manager:             '$employee.manager
    Write-Host 'l:                   '$employee.l
    Write-Host 'streetAddress:       '$employee.streetAddress
    Write-Host 'telephoneNumber:     '$employee.telephoneNumber
    Write-Host 'mobile:              '$employee.mobile
    Write-Host 'thumbnailphoto:      '$employee.thumbnailphoto
    Write-Host 'customAttribute6:    '$employee.customAttribute6
    Write-Host 'gruppoSPOwner:       '$employee.gruppoSPOwner
    Write-Host 'gruppoSPReader:      '$employee.gruppoSPReader
    Write-Host 'mailDelResponsabile: '$employee.mailDelResponsabile
    Write-Host 'codAzienda:          '$employee.codAzienda
    Write-Host 'codDipendente:       '$employee.codDipendente
    Write-Host 'codBu:               '$employee.codBu
}
function logSQLData ($record)
{
    Write-Host '*** LOG SQL DATA'

    for ($i=0; $i -lt $record.ItemArray.length; $i++) {
        Write-Host -NoNewline $record.Table.Columns[$i] ': '
        Write-Host $record.ItemArray[$i]
    }
}

function recordsDiffer ($employee, $record)
{
    $samAccountName_idx = 1

    Write-Host '*** CHECKING REST AND SQL DATA CONSISTENCY'

    $checkResult = $false

    logRESTData $employee

    Write-Host '================================================================'

    logSQLData $record

    #samAccountName
    $nameDotSurname = $record.ItemArray[$mail_idx].Split("@")
    $name,$surname = $nameDotSurname[0].Split(".")
    $samAccountName = "$($surname)_$($name)"
    if ($samAccountName.ToLower() -ne $record.ItemArray[$samAccountName_idx].ToLower())
    {
        $checkResult = $true
        updateRecord $record.ItemArray[$mail_idx], $samAccountName_idx, $samAccountName
    }
    $record.ItemArray[0].ToLower() 
    #dataCreazione
    $record.ItemArray[1].ToLower()
    #mailResp
    $record.ItemArray[2]
    #codAzienda
    $record.ItemArray[3]
    #codDipendente
    $record.ItemArray[4]
    #cognome
    $record.ItemArray[5]
    #nome
    $record.ItemArray[6]
    #mail
    $record.ItemArray[8]
    #id_reparto
    $record.ItemArray[8]
    #id_squadra
    $record.ItemArray[9]
    #id_divisione
    $record.ItemArray[10]
    #id_mansione
    $record.ItemArray[11]
    #codBU
    $record.ItemArray[12]
    #codRespStringa
    $record.ItemArray[13]
    #samResp
    $record.ItemArray[14]
    #codAzResp
    $record.ItemArray[15]
    #codDipResp
    $record.ItemArray[16]
    #id_avatar
    $record.ItemArray[17]
    #dataAssunzione
    $record.ItemArray[18]
    #dataNascita
    $record.ItemArray[19]
    #inquadramento
    $record.ItemArray[20]
    #unitaLocale
    $record.ItemArray[21]
    #unitaProduttiva
    $record.ItemArray[22]
    #cellulare
    $record.ItemArray[23]
    #interno
    $record.ItemArray[24]
    #sede
    $record.ItemArray[25]
    #Azienda
    $record.ItemArray[26]
    #Reparto
    $record.ItemArray[27]
    #Squadra
    $record.ItemArray[28]
    #Divisione
    $record.ItemArray[29]
    #Mansione
    $record.ItemArray[30]
    #Thumbnailphoto
    $record.ItemArray[31]
    #customAttribute6
    $record.ItemArray[32]
    #gruppoSPOwner
    $record.ItemArray[33]
    #gruppoSPReader
    $record.ItemArray[34]

    return $checkResult
}

function multipleRecords ($records)
{
    Write-Host '*** MULTIPLE RECORDS'

    foreach ($record in $records)
    {
        logSQLData $record
        Write-Host '================================================================'
    };
}
function readEmployeeData ($employeeData_fn)
{
    [xml]$employeeData = Get-Content $employeeData_fn
    
    return $employeeData
}

# Main program starts

<# DB Connection #>
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$Global:INTRANET_SQLSERVER = "intra-prod-db01.grupposnai.net"
$Global:DIPENDENTI_DBNAME = "dipendenti"
$Global:UID = 'dipendenti_updater'
$Global:PWD = 'dipendenti_updater!'

<# Get updated data #>
#$uri = "http://10.177.111.32:8080/Employee/getXMLForExcel?caller=intranet&firma=E2E38FDC09A1CAEF479F96E887D049DB&requestId=1"
#[xml]$employeeData = Invoke-RestMethod -Method Post -ContentType "text/xml" -uri $uri

<# Local data will be used until exceptions are corrected by HR #>
[xml]$employeeData = readEmployeeData "D:\Users\furio\Workspace\Infodip\registryUpd\response_1579793785266.xml"

$recCnt = 0

foreach($employee in $employeeData.Risposta.xmlForExcel.xmlForExcel) {
    Write-Host 'Record #'$recCnt
    Write-Host '================================================================'
    logRESTData $employee
    Write-Host '================================================================'
    $recCnt++

    <# Check user already in DB #>
    try
    {
        ## Create the connection object
        $SqlConnection  = New-Object System.Data.SQLClient.SQLConnection
        #$SqlConnection .ConnectionString = "server=$INTRANET_SQLSERVER;database=$DIPENDENTI_DBNAME;Integrated Security=True;"
        $SqlConnection.ConnectionString = "server=$INTRANET_SQLSERVER;database=$DIPENDENTI_DBNAME;User ID=$UID;Password=$PWD;"
    
        ## Build the SQL command
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = "SELECT * FROM [dipendenti].[dbo].[dipendentiAD] WHERE [mail] = '$($employee.mail)'"
        $SqlCmd.Connection = $SqlConnection

        ## Execute the query
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd

        ## Return the dataset
        $SqlDataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($SqlDataSet)
        $SqlDataSet.Tables[0]
    } 
    catch 
    {
        Write-Error $_.Exception.Message
    }
    finally 
    {
        ## Close the connection
        $SqlConnection.Close()
    }

    switch ($SQLDataset.Tables[0].Rows.Count) {
        0 {
            Write-Host $SQLCommand.CommandText;
            Write-Host "Query returned no data. Adding new record.";
            addNewRecord $employee;
            break
          }
        1 {
            Write-Host "Record found. Checking for changes";
            if (recordsDiffer $employee $SQLDataset.Tables[0].Rows[0])
            {
                Write-Host "Record not changed. No modification made.";
            } else {
                Write-Host "Record not changed. No modification made.";
            };
            break
          }
        default {
            Write-Host $SQLCommand.CommandText;
            Write-Host "Multiple records found. Skipping. ";
            multipleRecords $SQLDataset.Tables[0];
            break
          }
    }
exit
}

$SQLConnection.close()
