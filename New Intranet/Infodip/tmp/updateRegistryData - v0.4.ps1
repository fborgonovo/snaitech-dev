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
    v0.4 :  
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
$id_dipendente_idx    = 0
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
    "id_dipendente",
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

$LOGPATH = 'D:\Users\furio\Workspace\Infodip\registryUpd\logs'
$ZIPEXT  = 'zip'
$RETAINS = 6

$today = Get-Date -Format "yyyyMMdd-HHMM"

$infoIdx    = 0
$warningIdx = 1
$errorIdx   = 2

$severity = @(
    "Info",
    "Warn",
    "Error"
)

$severityFile = @(
    "$($LOGPATH)\info-$($today).log",
    "$($LOGPATH)\warning-$($today).log",
    "$($LOGPATH)\error-$($today).log"    
)

$deletedIdx = 0
$updatedIdx = 1
$addedIdx   = 2
$sameIdx    = 3

$changeLog = @(
    "$($LOGPATH)\deleted-$($today).log",
    "$($LOGPATH)\modified-$($today).log",
    "$($LOGPATH)\added-$($today).log",
    "$($LOGPATH)\same-$($today).log"
)

# Utility functions

function logRESTData ($restData)
{
    logger -Message "company:             $($restData.company)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "sn:                  $($restData.sn)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "givenName:           $($restData.givenName)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "mail:                $($restData.mail)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "department:          $($restData.department)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "description:         $($restData.description)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "office:              $($restData.office)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "jobTitle:            $($restData.jobTitle)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "manager:             $($restData.manager)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "l:                   $($restData.l)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "streetAddress:       $($restData.streetAddress)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "telephoneNumber:     $($restData.telephoneNumber)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "mobile:              $($restData.mobile)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "thumbnailphoto:      $($restData.thumbnailphoto)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "customAttribute6:    $($restData.customAttribute6)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "gruppoSPOwner:       $($restData.gruppoSPOwner)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "gruppoSPReader:      $($restData.gruppoSPReader)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "mailDelResponsabile: $($restData.mailDelResponsabile)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codAzienda:          $($restData.codAzienda)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codDipendente:       $($restData.codDipendente)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codBu:               $($restData.codBu)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function logSQLData ($sqlData)
{
    for ($i=0; $i -lt $sqlData.ItemArray.length; $i++) {
        logger -Message "$($sqlData.Table.Columns[$i]): $($sqlData.ItemArray[$i])" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    }
}

function addRecord ($restData)
{
    logger -Message "*** Begin addRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logger -Message "[ADDED] $($restData.mail)" -Level $severity[$infoIdx] -Path $changeLog[$addedIdx]

    logger -Message "*** End addRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function updateRecord ($sqlDataKey, $sqlColumnName_idx, $sqlDataNewValue)
{
    logger -Message "*** Begin updateRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logger -Message "[UPDATED] $($sqlDataKey) - $($sqlColumnsName[$sqlColumnName_idx]): '$($sqlDataNewValue)'" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]

    logger -Message "*** End updateRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function delRecord ($sqlDataKey)
{
    logger -Message "*** Begin delRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logger -Message "[DELETED] $($sqlDataKey)" -Level $severity[$infoIdx] -Path $changeLog[$deletedIdx]

    logger -Message "*** End delRecord" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function delRemovedRecords ($restData, $sqlData)
{
    logger -Message "*** Begin delRemovedRecords" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    for ($i=0; $i -lt $sqlData.ItemArray.length; $i++) {
        $found = $false
        foreach($employee in $restData.Risposta.xmlForExcel.xmlForExcel) {
            if ($sqlData.ItemArray[$i].mail.ToLower() -eq $employee.mail.ToLower())
            {
                $found = $true
                break
            }
        }
        if (-Not $found)
        {
            delRecord $sqlData.ItemArray[$i].mail.ToLower()
        }
    }

    logger -Message "*** End delRemovedRecords" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function sqlFieldFixed ( $sqlField )
{
    if ($sqlField -is [System.DBNull]) {
        return " "
    }
    else
    {
        return $sqlField    
    }
}
function recordsDiffer ($restData, $sqlData)
{
    logger -Message "*** Begin recordsDiffer" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    $differ = $false

    logger -Message "== REST data ===================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logRESTData $restData

    logger -Message "== DB data =====================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logSQLData $sqlData

### samAccountName
    $nameDotSurname = $restData.mail.Split("@")
    $name,$surname = $nameDotSurname[0].Split(".").ToLower()
    $samAccountName = "$($surname)_$($name)"

    <###
                        Add anomalies management
    ###>

    $sqlField = sqlFieldFixed $sqlData.ItemArray[$samAccountName_idx]

    if ($samAccountName -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $samAccountName_idx $samAccountName
    }

### mailDelResponsabile
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$mailResp_idx]

    if ($restData.mailDelResponsabile.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $mailResp_idx $restData.mailDelResponsabile.ToLower()
    }

### codAzienda
    if ($restData.codAzienda -ne $sqlData.ItemArray[$codAzienda_idx])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codAzienda_idx $restData.codAzienda
    }

### codDipendente
    if ($restData.codDipendente -ne $sqlData.ItemArray[$codDipendente_idx])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codDipendente_idx $restData.codDipendente
    }

### sn
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$cognome_idx]
!!!!!!!!!! Continue 
    if ($restData.sn.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        $snNorm = (Get-Culture).TextInfo.ToTitleCase("$($restData.sn.ToLower())")
        updateRecord $restData.mail.ToLower() $cognome_idx $snNorm
    }

### givenName
    if ($null -eq $sqlData.ItemArray[$nome_idx]) { $sqlData.ItemArray[$nome_idx] = "" }
    if ($restData.givenName.ToLower() -ne $sqlData.ItemArray[$nome_idx].ToLower())
    {
        $differ = $true
        $givenNameNorm = (Get-Culture).TextInfo.ToTitleCase("$($restData.givenName.ToLower())")
        updateRecord $restData.mail.ToLower() $nome_idx $givenNameNorm
    }

<#=========================================================================================================================#>
<#
### mail
    if ($restData.mail.ToLower() -ne $sqlData.ItemArray[$mail_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $mail_idx $samAccountName
    }
#>
<#=========================================================================================================================#>

<# TBD xref
Le funzioni saranno abilitate dopo l'aggiornamento della REST che dovra' fornire i valori numerici oltre che le stringhe
per: REPARTO, SQUADRA, DIVISIONE, MANSIONE, UNITALOCALE e UNITAPRODUTTIVA
n.b. abilitare anche il blocco di funzioni xref precedenti

### id_reparto
    $id_reparto = xrefReparto $restData.department.ToLower()

    if ($id_reparto -ne $sqlData.ItemArray[$id_reparto_idx])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $id_reparto_idx  $id_reparto
    }

### id_squadra
    $id_squadra = xrefSquadra $restData.description.ToLower()

    if ($id_squadra -ne $sqlData.ItemArray[$id_squadra_idx])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $id_squadra_idx $id_squadra
    }

### id_divisione
    $id_divisione = xrefDivisione $restData.office.ToLower()

    if ($id_divisione -ne $sqlData.ItemArray[$id_divisione_idx])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $id_divisione_idx $id_divisione
    }

### id_mansione
    $id_mansione = xrefDivisione $restData.jobTitle.ToLower()

    if ($id_mansione -ne $sqlData.ItemArray[$id_mansione_idx])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $id_mansione_idx $id_mansione
    }
#>

### codBu
    if ($restData.codBu -ne $sqlData.ItemArray[$codBU_idx])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codBU_idx $restData.codBu
    }

### manager
    if ($null -eq $sqlData.ItemArray[$codRespStringa_idx]) { $sqlData.ItemArray[$codRespStringa_idx] = "" }
    if ($restData.manager.ToLower() -ne $sqlData.ItemArray[$codRespStringa_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codRespStringa_idx $restData.manager
    }

### samResp
    if ($null -eq $restData.mailDelResponsabile) { $restData.mailDelResponsabile = "" }
    $nameDotSurname = $restData.mailDelResponsabile.Split("@")
    $name,$surname = $nameDotSurname[0].Split(".").ToLower()
    $samAccountName = "$($surname)_$($name)"

    <###
                        Add anomalies management
    ###>

    if ($samAccountName -ne $sqlData.ItemArray[$samResp_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $samResp_idx $samAccountName
    }

<#
Le funzioni saranno abilitate dopo l'aggiornamento della REST che dovra' fornire i valori numerici
per: codAzResp e codDipresp

### codAzResp
    $SqlCommand = "SELECT [codAzResp] FROM [dipendenti].[test].[dipendentiAD] WHERE [mail] = '$($restData.mail)'"
    logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    $SqlDataset = execSqlCommand $SqlCommand
    $codAzRespOld = $SqlDataset.Tables[0].Rows[0].ItemArray[0]
    if ($null -ne $codAzRespOld)
    {
        logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
    }
    $codAzRespNew = $restData.codAzResp

    if ($codAzRespNew -ne $codAzRespOld)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codAzResp_idx $codAzRespNew
        logger -Message "$($restData.mail.ToLower()) - old codAzResp: $($codAzRespOld), new codAzResp: $($codAzRespNew)" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }

### codDipResp
    $SqlCommand = "SELECT [codAzResp] FROM [dipendenti].[test].[dipendentiAD] WHERE [mail] = '$($restData.mail)'"
    logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    $SqlDataset = execSqlCommand $SqlCommand
    $codDipRespOld = $SqlDataset.Tables[0].Rows[0].ItemArray[0]
    if ($null -ne $codAzRespOld)
    {
        logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$warningIdx]
    }

    $codDipRespNew = $restData.codDipResp

    if ($codDipRespNew -ne $codDipRespOld)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codDipResp_idx $codDipRespNew
        logger -Message "$($restData.mail.ToLower()) - old codAzResp: $($codAzRespOld), new codAzResp: $($codAzRespNew)" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }
#>

### id_avatar: TBD

### dataAssunzione: TBD

### dataNascita: TBD

### inquadramento: TBD

<# 
Le funzioni saranno abilitate dopo l'aggiornamento della REST che dovra' fornire i valori numerici oltre che le stringhe
per: UNITALOCALE e UNITAPRODUTTIVA.

### unitaLocale
$codUL = xrefUnitaLocale $restData.l.ToLower()
if ($codUL -ne -1)
{
    if ($codUL -ne $unitaLocali.Tables[0].Rows[$sqlData.ItemArray[$unitaLocale_idx]].ItemArray[1])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $unitaLocale_idx $codUL
    }
}

### unitaProduttiva
$codUP = xrefUnitaProduttiva $restData.streetAddress.ToLower()
if ($codUP -ne -1)
{
    if ($codUP -ne $unitaProduttive.Tables[0].Rows[$sqlData.ItemArray[$unitaProduttiva_idx]].ItemArray[1])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $unitaProduttiva_idx $restData.streetAddress
    }
}
#>

### cellulare
if ($restData.mobile -ne $sqlData.ItemArray[$cellulare_idx])
{
    $differ = $true
    updateRecord $restData.mail.ToLower() $cellulare_idx $restData.mobile
}

### interno
if ($restData.telephoneNumber -ne $sqlData.ItemArray[$interno_idx])
{
    $differ = $true
    updateRecord $restData.mail.ToLower() $interno_idx $restData.telephoneNumber
}

### sede
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$sede_idx]
    if ($restData.streetAddress.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $sede_idx $restData.streetAddress
    }
    
### Azienda
    if ($null -eq $sqlData.ItemArray[$Azienda_idx]) { $sqlData.ItemArray[$Azienda_idx] = " " }
    if ($restData.company.ToLower() -ne $sqlData.ItemArray[$Azienda_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $Azienda_idx $restData.company
    }

### Reparto
    if ($null -eq $sqlData.ItemArray[$Reparto_idx]) { $sqlData.ItemArray[$Reparto_idx] = " " }
    if ($restData.department.ToLower() -ne $sqlData.ItemArray[$Reparto_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $Reparto_idx $restData.department
    }

### Squadra
    if ($null -eq $sqlData.ItemArray[$Squadra_idx]) { $sqlData.ItemArray[$Squadra_idx] = " " }
    if ($restData.description.ToLower() -ne $sqlData.ItemArray[$Squadra_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $Squadra_idx $restData.description
    }

### Divisione
    if ($null -eq $sqlData.ItemArray[$Divisione_idx]) { $sqlData.ItemArray[$Divisione_idx] = " " }
    if ($restData.office.ToLower() -ne $sqlData.ItemArray[$Divisione_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $Divisione_idx $restData.office
    }

### Mansione
    if ($null -eq $sqlData.ItemArray[$Mansione_idx]) { $sqlData.ItemArray[$Mansione_idx] = " " }
    if ($restData.jobTitle.ToLower() -ne $sqlData.ItemArray[$Mansione_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $Mansione_idx $restData.jobTitle
    }

### Thumbnailphoto: TBD

### customAttribute6
    if ($null -eq $sqlData.ItemArray[$customAttribute6_idx]) { $sqlData.ItemArray[$customAttribute6_idx] = " " }
    if ($restData.customAttribute6.ToLower() -ne $sqlData.ItemArray[$customAttribute6_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $customAttribute6_idx $restData.customAttribute6
    }

### gruppoSPOwner
    if ($null -eq $sqlData.ItemArray[$gruppoSPOwner_idx]) { $sqlData.ItemArray[$gruppoSPOwner_idx] = " " }
    if ($restData.gruppoSPOwner.ToLower() -ne $sqlData.ItemArray[$gruppoSPOwner_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $gruppoSPOwner_idx $restData.gruppoSPOwner
    }

### gruppoSPReader
    if ($null -eq $sqlData.ItemArray[$gruppoSPReader_idx]) { $sqlData.ItemArray[$gruppoSPReader_idx]= "" }
    if ($restData.gruppoSPReader.ToLower() -ne $sqlData.ItemArray[$gruppoSPReader_idx].ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $gruppoSPReader_idx $restData.gruppoSPReader
    }

### dataCreazione
    if ($differ)
    {
        $creationDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        updateRecord $restData.mail.ToLower() $dataCreazione_idx $creationDate
    }
    else
    {
        logger -Message "[NOT CHANGED] $($sqlData.ItemArray[$i].mail.ToLower())" -Level $severity[$infoIdx] -Path $changeLog[$samedIdx]
    }

    logger -Message "*** End recordsDiffer" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function multipleRecords ($sqlDatas)
{
    logger -Message "*** Begin multipleRecords" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    foreach ($sqlData in $sqlDatas)
    {
        logSQLData $sqlData
        logger -Message "================================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    };

    logger -Message "*** End multipleRecords" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}
function readEmployeeData ($restDataData_fn)
{
    logger -Message "*** Begin readEmployeeData" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    [xml]$restDataData = Get-Content $restDataData_fn

    logger -Message "*** End readEmployeeData" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    
    return $restDataData
}

<# TBD xref
Le funzioni saranno abilitate dopo l'aggiornamento della REST che dovra' fornire i valori numerici oltre che le stringhe
per: REPARTO, SQUADRA, DIVISIONE, MANSIONE, UNITALOCALE e UNITAPRODUTTIVA.
n.b. abilitare anche il blocco xref nel seguito

function xrefReparto ($nomeReparto)
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

function xrefSquadra ($nomeSquadra)
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

function xrefDivisione ($nomeDivisione)
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

function xrefMansione ($nomeMansione)
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
    
    return $id_mansione
}

function xrefUnitaLocale ($nomeUL)
{
    $codUL = -1
    foreach($unitaLocale in $unitaLocali.Tables[0].Rows)
    {
        if ($nomeUL -eq $unitaLocale.Item('unitaLocale').ToLower())
        {
            $codUL = $unitaLocale.Item('codUL')
            break
        }
    }
    
    return $codUL
}

function xrefUnitaProduttiva ($nomeUP)
{
    $codUP = -1
    foreach($unitaProduttiva in $unitaProduttive.Tables[0].Rows)
    {
        if ($nomeUP -eq $unitaProduttiva.Item('filiale').ToLower())
        {
            $codUP = $divisione.Item('codFiliale')
            break
        }
    }
    
    return $codUP
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

    return $SqlDataSet
}

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

function loadAncillaryTables
{
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

<# Load cross reference tables #>
loadAncillaryTables

<# Get updated data #>
logger -Message "Loading REST data" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

#$uri = "http://10.177.111.32:8080/Employee/getXMLForExcel?caller=intranet&firma=E2E38FDC09A1CAEF479F96E887D049DB&requestId=1"
#[xml]$restDataData = Invoke-RestMethod -Method Post -ContentType "text/xml" -uri $uri

<# Local data will be used until exceptions are corrected by HR #>
[xml]$restDataData = readEmployeeData "D:\Users\furio\Workspace\Infodip\registryUpd\response_1579793785266.xml"

$restDatasCnt = 0

foreach($restData in $restDataData.Risposta.xmlForExcel.xmlForExcel) {
    $restDatasCnt++
    logger -Message "=== Working on record #$($restDatasCnt): $($restData.mail) =============================================================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    <# Check user already in DB #>
    $SqlCommand = "SELECT * FROM [dipendenti].[test].[dipendentiAD] WHERE [mail] = '$($restData.mail)'"
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
            addRecord $restData;
            break
        }
        1 {
            logger -Message "Record found. Checking for changes." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
            recordsDiffer $restData $SqlDataset.Tables[0].Rows[0]
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

delRemovedRecords $restData $SqlDataset.Tables[0].Rows[0]

archiveLogs $LOGPATH $LOGEXT
trimLogsArchives $LOGPATH $LOGEXT $RETAINS

