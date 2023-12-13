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
            codBU

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
    v0.4 :  Debug
    v0.5 :  Added numeric code from c.a. 6
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

$today = Get-Date -Format "yyyyMMdd-HHmm"

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
    logger -Message "company:             $($restData.company)"             -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "sn:                  $($restData.sn)"                  -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "givenName:           $($restData.givenName)"           -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "mail:                $($restData.mail)"                -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "department:          $($restData.department)"          -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "description:         $($restData.description)"         -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "office:              $($restData.office)"              -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "jobTitle:            $($restData.jobTitle)"            -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "manager:             $($restData.manager)"             -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "l:                   $($restData.l)"                   -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "streetAddress:       $($restData.streetAddress)"       -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "telephoneNumber:     $($restData.telephoneNumber)"     -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "mobile:              $($restData.mobile)"              -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "thumbnailphoto:      $($restData.thumbnailphoto)"      -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "customAttribute6:    $($restData.customAttribute6)"    -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "gruppoSPOwner:       $($restData.gruppoSPOwner)"       -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "gruppoSPReader:      $($restData.gruppoSPReader)"      -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "mailDelResponsabile: $($restData.mailDelResponsabile)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codAzienda:          $($restData.codAzienda)"          -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codDipendente:       $($restData.codDipendente)"       -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codBU:               $($restData.codBU)"               -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    
### Split employee data from customattribute6 - 
    $_codAzienda, `
    $_codDipendente, `
    $id_reparto, `
    $id_squadra, `
    $id_divisione, `
    $id_mansione, `
    $_codBU, `
    $codAzResp, `
    $codDipResp, `
    $id_avatar, `
    $data_assunzione, `
    $data_nascita, `
    $inquadramento =
    $restData.customAttribute6.Split('|')

    logger -Message "codAzienda:        $($codAzienda)"        -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codDipendente:     $($codDipendente)"     -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "id_reparto:        $($id_reparto)"        -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "id_squadra:        $($id_squadra)"        -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "id_divisione:      $($id_divisione)"      -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "id_mansione:       $($id_mansione)"       -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codBU:             $($codBU)"             -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codAzResp:         $($codAzResp)"         -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codDipResp:        $($codDipResp)"        -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "id_avatar:         $($id_avatar)"         -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "data_assunzione:   $($data_assunzione)"   -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "data_nascita:      $($data_nascita)"      -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "inquadramento:     $($inquadramento)"     -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
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

function updateRecord ($sqlDataKey, $sqlColumnName_idx, $sqlDataNewValue, $oldValue)
{
    logger -Message "*** Begin updateRecord: $($sqlDataKey) - $($sqlColumnsName[$($sqlColumnName_idx)])" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    if ($oldValue -eq '')
    {
        logger -Message "[UPDATED] $($sqlDataKey) - $($sqlColumnsName[$sqlColumnName_idx]): '$($sqlDataNewValue)'" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }
    else
    {
        logger -Message "[UPDATED] $($sqlDataKey) - $($sqlColumnsName[$sqlColumnName_idx]): '$($sqlDataNewValue)' - Old value: '$($oldValue)'" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }

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
        return ''
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

### Split employee data from customattribute6
    $codAzienda, `
    $codDipendente, `
    $id_reparto, `
    $id_squadra, `
    $id_divisione, `
    $id_mansione, `
    $codBU, `
    $codAzResp, `
    $codDipResp, `
    $id_avatar, `
    $data_assunzione, `
    $data_nascita, `
    $inquadramento =
    $restData.customAttribute6.Split('|')

    logger -Message "== DB data =====================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logSQLData $sqlData

### samAccountName
    $nameDotSurname = $restData.mail.Split("@")
    $name,$surname = $nameDotSurname[0].Split(".").ToLower()
    $samAccountName = "$($surname)_$($name)"

<###
            Add anomalies management: lenght, multiple names/surnames etc.
###>

    $sqlField = sqlFieldFixed $sqlData.ItemArray[$samAccountName_idx]
    if ($samAccountName -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $samAccountName_idx $samAccountName $sqlField
    }

### mailDelResponsabile
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$mailResp_idx]
    if ($restData.mailDelResponsabile.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $mailResp_idx $restData.mailDelResponsabile.ToLower() $sqlField
    }

### codAzienda
    if ($restData.codAzienda -ne $sqlData.ItemArray[$codAzienda_idx])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codAzienda_idx $restData.codAzienda $sqlData.ItemArray[$codAzienda_idx]
    }

### codDipendente
    if ($restData.codDipendente -ne $sqlData.ItemArray[$codDipendente_idx])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codDipendente_idx $restData.codDipendente $sqlData.ItemArray[$codDipendente_idx]
    }

### sn
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$cognome_idx]
    if ($restData.sn.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        $snNorm = (Get-Culture).TextInfo.ToTitleCase("$($restData.sn.ToLower())")
        updateRecord $restData.mail.ToLower() $cognome_idx $snNorm $sqlField
    }

### givenName
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$nome_idx]
    if ($restData.givenName.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        $givenNameNorm = (Get-Culture).TextInfo.ToTitleCase("$($restData.givenName.ToLower())")
        updateRecord $restData.mail.ToLower() $nome_idx $givenNameNorm $sqlField
    }

### id_reparto
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$id_reparto_idx]
    if ($id_reparto -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $id_reparto_idx $id_reparto $sqlField
    }

### id_squadra
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$id_squadra_idx]
    if ($id_squadra -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $id_squadra_idx $id_squadra $sqlField
    }

### id_divisione
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$id_divisione_idx]
    if ($id_divisione -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $id_divisione_idx $id_divisione $sqlField
    }

### id_mansione
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$id_mansione_idx]
    if ($id_mansione -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $id_mansione_idx $id_mansione $sqlField
    }

### codBU
    if ($restData.codBU -ne $sqlData.ItemArray[$codBU_idx])
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codBU_idx $restData.codBU $sqlData.ItemArray[$codBU_idx]
    }

### manager
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$codRespStringa_idx]
    if ($restData.manager.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codRespStringa_idx $restData.manager $sqlField
    }

### samResp
    $nameDotSurname = $restData.mailDelResponsabile.Split("@")
    $name,$surname = $nameDotSurname[0].Split(".").ToLower()
    $samResp = "$($surname)_$($name)"

<###
        Add anomalies management: lenght, multiple names/surnames etc.
###>

    $sqlField = sqlFieldFixed $sqlData.ItemArray[$samResp_idx]

    if ($samResp -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $samResp_idx $samRest $sqlField
    }
    
### codAzResp
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$codAzResp_idx]
    if ($codAzResp -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codAzResp_idx $codAzResp $sqlField
    }

### codDipResp
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$codDipResp_idx]
    if ($codDipResp -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codDipResp_idx $codDipResp $sqlField
    }

### id_avatar: TBD
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$id_avatar_idx]
    if ($id_avatar -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $id_avatar_idx $id_avatar $sqlField
    }

### dataAssunzione: TBD
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$dataAssunzione_idx]
    if ($data_assunzione -ne $sqlField.Date.ToString().Substring(0,10))
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $dataAssunzione_idx $data_assunzione $sqlField
    }

### dataNascita: TBD
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$dataNascita_idx]
    if ($data_nascita -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $dataNascita_idx $data_nascita $sqlField
    }

### inquadramento: TBD
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$inquadramento_idx]
    if ($inquadramento -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $inquadramento_idx $inquadramento $sqlField
    }

<#  Obsoletes

### unitaLocale

### unitaProduttiva

#>

### cellulare
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$cellulare_idx]
    if ($restData.mobile -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $cellulare_idx $restData.mobile $sqlField
    }

### interno
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$interno_idx]
    if ($restData.telephoneNumber -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $interno_idx $restData.telephoneNumber $sqlField
    }

### sede
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$sede_idx]
    if ($restData.streetAddress.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $sede_idx $restData.streetAddress $sqlField
    }
    
### Azienda
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$Azienda_idx]
    if ($restData.company.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $Azienda_idx $restData.company $sqlField
    }

### Reparto
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$Reparto_idx]
    if ($restData.department.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $Reparto_idx $restData.department $sqlField
    }

### Squadra
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$Squadra_idx]
    if ($restData.description.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $Squadra_idx $restData.description $sqlField
    }

### Divisione
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$Divisione_idx]
    if ($restData.office.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $Divisione_idx $restData.office $sqlField
    }

### Mansione
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$Mansione_idx]
    if ($restData.jobTitle.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $Mansione_idx $restData.jobTitle $sqlField
    }

### Thumbnailphoto: TBD

### customAttribute6
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$customAttribute6_idx]
    if ($restData.customAttribute6.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $customAttribute6_idx $restData.customAttribute6 $sqlField
    }

### gruppoSPOwner
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$gruppoSPOwner_idx]
    if ($restData.gruppoSPOwner.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $gruppoSPOwner_idx $restData.gruppoSPOwner $sqlField
    }

### gruppoSPReader
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$gruppoSPReader_idx]
    if ($restData.gruppoSPReader.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $gruppoSPReader_idx $restData.gruppoSPReader $sqlField
    }

### dataCreazione
    $sqlDataCreazione = sqlFieldFixed $sqlData.ItemArray[$dataCreazione_idx]

    if ($differ)
    {
        $creationDate = Get-Date -Format "dd-MM-yyyy HH.mm:ss"
        updateRecord $restData.mail.ToLower() $dataCreazione_idx $creationDate $sqlDataCreazione
        logger -Message "-------------------------------------------------------------" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }
    else
    {
        logger -Message "[NOT CHANGED] $($sqlData.ItemArray[$i].mail.ToLower())" -Level $severity[$infoIdx] -Path $changeLog[$sameIdx]
        updateRecord $restData.mail.ToLower() $dataCreazione_idx $sqlDataCreazione
        logger -Message "-------------------------------------------------------------" -Level $severity[$infoIdx] -Path $changeLog[$sameIdx]
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
#logger -Message "Loading REST data" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

#$uri = "http://10.177.111.32:8080/Employee/getXMLForExcel?caller=intranet&firma=E2E38FDC09A1CAEF479F96E887D049DB&requestId=1"
#[xml]$restDataData = Invoke-RestMethod -Method Post -ContentType "text/xml" -uri $uri

logger -Message "Loading frozen (20200204) REST data" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
<# Local data will be used until exceptions are corrected by HR #>
#[xml]$restDataData = readEmployeeData "D:\Users\furio\Workspace\Infodip\registryUpd\response_1579793785266.xml"
[xml]$restDataData = readEmployeeData "D:\Users\furio\Workspace\Infodip\registryUpd\response_1580816276823.xml"

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
}

delRemovedRecords $restData $SqlDataset.Tables[0].Rows[0]

archiveLogs $LOGPATH $LOGEXT
trimLogsArchives $LOGPATH $LOGEXT $RETAINS

