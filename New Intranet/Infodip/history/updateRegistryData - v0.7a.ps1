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
    v0.6 :  Debug
    v0.7 :  data_assunzione field must be '0'
            Employee data field are not to be checked
            SP groups must be checked using the leght of the data
            from the relative SQL
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
. ".\\logger.ps1"

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

$LOGPATH = '.\\logs'
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

    $data_assunzione = ''

    $ca6 = (
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
        $inquadramento
    ) -join '|'

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
    logger -Message "customAttribute6:    $($ca6)"                          -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "gruppoSPOwner:       $($restData.gruppoSPOwner)"       -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "gruppoSPReader:      $($restData.gruppoSPReader)"      -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "mailDelResponsabile: $($restData.mailDelResponsabile)" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codAzienda:          $($restData.codAzienda)"          -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codDipendente:       $($restData.codDipendente)"       -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codBU:               $($restData.codBU)"               -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logger -Message "codAzienda:          $($codAzienda)"                   -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codDipendente:       $($codDipendente)"                -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "id_reparto:          $($id_reparto)"                   -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "id_squadra:          $($id_squadra)"                   -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "id_divisione:        $($id_divisione)"                 -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "id_mansione:         $($id_mansione)"                  -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codBU:               $($codBU)"                        -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codAzResp:           $($codAzResp)"                    -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "codDipResp:          $($codDipResp)"                   -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "id_avatar:           $($id_avatar)"                    -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "data_assunzione:     $($data_assunzione)"              -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "data_nascita:        $($data_nascita)"                 -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    logger -Message "inquadramento:       $($inquadramento)"                -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function logSQLData ($sqlData, $logIdx)
{
    for ($i=0; $i -lt $sqlData.ItemArray.length; $i++) {
        logger -Message "$($sqlData.Table.Columns[$i]): $($sqlData.ItemArray[$i])" -Level $severity[$infoIdx] -Path $severityFile[$logIdx]
    }
}

function escapeApices($str)
{
    return $str.Replace("'", "#")
}

function addRecord ($restData)
{
    logger -Message "*** Begin addRecord" -Level $severity[$infoIdx] -Path $changeLog[$addedIdx]

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

    $data_assunzione = 'NULL'
    $data_nascita = 'NULL'

    $samAccountName = checkSamExceptions $restData.mail
    $samResp = checkSamExceptions $restData.mailDelResponsabile

    $sn = escapeApices $restData.sn
    $givenName = escapeApices $restData.givenName
    $manager = escapeApices $restData.manager
    $streetAddress = escapeApices $restData.streetAddress
    $department = escapeApices $restData.department
    $description = escapeApices $restData.description
    $office = escapeApices $restData.office
    $jobTitle = escapeApices $restData.jobTitle

    $SqlCommand =
@"
        INSERT INTO
            $($DIPENDENTIAD_TABLE)
        VALUES (
            '$($samAccountName)',
            '$($today)',
            '$($restData.mailDelResponsabile)',
            $($restData.codAzienda),
            $($restData.codDipendente),
            '$sn',
            '$($givenName)',
            '$($restData.mail)',
            $($id_reparto),
            $($id_squadra),
            $($id_divisione),
            $($id_mansione),
            $($restData.codBU),
            '$($manager)',
            '$($samResp)',
            $($codAzResp),
            $($codDipResp),
            '$($id_avatar)',
            '$($data_assunzione)',
            '$($data_nascita)',
            '$($inquadramento)',
            0,
            0,
            '$($restData.mobile)',
            '$($restData.telephoneNumber)',
            '$($streetAddress)',
            '$($restData.company)',
            '$($department)',
            '$($description)',
            '$($office)',
            '$($jobTitle)',
            '$($restData.thumbnailphoto)',
            '$($restData.customAttribute6)',
            '$($restData.gruppoSPOwner)',
            '$($restData.gruppoSPReader)'
        )
"@

	logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $changeLog[$addedIdx]
<# ###DEBUG###
    $SqlDataset = execSqlCommand $SqlCommand
	
	if ([string]::IsNullOrEmpty($SqlDataset))
	{
        logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$errorIdx]
        logger -Message "                $($SqlCommand)" -Level $severity[$infoIdx] -Path $severityFile[$errorIdx]
	}
	else
	{
        logger -Message "-------------------------------------------------------------" -Level $severity[$infoIdx] -Path $changeLog[$addedIdx]
        logger -Message "[ADDED] $($restData.mail)" -Level $severity[$infoIdx] -Path $changeLog[$addedIdx]
        logger -Message "-------------------------------------------------------------" -Level $severity[$infoIdx] -Path $changeLog[$addedIdx]
        logger -Message "        $($SqlCommand)" -Level $severity[$infoIdx] -Path $changeLog[$addedIdx]
    }
#>
    logger -Message "*** End addRecord" -Level $severity[$infoIdx] -Path $changeLog[$addedIdx]
}

function updateRecord ($sqlDataKey, $sqlColumnName_idx, $NewValue, $oldValue)
{
    logger -Message "*** Begin updateRecord: $($sqlDataKey) - $($sqlColumnsName[$($sqlColumnName_idx)])" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]

#    if ($sqlDataKey -eq 'lorenzo.stoppini@snaitech.it')
    if ($NewValue -eq "''")
    {
        $NewValue = 'NULL'
    }
    $SqlCommand = "UPDATE $($DIPENDENTIAD_TABLE) SET [$($sqlColumnsName[$($sqlColumnName_idx)])] = $($NewValue) WHERE [mail] = '$sqlDataKey'"
	
	logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    
<#  ###DEBUG###
    $SqlDataset = execSqlCommand $SqlCommand
	
    logger -Message "-------------------------------------------------------------" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]

    if ([string]::IsNullOrEmpty($SqlDataset))
	{
		logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$errorIdx]
	}
	else
	{
        logger -Message "[UPDATED] $($sqlDataKey)" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }
    if ($oldValue -eq '')
    {
        logger -Message "[UPDATED] $($sqlDataKey) - $($sqlColumnsName[$sqlColumnName_idx]): '$($NewValue)'" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }
    else
    {
        logger -Message "[UPDATED] $($sqlDataKey) - $($sqlColumnsName[$sqlColumnName_idx]): '$($NewValue)' - Old value: '$($oldValue)'" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }
#>
    logger -Message "*** End updateRecord" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
}

function delRecord ($sqlDataKey)
{
    logger -Message "*** Begin delRecord" -Level $severity[$infoIdx] -Path $changeLog[$deletedIdx]

	$SqlCommand = "DELETE FROM $($DIPENDENTIAD_TABLE) WHERE [mail] = '$sqlDataKey'"
	
	logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $changeLog[$deletedIdx]
	
<#  ###DEBUG###

    $SqlDataset = execSqlCommand $SqlCommand
	
	if ([string]::IsNullOrEmpty($SqlDataset))
	{
		logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$errorIdx]
	}
	else
	{
        logger -Message "-------------------------------------------------------------" -Level $severity[$infoIdx] -Path $changeLog[$deletedIdx]
        logger -Message "[DELETED] $($sqlDataKey)" -Level $severity[$infoIdx] -Path $changeLog[$deletedIdx]
    }
#>
    logger -Message "*** End delRecord" -Level $severity[$infoIdx] -Path $changeLog[$deletedIdx]
}

function delRemovedRecords ([xml]$restData)
{
    logger -Message "*** Begin delRemovedRecords" -Level $severity[$infoIdx] -Path $changeLog[$deletedIdx]

    $cnt = 0
	$del = 0
	
	$SqlCommand = "SELECT * FROM $($DIPENDENTIAD_TABLE)"
	
	logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $changeLog[$deletedIdx]

    $SqlDataset = execSqlCommand $SqlCommand

    $dipendentiAD = $SqlDataset.Tables[0]
	
	if ([string]::IsNullOrEmpty($SqlDataset))
	{
		logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$errorIdx]
	}
	else
	{
		foreach ($row in $dipendentiAD) {

            $existingMail = $row.ItemArray[$mail_idx]

            if ($existingMail -is [System.DBNull] -or $existingMail.Trim -eq '') { # Discard meeting rooms and other record without an email
                continue
            }

			Write-Host "Record $($cnt): $($existingMail)"
            $cnt++

            $employeeMail = $restData | Select-XML -XPath "//xmlForExcel/xmlForExcel/mail[text()='$($existingMail)']"

### Temporary patch. Teleippica -> Epiqa
            if ($employeeMail -match "teleippica")
            {
                $employeeMail = $employeeMail.ToLower().Replace("teleippica", "epiqa")
            }
### End patch
            if ($null -eq $employeeMail) {
				delRecord $existingMail
				Write-Host "Delete record #$($del): $($existingMail)"
                $del++
                continue
            }
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

function checkSamExceptions ($mail2check)
{
    $samExceptions = @{
		'DELLOSO_ROSANNA' = 'rosanna.delloso@snaireteitalia.it'
		'DegliAngeli_AnnaMaria' = 'annamaria.degliangeli@areascom.it'
		'DiBona_Nicolo' = 'nicolo.dibona@snaireteitalia.it'
		'GALLO_MARIA' = 'maria.gallo@snaireteitalia.it'
		'PAPADOULIS_OLGA' = 'olga.papadoulis@snaireteitalia.it'
		'PISTOLESI_ANNAMARIA' = 'annamaria.pistolesi@snaireteitalia.it'
		'dejesus_geisatatiana' = 'geisatatiana.dejesus@snaireteitalia.it'
		'dibartolomeo_alessio' = 'alessio.dibartolomeo@snaitech.it'
        'alfredorosario.morelli@snaireteitalia.it' = 'Morelli_Alfredo'
        'antoninogianluca.giaimo@snaitech.it' = 'Giaimo_Gianluca'
        'carmelinapinuccia.favaccio@snaitech.it' = 'FAVACCIO_CARMELINA'
        'carmineivan.morra@snaireteitalia.it' = 'morra_carmine'
        'cinzia.fornillo@snaitech.it' = 'fornillo_vincenza'
        'elena.delcarlo=af@snaitech.it' = 'delcarlo_elena_af'
        'eleonoramaria.vasta@snaireteitalia.it' = 'VASTA_ELEONORA'
        'elisa.ascoli@snaitech.it' = 'ascoli_elisabetta'
        'elisabetageraldine.surd@snaireteitalia.it' = 'surd_elisabeta'
        'emanuele.mattacchioni@snaitech.it' = 'mattacchioni_e'
        'gianfranco.licenziato@snaitech.it' = 'licenziato_gianfranc'
        'giovanna.antuono@snaitech.it' = 'antuono_giovannangela'
        'gisella.tarantino@snaitech.it' = 'tarantino_agata'
        'ivan.dovicolupo@snaitech.it' = 'dovico_ivan'
        'kety.delbino@snaitech.it' = 'delbino_keti'
        'leonardo.cesare@snaitech.it' = 'abude_leonardo'
        'leonardo.corderomatos@snaireteitalia.it' = 'CORDERO_MATOS'
        'luigi.babbini@snaitech.it' = 'babbini_luigino'
        'mariagrazia.tundis@snaitech.it' = 'tundis_mg'
        'massimiliano.tempesta@snaitech.it' = 'tempesta_max'
        'morgan.ricciardi@snaitech.it' = 'MORGAN'
        'natalie.bolanoscorredor@snaireteitalia.it' = 'bolanoscorredor_nata'
        'paola.giusti.lu@areascom.it' = 'GIUSTI.LU_PAOLA'
        'ritaelena.specchia@snaireteitalia.it' = 'SPECCHIA_RITA'
        'roberta.tessandoribernini@snaitech.it' = 'TESSANDORI_ROBERTA'
        'stefano.rossi2@snaitech.it' = 'rossi_stefano'
        'stefano.rossi@snaitech.it' = 'rossi.stefano'
        'ylena.lomagno@snaireteitalia.it' = 'lomagno_ylenia'
    }

    if ($null -eq $mail2check)
    {
        $samAccountName = ''
    }
    else
    {
        $samAccountName = $samExceptions[$mail2check]

        if ($null -eq $samAccountName)
        {
            $nameDotSurname = $mail2check.Split("@")
            $name,$surname = $nameDotSurname[0].Split(".").ToLower()
            $samAccountName = "$($surname)_$($name)"
        }
    }

    return $samAccountName
}

function recordsDiffer ($restData, $sqlData)
{
    logger -Message "*** Begin recordsDiffer" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    $differ = $false

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

    $data_assunzione = ''

    $ca6 = (
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
        $inquadramento
    ) -join '|'

    logger -Message "== REST data ===================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logRESTData $restData

    logger -Message "== DB data =====================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    logSQLData $sqlData $infoIdx

### samAccountName

    $samAccountName = checkSamExceptions $restData.mail

    $sqlField = sqlFieldFixed $sqlData.ItemArray[$samAccountName_idx]
    if ($samAccountName -ne $sqlField.ToLower())
    {
        $differ = $true
        $newValue = "'"+$($samAccountName)+"'"
        updateRecord $restData.mail.ToLower() $samAccountName_idx $($newValue) $sqlField
    }

### mailDelResponsabile
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$mailResp_idx]
    if ($restData.mailDelResponsabile.ToLower() -ne $sqlField.ToLower() -and $sqlData.ItemArray[$mailResp_idx] -ne "")
    {
        $differ = $true
        $newValue = "'"+$($restData.mailDelResponsabile).ToLower()+"'"
        updateRecord $restData.mail.ToLower() $mailResp_idx $newValue $sqlField
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
        $newValue = "'"+$($snNorm)+"'"
        updateRecord $restData.mail.ToLower() $cognome_idx $newValue $sqlField
    }

### givenName
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$nome_idx]
    if ($restData.givenName.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        $givenNameNorm = (Get-Culture).TextInfo.ToTitleCase("$($restData.givenName.ToLower())")
        $newValue = "'"+$($givenNameNorm)+"'"
        updateRecord $restData.mail.ToLower() $nome_idx $newValue $sqlField
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
    if ($restData.manager.ToLower() -ne $sqlField.ToLower() -and $sqlField -ne "")
    {
        $differ = $true
        $newValue = "'"+$($restData.manager)+"'"
        updateRecord $restData.mail.ToLower() $codRespStringa_idx $newValue $sqlField
    }

### samResp
    $samResp = checkSamExceptions $restData.mailDelResponsabile

    $sqlField = sqlFieldFixed $sqlData.ItemArray[$samResp_idx]

    if ($samResp -ne $sqlField.ToLower() -and $sqlField -ne "")
    {
        $differ = $true
        $newValue = "'"+$($samResp)+"'"
        updateRecord $restData.mail.ToLower() $samResp_idx $newValue $sqlField
    }
    
### codAzResp
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$codAzResp_idx]
    if ($codAzResp -ne $sqlField -and $sqlField -ne "")
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codAzResp_idx $codAzResp $sqlField
    }

### codDipResp
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$codDipResp_idx]
    if ($codDipResp -ne $sqlField -and $sqlField -ne "")
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $codDipResp_idx $codDipResp $sqlField
    }

### id_avatar: TBD
#    $sqlField = sqlFieldFixed $sqlData.ItemArray[$id_avatar_idx]
    $sqlField = "0"
    
    if ($id_avatar -ne $sqlField)
    {
        $differ = $true
        $newValue = "'"+$($id_avatar)+"'"
        updateRecord $restData.mail.ToLower() $id_avatar_idx $newValue $sqlField
    }

### dataAssunzione: TBD
<#
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$dataAssunzione_idx]
    if ([string]::IsNullOrEmpty($sqlField))
#    if ($sqlField.Date -is [System.DBNull])
    {
        $sqlField.Date = ' '
    }
###
### TBD: CHECK FOR NULL VALUES
###
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
#>
### inquadramento: TBD`
<#
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$inquadramento_idx]
    if ($inquadramento -ne $sqlField)
    {
        $differ = $true
        updateRecord $restData.mail.ToLower() $inquadramento_idx $inquadramento $sqlField
    }
#>
<#  Obsoletes

### unitaLocale

### unitaProduttiva

#>

### cellulare
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$cellulare_idx]
    $restField = $restData.mobile.Replace('/', '-')
    if ($restField -ne $sqlField)
    {
        $differ = $true
        $newValue = "'"+$($restField)+"'"
        updateRecord $restData.mail.ToLower() $cellulare_idx $newValue $sqlField
    }

### interno
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$interno_idx]
    if ($restData.telephoneNumber -ne $sqlField)
    {
        $differ = $true
        $newValue = "'"+$($restData.telephoneNumber)+"'"
        updateRecord $restData.mail.ToLower() $interno_idx $newValue $sqlField
    }

### sede
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$sede_idx]
    if ($restData.streetAddress.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        $newValue = escapeApices $restData.streetAddress
        $newValue = "'"+$($newValue)+"'"
        updateRecord $restData.mail.ToLower() $sede_idx $newValue $sqlField
    }

### Azienda
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$Azienda_idx]
    if ($restData.company.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        $newValue = "'"+$($restData.company)+"'"
        updateRecord $restData.mail.ToLower() $Azienda_idx $newValue $sqlField
    }

### Reparto
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$Reparto_idx]
    if ($restData.department.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        $newValue = "'"+$($restData.department)+"'"
        updateRecord $restData.mail.ToLower() $Reparto_idx $newValue $sqlField
    }

### Squadra
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$Squadra_idx]
    if ($restData.description.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        $newValue = "'"+$($restData.description)+"'"
        updateRecord $restData.mail.ToLower() $Squadra_idx $newValue $sqlField
    }

### Divisione
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$Divisione_idx]
    if ($restData.office.ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        $newValue = "'"+$($restData.office)+"'"
        updateRecord $restData.mail.ToLower() $Divisione_idx $newValue $sqlField
    }

### Mansione
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$Mansione_idx]
    if ($restData.jobTitle.Trim().ToLower() -ne $sqlField.ToLower())
    {
        $differ = $true
        $newValue = "'"+$($restData.jobTitle)+"'"
        updateRecord $restData.mail.ToLower() $Mansione_idx $newValue $sqlField
    }

### Thumbnailphoto: TBD

### customAttribute6
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$customAttribute6_idx]
    if ($ca6 -ne $sqlField.ToLower())
    {
        $differ = $true
        $newValue = "'"+$($ca6)+"'"
        updateRecord $restData.mail.ToLower() $customAttribute6_idx $newValue $sqlField
    }

### gruppoSPOwner
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$gruppoSPOwner_idx]
#    if ($restData.gruppoSPOwner.ToLower() -ne $sqlField.ToLower())
    if ($restData.gruppoSPOwner -inotmatch $sqlField)
    {
        $differ = $true
        $newValue = "'"+$($restData.gruppoSPOwner)+"'"
        updateRecord $restData.mail.ToLower() $gruppoSPOwner_idx $newValue $sqlField
    }

### gruppoSPReader
    $sqlField = sqlFieldFixed $sqlData.ItemArray[$gruppoSPReader_idx]
#    if ($restData.gruppoSPReader.ToLower() -ne $sqlField.ToLower())
    if ($restData.gruppoSPReader -inotmatch $sqlField)
    {
        $differ = $true
        $newValue = "'"+$($restData.gruppoSPReader)+"'"
        updateRecord $restData.mail.ToLower() $gruppoSPReader_idx $newValue $sqlField
    }

### dataCreazione
    $sqlDataCreazione = sqlFieldFixed $sqlData.ItemArray[$dataCreazione_idx]

    if ($differ)
    {
        $creationDate = Get-Date -Format "dd-MM-yyyy HH.mm:ss"
        $newValue = "'"+$($creationDate)+"'"
        updateRecord $restData.mail.ToLower() $dataCreazione_idx $newValue $sqlDataCreazione
        logger -Message "-------------------------------------------------------------" -Level $severity[$infoIdx] -Path $changeLog[$updatedIdx]
    }
    else
    {
        logger -Message "[NOT CHANGED] $($sqlData.ItemArray[$mail_idx].ToLower())"      -Level $severity[$infoIdx] -Path $changeLog[$sameIdx]
        logger -Message "-------------------------------------------------------------" -Level $severity[$infoIdx] -Path $changeLog[$sameIdx]
    }

    logger -Message "*** End recordsDiffer" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
}

function multipleRecords ($sqlData)
{
    logger -Message "*** Begin multipleRecords" -Level $severity[$infoIdx] -Path $severityFile[$warningIdx]

    foreach ($sqlDatum in $sqlData)
    {
        logSQLData $sqlDatum $warningIdx
        logger -Message "================================================================" -Level $severity[$infoIdx] -Path $severityFile[$warningIdx]
    };

    logger -Message "*** End multipleRecords" -Level $severity[$infoIdx] -Path $severityFile[$warningIdx]
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

function blank2null($restData)
{
    if ($restData.company -eq '')
    {
        $restData.company = 'NULL'
    }
    
    if ($restData.sn -eq '')
    {
        $restData.sn = 'NULL'
    }
    
    if ($restData.givenName -eq '')
    {
        $restData.givenName = 'NULL'
    }
    
    if ($restData.mail -eq '')
    {
        $restData.mail = 'NULL'
    }
    
    if ($restData.department -eq '')
    {
        $restData.department = 'NULL'
    }
    
    if ($restData.description -eq '')
    {
        $restData.description = 'NULL'
    }
    
    if ($restData.office -eq '')
    {
        $restData.office = 'NULL'
    }
    
    if ($restData.jobTitle -eq '')
    {
        $restData.jobTitle = 'NULL'
    }
    
    if ($restData.manager -eq '')
    {
        $restData.manager = 'NULL'
    }
    
    if ($restData.l -eq '')
    {
        $restData.l = 'NULL'
    }
    
    if ($restData.streetAddress -eq '')
    {
        $restData.streetAddress = 'NULL'
    }
    
    if ($restData.telephoneNumber -eq '')
    {
        $restData.telephoneNumber = 'NULL'
    }
    
    if ($restData.mobile -eq '')
    {
        $restData.mobile = 'NULL'
    }
    
    if ($restData.thumbnailphoto -eq '')
    {
        $restData.thumbnailphoto = 'NULL'
    }
    
    if ($restData.customAttribute6 -eq '')
    {
        $restData.customAttribute6 = 'NULL'
    }
    
    if ($restData.gruppoSPOwner -eq '')
    {
        $restData.gruppoSPOwner = 'NULL'
    }
    
    if ($restData.gruppoSPReader -eq '')
    {
        $restData.gruppoSPReader = 'NULL'
    }
    
    if ($restData.mailDelResponsabile -eq '')
    {
        $restData.mailDelResponsabile = 'NULL'
    }
    
    if ($restData.codDipendente -eq '')
    {
        $restData.codDipendente = 'NULL'
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
$Global:DIPENDENTIAD_TABLE = "[dipendenti].[test].[dipendentiAD]"
$Global:UID = 'dipendenti_updater'
$Global:PWD = 'dipendenti_updater!'

<# Load cross reference tables #>
loadAncillaryTables

<# Get updated data #>
logger -Message "Loading REST data" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

$uri = "http://10.177.111.32:8080/Employee/getXMLForExcel?caller=intranet&firma=E2E38FDC09A1CAEF479F96E887D049DB&requestId=1"
[xml]$restDataData = Invoke-RestMethod -Method Post -ContentType "text/xml" -uri $uri

#logger -Message "Loading frozen (20200204 12:38) REST data" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
<# Local data will be used until exceptions are corrected by HR #>
#[xml]$restDataData = readEmployeeData "D:\Users\furio\Workspace\Infodip\registryUpd\response_1579793785266.xml"
#[xml]$restDataData = readEmployeeData "D:\Users\furio\Workspace\Infodip\registryUpd\response_1580816276823.xml"

#================================================
logger -Message "Loading live SQL data" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
$SqlCommand = "SELECT * FROM $($DIPENDENTIAD_TABLE)"
logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
$SqlDataset = execSqlCommand $SqlCommand
if ([string]::IsNullOrEmpty($SqlDataset))
{
    logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$errorIdx]
    exit
}

<#   ###DEBUG###
delRemovedRecords $restDataData
#>

$restDataCnt = 0

foreach($restData in $restDataData.Risposta.xmlForExcel.xmlForExcel) {
    blank2null $restData
### Temporary patch. Teleippica -> Epiqa
    if ($restData.mailDelResponsabile -match "teleippica")
    {
        $restData.mailDelResponsabile = $restData.mailDelResponsabile.ToLower().Replace("teleippica", "epiqa")
    }
    if ($restData.mail -match "teleippica")
    {
        $restData.mail = $restData.mail.ToLower().Replace("teleippica", "epiqa")
    }
    if ($restData.company -match "teleippica")
    {
        $restData.company = $restData.company.ToLower().Replace("teleippica", "Epiqa")
    }
### End patch

    $restDataCnt++
    logger -Message "=== Working on record #$($restDataCnt): $($restData.mail) =============================================================================================" -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]

    <# Check user already in DB #>
    $SqlCommand = "SELECT * FROM $($DIPENDENTIAD_TABLE) WHERE [mail] = '$($restData.mail)'"
    logger -Message "Executing $($SqlCommand) command." -Level $severity[$infoIdx] -Path $severityFile[$infoIdx]
    $SqlDataset = execSqlCommand $SqlCommand

    if ([string]::IsNullOrEmpty($SqlDataset))
    {
        logger -Message "Error executing $($SqlCommand) command." -Level $severity[$warningIdx] -Path $severityFile[$errorIdx]
        break
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
            logger -Message "Multiple records found for: $($restData.mail). Skipping." -Level $severity[$warningIdx] -Path $severityFile[$infoIdx]
            multipleRecords $SqlDataset.Tables[0];
            break
        }
    }
}

archiveLogs $LOGPATH $LOGEXT
trimLogsArchives $LOGPATH $LOGEXT $RETAINS

