<#
    User data updater.

    !!! MUST BE RUN AS 'dipendenti_updater' user through the runas.ps1 script !!!
    
    Workflow:
        1) Validate preconditions
        2) Get user's data from the REST at: http://10.177.111.32:8080/Employee/swagger-ui.html?username=admin&password=password#/dipendente-controller
                                             intranet - - E2E38FDC09A1CAEF479F96E887D049DB 1
        3) Convert XML user's data in table format
        4) For each record:
            a) Validate the record (see footnotes)
            b) Use the email field to search the SQL DB
            c) If 

	Parameter(s):

    operation  ->   0: Create new user, 1: Modify existing user, 2: Delete user
    user_data  ->   The following data are passed as CSV. If a field is not mandatory it can be left out.
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

# Utility functions

<#
function getUser() {
    
}

function addUser() {
    
}

function modUser() {
    
}

function delUser() {
    
}
#>

# Main program starts
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$Global:INTRANET_SQLSERVER = "intra-prod-db01.grupposnai.net"
$Global:DIPENDENTI_DBNAME = "dipendenti"
$Global:UID = 'dipendenti_updater'
$Global:PWD = 'dipendenti_updater!'

Try 
{ 
    $SQLConnection = New-Object System.Data.SQLClient.SQLConnection
    #$SQLConnection.ConnectionString = "server=$INTRANET_SQLSERVER;database=$DIPENDENTI_DBNAME;Integrated Security=True;"
    $SQLConnection.ConnectionString = "server=$INTRANET_SQLSERVER;database=$DIPENDENTI_DBNAME;User ID=$UID;Password=$PWD;"
    $SQLConnection.Open()
}
catch
{
    $exception = $_.Exception.Message
    [System.Windows.Forms.MessageBox]::Show("Failed to connect SQL Server: $exception")
    Write-Error $_.Exception.Message
    exit
}
 
$SQLCommand = New-Object System.Data.SqlClient.SqlCommand
$SQLCommand.CommandText = "SELECT * FROM [dipendenti].[dbo].[dipendentiAD] WHERE [cognome] LIKE '%liberatori%'"
$SQLCommand.Connection = $SQLConnection
 
$SQLAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SQLCommand
$SQLDataset = New-Object System.Data.DataSet
$SqlAdapter.fill($SQLDataset) | out-null
 
foreach ($data in $SQLDataset.tables[0])
{
    for ($i=0; $i -lt $data.ItemArray.length; $i++) {
        Write-Host -NoNewline $data.Table.Columns[$i] ': '
        Write-Host $data.ItemArray[$i]
    }
}

$SQLConnection.close()

<#
$SQLServer = "intra-prod-db01.grupposnai.net"
$db = "dipendenti"
$user = "GRUPPOSNAI\dipendenti_updater"
$pwd = "dipendenti_updater!"

switch ($operation) {
    0   {addUser}
    1   {modUser}
    2   {delUser}
}

$qcd = "SELECT * FROM dipendentiAD"
 
Invoke-Sqlcmd -ServerInstance $SQLServer -Database $db -Query $qcd -Username $user -Password $pwd -Verbose


function global:SelectAllUsers()
{
    Read-Query -ConnectionString 'Server=$SQLServer;Database=$db;UID=$user;PWD=somepassword;Integrated Security=true;' `
        -Query "SELECT * FROM dipendentiAD" `
        -Action {
            echo "I can take an action here"
        }
}

function Read-Query
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$ConnectionString,

        [Parameter(Mandatory=$true)]
        [string]$Query,

        [Parameter(Mandatory=$true)]
        [scriptblock]$Action
    )

    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = $ConnectionString
    $SqlConnection.Open()
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $Query
    $SqlCmd.Connection = $SqlConnection
    $reader = $SqlCmd.ExecuteReader()

    while ($reader.Read())
    {
        $x = $null
        $x = @{}

        for ($i = 0; $i -lt $reader.FieldCount; ++$i)
        {
            $x.add($reader.GetName($i), $reader[$i])
        }

        Invoke-Command -ScriptBlock $action -ArgumentList $x
    }

    $SqlConnection.Close()
}



SelectAllUsers

#>