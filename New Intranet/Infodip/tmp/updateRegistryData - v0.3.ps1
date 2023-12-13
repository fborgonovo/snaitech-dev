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
            c) ... 

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

        User's data from the Intranet DB:
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
    v0.2 :  Change repetitive code into functions
            Added log functionality
    v0.3 :  Added log retention management
            Added deleted records management
            Nailed out some bugs
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

<# Includes #>

# Logger
. "D:\Users\furio\Workspace\Infodip\registryUpd\logger.ps1"

<# Constants #>
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

$sqlColumnsName = @(
    "samAccountName",
    "dataCreazione",
    "mailResp",
    "codAzienda",
    "codDipendente",
    "cognome",
    "nome",
    "mail",
    "id_reparto",
    "id_squadra",
    "id_divisione",
    "id_mansione",
    "codBU",
    "codRespStringa",
    "samResp",
    "codAzResp",
    "codDipResp",
    "id_avatar",
    "dataAssunzione",
    "dataNascita",
    "inquadramento",
    "unitaLocale",
    "unitaProduttiva",
    "cellulare",
    "interno",
    "sede",
    "Azienda",
    "Reparto",
    "Squadra",
    "Divisione",
    "Mansione",
    "Thumbnailphoto",
    "customAttribute6",
    "gruppoSPOwner",
    "gruppoSPReader"
)

$infoIdx = 0
$warningIdx = 1
$errorIdx = 2

$severity = @(
    "Info",
    "Warn",
    "Error"
)

$LOGPATH = 'D:\Users\furio\Workspace\Infodip\registryUpd\logs'
$ZIPEXT  = 'zip'
$RETAINS = 6

$today = Get-Date -Format "yyyyMMdd-HHMM"

$severityFile = @(
    "$($LOGPATH)\info-$($today).log",
    "$($LOGPATH)\warning-$($today).log",
    "$($LOGPATH)\error-$($today).log"    
)

$changeLog = @(
    "$($LOGPATH)\deleted-$($today).log",
    "$($LOGPATH)\modified-$($today).log",
    "$($LOGPATH)\added-$($today).log",
    "$($LOGPATH)\same-$($today).log"
)

$deletedIdx = 0
$updatedIdx = 1
$addedIdx = 2
$sameIdx = 3

$op = @(
    "DELETED",
    "MODIFIED",
    "ADDED",
    "SAME"
)

$opFile = @(
    "D:\Users\furio\Workspace\Infodip\registryUpd\del.log",
    "D:\Users\furio\Workspace\Infodip\registryUpd\mod.log",
    "D:\Users\furio\Workspace\Infodip\registryUpd\add.log" ,  
    "D:\Users\furio\Workspace\Infodip\registryUpd\same.log"    
)

# Utility functions

function logRESTData ($employee)
{
    logger -Message "company:             $($employee.company)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "sn:                  $($employee.sn)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "givenName:           $($employee.givenName)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "mail:                $($employee.mail)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "department:          $($employee.department)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "description:         $($employee.description)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "office:              $($employee.office)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "jobTitle:            $($employee.jobTitle)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "manager:             $($employee.manager)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "l:                   $($employee.l)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "streetAddress:       $($employee.streetAddress)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "telephoneNumber:     $($employee.telephoneNumber)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "mobile:              $($employee.mobile)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "thumbnailphoto:      $($employee.thumbnailphoto)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "customAttribute6:    $($employee.customAttribute6)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "gruppoSPOwner:       $($employee.gruppoSPOwner)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "gruppoSPReader:      $($employee.gruppoSPReader)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "mailDelResponsabile: $($employee.mailDelResponsabile)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codAzienda:          $($employee.codAzienda)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codDipendente:       $($employee.codDipendente)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codBu:               $($employee.codBu)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function logSQLData ($record)
{
    for ($i=0; $i -lt $record.ItemArray.length; $i++) {
        logger -Message "$($record.Table.Columns[$i]): $($record.ItemArray[$i])" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    }
}

function addRecord ($employee)
{
    logger -Message "*** Begin addRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logger -Message "Added: $($employee.mail)" -Level $severity[$infoIdx] -Path $changeLog[$addedIdx]

    logger -Message "*** End addRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function updateRecord ($recordKey, $samAccountName_idx, $recordNewValue)
{
    logger -Message "*** Begin updateRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    if ($recordKey -eq 'serena.carrara@snaitech.it')
    {
        $a=0
    }
    logger -Message "Updated: $($recordKey): $($recordNewValue)" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]

    logger -Message "*** End updateRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function delRecord ($recordKey)
{
    logger -Message "*** Begin delRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logger -Message "Deleted: $($recordKey)" -Level $severity[$infoIdx] -Path $changeLog[$deletedIdx]

    logger -Message "*** End delRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function delOldRecords ($employee, $record)
{
    logger -Message "*** Begin delOldRecords" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    for ($i=0; $i -lt $record.ItemArray.length; $i++) {
        $found = $false
        foreach($employee in $employeeData.Risposta.xmlForExcel.xmlForExcel) {
            if ($record.ItemArray[$i].mail.ToLower() -eq $employee.mail.ToLower())
            {
                $found = $true
                break
            }
        }
        if (-Not $found)
        {
            delRecord $record.ItemArray[$i].mail.ToLower()
        }
        else {
            logger -Message "Not changed: $($record.ItemArray[$i].mail.ToLower())" -Level $severity[$infoIdx] -Path $changeLog[$sameIdx]
        }
    }

    logger -Message "*** End delOldRecords" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function recordsDiffer ($employee, $record)
{
    logger -Message "*** Begin recordsDiffer" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    $differ = $false

    logger -Message "== REST data ===================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logRESTData $employee

    logger -Message "== DB data =====================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logSQLData $record

### samAccountName
    $nameDotSurname = $employee.mail.Split("@")
    $name,$surname = $nameDotSurname[0].Split(".").ToLower()
    $samAccountName = "$($surname)_$($name)"
    
    if ($samAccountName -ne $record.ItemArray[$samAccountName_idx].ToLower())
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $samAccountName_idx $samAccountName
    }

### mailDelResponsabile
    if ($employee.mailDelResponsabile.ToLower() -ne $record.ItemArray[$mailResp_idx].ToLower())
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $mailResp_idx $employee.mailDelResponsabile.ToLower()
    }

### codAzienda
    if ($employee.codAzienda -ne $record.ItemArray[$codAzienda_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $codAzienda_idx $employee.codAzienda
    }

### codDipendente
    if ($employee.codDipendente -ne $record.ItemArray[$codDipendente_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $codDipendente_idx $employee.codDipendente
    }

### sn
    if ($employee.sn.ToLower() -ne $record.ItemArray[$cognome_idx].ToLower())
    {
        $differ = $true
        $snNorm = (Get-Culture).TextInfo.ToTitleCase("$($employee.sn.ToLower())")
        updateRecord $employee.mail.ToLower() $cognome_idx $snNorm
    }

### givenName
    if ($employee.givenName.ToLower() -ne $record.ItemArray[$nome_idx].ToLower())
    {
        $differ = $true
        $givenNameNorm = (Get-Culture).TextInfo.ToTitleCase("$($employee.givenName.ToLower())")
        updateRecord $employee.mail.ToLower() $nome_idx $givenNameNorm
    }

<#=========================================================================================================================#>
<#
### mail
    if ($employee.mail.ToLower() -ne $record.ItemArray[$mail_idx].ToLower())
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $mail_idx $samAccountName
    }
#>
<#=========================================================================================================================#>

<# TBD xref
Le funzioni saranno abilitate dopo l'aggiornamento della REST che dovra' fornire i valori numerici oltre che le stringhe
per: REPARTO, SQUADRA, DIVISIONE, MANSIONE, UNITALOCALE e UNITAPRODUTTIVA
n.b. abilitare anche il blocco di funzioni xref precedenti

### id_reparto
    $id_reparto = xrefReparto $reparti $employee.department.ToLower()

    if ($id_reparto -ne $record.ItemArray[$id_reparto_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $id_reparto_idx  $id_reparto
    }

### id_squadra
    $id_squadra = xrefSquadra $squadre $employee.description.ToLower()

    if ($id_squadra -ne $record.ItemArray[$id_squadra_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $id_squadra_idx $id_squadra
    }

### id_divisione
    $id_divisione = xrefDivisione $divisioni $employee.office.ToLower()

    if ($id_divisione -ne $record.ItemArray[$id_divisione_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $id_divisione_idx $id_divisione
    }

### id_mansione
    $id_mansione = xrefDivisione $mansioni $employee.jobTitle.ToLower()

    if ($id_mansione -ne $record.ItemArray[$id_mansione_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $id_mansione_idx $id_mansione
    }
#>

### codBu
    if ($employee.codBu -ne $record.ItemArray[$codBU_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $codBU_idx $employee.codBu
    }

### manager
    if ($employee.manager -ne $record.ItemArray[$codRespStringa_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $codRespStringa_idx $employee.manager
    }

### samResp
    $nameDotSurname = $employee.mailDelResponsabile.Split("@")
    $name,$surname = $nameDotSurname[0].Split(".").ToLower()
    $samAccountName = "$($surname)_$($name)"

    if ($samAccountName -ne $record.ItemArray[$samResp_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $samResp_idx $samAccountName
    }

<#
Le funzioni saranno abilitate dopo l'aggiornamento della REST che dovra' fornire i valori numerici
per: codAzResp e codDipresp

### codAzResp
    $SqlCommand = "SELECT [codAzResp] FROM [dipendenti].[test].[dipendentiAD] WHERE [mail] = '$($employee.mail)'"
    logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    $SqlDataset = execSqlCommand $SqlCommand
    $codAzRespOld = $SqlDataset.Tables[0].Rows[0].ItemArray[0]
    if ($null -ne $codAzRespOld)
    {
        logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
    }
    $codAzRespNew = $employee.codAzResp

    if ($codAzRespNew -ne $codAzRespOld)
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $codAzResp_idx $codAzRespNew
        logger -Message "$($employee.mail.ToLower()) - old codAzResp: $($codAzRespOld), new codAzResp: $($codAzRespNew)" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }

### codDipResp
    $SqlCommand = "SELECT [codAzResp] FROM [dipendenti].[test].[dipendentiAD] WHERE [mail] = '$($employee.mail)'"
    logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    $SqlDataset = execSqlCommand $SqlCommand
    $codDipRespOld = $SqlDataset.Tables[0].Rows[0].ItemArray[0]
    if ($null -ne $codAzRespOld)
    {
        logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
    }

    $codDipRespNew = $employee.codDipResp

    if ($codDipRespNew -ne $codDipRespOld)
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $codDipResp_idx $codDipRespNew
        logger -Message "$($employee.mail.ToLower()) - old codAzResp: $($codAzRespOld), new codAzResp: $($codAzRespNew)" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }
#>

### id_avatar: TBD

### dataAssunzione: TBD

### dataNascita: TBD

### inquadramento: TBD

### unitaLocale
if ($employee.l.ToLower() -ne $unitaLocali.Tables[0].Rows[$record.ItemArray[$unitaLocale_idx]].ItemArray[1].ToLower())
{
    $differ = $true
    updateRecord $employee.mail $unitaLocale_idx $employee.l
}

### unitaProduttiva
if ($employee.streetAddress.ToLower() -ne $unitaProduttive.Tables[0].Rows[$record.ItemArray[$unitaProduttiva_idx]].ItemArray[1].ToLower())
{
    $differ = $true
    updateRecord $employee.mail.ToLower() $streetAddress_idx $employee.streetAddress
}

### cellulare
if ($employee.mobile -ne $record.ItemArray[$cellulare_idx])
{
    $differ = $true
    updateRecord $employee.mail.ToLower() $cellulare_idx $employee.mobile
}

### interno
if ($employee.telephoneNumber -ne $record.ItemArray[$interno_idx])
{
    $differ = $true
    updateRecord $employee.mail.ToLower() $interno_idx $employee.telephoneNumber
}

### sede
$a = $employee.streetAddress.ToLower()
    if ($employee.streetAddress.ToLower() -ne $record.ItemArray[$sede_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $sede_idx $employee.streetAddress.ToLower()
    }
    
### Azienda
    if ($employee.company.ToLower() -ne $record.ItemArray[$Azienda_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $Azienda_idx $employee.company.ToLower()
    }

### Reparto
    if ($employee.department.ToLower() -ne $record.ItemArray[$Reparto_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $Reparto_idx $employee.department.ToLower()
    }

### Squadra
    if ($employee.description.ToLower() -ne $record.ItemArray[$Squadra_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $Squadra_idx $employee.description.ToLower()
    }

### Divisione
    if ($employee.office.ToLower() -ne $record.ItemArray[$Divisione_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $Divisione_idx $employee.office.ToLower()
    }

### Mansione
    if ($employee.jobTitle.ToLower() -ne $record.ItemArray[$Mansione_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $Mansione_idx $employee.jobTitle.ToLower()
    }

### Thumbnailphoto: TBD

### customAttribute6
    if ($employee.customAttribute6.ToLower() -ne $record.ItemArray[$customAttribute6_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $customAttribute6_idx $employee.customAttribute6.ToLower()
    }

### gruppoSPOwner
    if ($employee.gruppoSPOwner.ToLower() -ne $record.ItemArray[$gruppoSPOwner_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $gruppoSPOwner_idx $employee.gruppoSPOwner.ToLower()
    }

### gruppoSPReader
    if ($employee.gruppoSPReader.ToLower() -ne $record.ItemArray[$gruppoSPReader_idx])
    {
        $differ = $true
        updateRecord $employee.mail.ToLower() $gruppoSPReader_idx $employee.gruppoSPReader.ToLower()
    }

### dataCreazione
    if ($differ)
    {
        $creationDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        updateRecord $employee.mail.ToLower() $dataCreazione_idx $creationDate
    }
    else
    {
        logger -Message "Same: $($record.ItemArray[$i].mail.ToLower())" -Level $severity[$infoIdx] -Path $changeLog[$samedIdx]
    }

    logger -Message "*** End recordsDiffer" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

#    return $differ
}

function multipleRecords ($records)
{
    logger -Message "*** Begin multipleRecords" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    foreach ($record in $records)
    {
        logSQLData $record
        logger -Message "================================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    };

    logger -Message "*** End multipleRecords" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}
function readEmployeeData ($employeeData_fn)
{
    logger -Message "*** Begin readEmployeeData" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    [xml]$employeeData = Get-Content $employeeData_fn

    logger -Message "*** End readEmployeeData" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    
    return $employeeData
}

<# TBD xref
Le funzioni saranno abilitate dopo l'aggiornamento della REST che dovra' fornire i valori numerici oltre che le stringhe
per: REPARTO, SQUADRA, DIVISIONE, MANSIONE, UNITALOCALE e UNITAPRODUTTIVA.
n.b. abilitare anche il blocco xref nel seguito

function xrefReparto ($reparti, $nomeReparto)
{
    $id_reparto = -1
    foreach($reparto in $reparti.Tables[0].Rows)
    {
        if ($nomeReparto -eq $reparto.Item('Reparto').ToLower())
        {
            $id_reparto = $reparto.Item('id_reparto')
            break
        }
    }
    
    return $id_reparto
}

function xrefSquadra ($squadre, $nomeSquadra)
{
    $id_squadra = -1
    foreach($squadra in $squadre.Tables[0].Rows)
    {
        if ($nomeSquadra -eq $squadra.Item('Squadra').ToLower())
        {
            $id_squadra = $squadra.Item('id_squadra')
            break
        }
    }
    
    return $id_squadra
}

function xrefDivisione ($divisioni, $nomeDivisione)
{
    $id_divisione = -1
    foreach($divisione in $divisioni.Tables[0].Rows)
    {
        if ($nomeDivisione -eq $divisione.Item('Divisione').ToLower())
        {
            $id_divisione = $divisione.Item('id_divisione')
            break
        }
    }
    
    return $id_divisione
}

function xrefMansione ($mansioni, $nomeMansione)
{
    $id_mansione = -1
    foreach($mansione in $mansioni.Tables[0].Rows)
    {
        if ($nomeMansione -eq $mansione.Item('Mansione').ToLower())
        {
            $id_mansione = $divisione.Item('id_mansione')
            break
        }
    }
    
    return $id_divisione
}
#>

function execSqlCommand ($SqlCommand)
{
    logger -Message "*** Begin execSqlCommand" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    try
    {
        ## Create the connection object
        $SqlConnection  = New-Object System.Data.SQLClient.SQLConnection
        #$SqlConnection .ConnectionString = "server=$INTRANET_SQLSERVER;database=$DIPENDENTI_DBNAME;Integrated Security=True;"
        $SqlConnection.ConnectionString = "server=$INTRANET_SQLSERVER;database=$DIPENDENTI_DBNAME;User ID=$UID;Password=$PWD;"
    
        ## Build the SQL command
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SqlCommand
        $SqlCmd.Connection = $SqlConnection

        ## Execute the query
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd

        ## Return the dataset
        $SqlDataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($SqlDataSet)
    } 
    catch 
    {
        $exceptionError = $_.Exception.Message
        logger -Message "execSqlCommand error: $($sqlCommand) - $($exceptionError)" -Level $severity[$errorIdx] -Path $severityFile[$errorIdx]

        $SqlDataSet = $null
    }
    finally 
    {
        ## Close the connection
        $SqlConnection.Close()
    }

    logger -Message "*** End execSqlCommand" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    return $SqlDataSet}

    function archiveLogs ($LOGPATH, $LOGEXT)
    {
        $archiveName = "logs-$($today).$($ZIPEXT)"
        $logsName = "*-$($today).$($LOGEXT)"

        $filesToArchive = "$($LOGPATH)\$($logsName)"
        $archiveName = "$($LOGPATH)\$($archiveName)"

        try {
            Compress-Archive -Path $filesToArchive -DestinationPath $archiveName -ErrorAction Stop
        } catch {
            Write-Output "Failed to create $($archiveName)"
            return
        }
        Remove-Item $filesToArchive -WhatIf
    }

    function trimLogsArchives ($LOGPATH, $ZIPEXT, $RETAINS)
    {
        $pattern = "logs-$($today).$($ZIPEXT)"
    
        Get-ChildItem -Path $LOGPATH |                  # Get all the items in $logPath
            Where-Object { -not $_.PsIsContainer } |    # Skip directories
            Where-Object { $_.Name -match $pattern } |  # Only get files that match log file name convenction and ext. format
            Sort-Object -Descending -Property Name |    # Sort them by name, from most recent to oldest
            Select-Object -Skip $RETAINS |              # Keep the first $RETAINS items
            Remove-Item -WhatIf
    }
        
<# 
##  ######################################### Main program starts #########################################
#>

logger -Message "Begin dipendentiAD update." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

<# DB Connection #>
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$Global:INTRANET_SQLSERVER = "intra-prod-db01.grupposnai.net"
$Global:DIPENDENTI_DBNAME = "dipendenti"
$Global:UID = 'dipendenti_updater'
$Global:PWD = 'dipendenti_updater!'

<# Load Reparti table #>
$SqlCommand = "SELECT * FROM [dipendenti].[dbo].[Reparti]"
logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

$global:reparti = execSqlCommand $SqlCommand

if ($null -eq $reparti)
{
    logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
}

<# Load Squadre table #>
$SqlCommand = "SELECT * FROM [dipendenti].[dbo].[Squadre]"
logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
$global:squadre = execSqlCommand $SqlCommand

if ($null -eq $squadre)
{
    logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
}

<# Load Divisioni table #>
$SqlCommand = "SELECT * FROM [dipendenti].[dbo].[Divisioni]"
logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
$global:divisioni = execSqlCommand $SqlCommand

if ($null -eq $divisioni)
{
    logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
}

<# Load Mansioni table #>
$SqlCommand = "SELECT * FROM [dipendenti].[dbo].[Mansioni]"
logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
$global:mansioni = execSqlCommand $SqlCommand

if ($null -eq $mansioni)
{
    logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
}

<# Load unitaLocale table #>
$SqlCommand = "SELECT * FROM [dipendenti].[dbo].[unitaLocale]"
logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
$global:unitaLocali = execSqlCommand $SqlCommand

if ($null -eq $unitaLocali)
{
    logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
}

<# Load unitaProduttiva table #>
$SqlCommand = "SELECT * FROM [dipendenti].[dbo].[unitaProduttiva]"
logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
$global:unitaProduttive = execSqlCommand $SqlCommand

if ($null -eq $unitaProduttive)
{
    logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
}

<# Get updated data #>
logger -Message "Loading REST data" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

#$uri = "http://10.177.111.32:8080/Employee/getXMLForExcel?caller=intranet&firma=E2E38FDC09A1CAEF479F96E887D049DB&requestId=1"
#[xml]$employeeData = Invoke-RestMethod -Method Post -ContentType "text/xml" -uri $uri

<# Local data will be used until exceptions are corrected by HR #>
[xml]$employeeData = readEmployeeData "D:\Users\furio\Workspace\Infodip\registryUpd\response_1579793785266.xml"

$employeesCnt = 0

foreach($employee in $employeeData.Risposta.xmlForExcel.xmlForExcel) {
    $employeesCnt++
    logger -Message "=== Working on record #$($employeesCnt): $($employee.mail) =============================================================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    <# Check user already in DB #>
    $SqlCommand = "SELECT * FROM [dipendenti].[test].[dipendentiAD] WHERE [mail] = '$($employee.mail)'"
    logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    $SqlDataset = execSqlCommand $SqlCommand
    if ($null -eq $SqlDataset)
    {
        logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$errorIdx]
        exit
    }

    switch ($SqlDataset.Tables[0].Rows.Count) {
        0 {
            logger -Message "Query returned no data. Adding new record." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
            addRecord $employee;
            break
        }
        1 {
            logger -Message "Record found. Checking for changes." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
            recordsDiffer $employee $SqlDataset.Tables[0].Rows[0]
            break
        }
        default {
            logger -Message "Multiple records found. Skipping." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
            multipleRecords $SqlDataset.Tables[0];
            break
        }
    }
#    exit # DEBUG
}

delOldRecords $employee $SqlDataset.Tables[0].Rows[0]

archiveLogs $LOGPATH $LOGEXT
trimLogsArchives $LOGPATH $LOGEXT $RETAINS

