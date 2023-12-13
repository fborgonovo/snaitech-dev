SELECT
	 UPPER(RIGHT(LEFT(de.[mail], CHARINDEX('@', de.[mail]) - 1), LEN(LEFT(de.[mail], CHARINDEX('@', de.[mail]) - 1)) - CHARINDEX('.', de.[mail])))+'_'+UPPER(LEFT(LEFT(de.[mail], CHARINDEX('@', de.[mail]) - 1), CHARINDEX('.', de.[mail]) - 1)) AS samAccountName
	,de.[company] AS 'Company'
	,de.[sn] AS 'sn'
	,de.[givenName] AS 'givenName'
	,LOWER(de.[mail]) AS 'mail'
	,de.[department] AS 'Department'
	,de.[description] AS 'Description'
	,de.[office] AS 'Office'
	,de.[jobTitle] AS 'Title'
	,de.[manager] AS 'Manager'
	,de.[l] AS 'l'
	,TRIM(SUBSTRING(de.[streetAddress], CHARINDEX('-', de.[streetAddress])+1, LEN(de.[streetAddress])-CHARINDEX('-', de.[streetAddress]))) AS 'unitaProduttiva'
	,(CASE WHEN de.[mobile] IS NULL THEN '' ELSE de.[mobile] END) AS 'mobile'
	,de.[customAttribute6] AS 'Custom attribute 6'
	,(CASE WHEN de.[gruppoSPOwner] IS NULL THEN '' ELSE de.[gruppoSPOwner]+'_owner' END) AS 'gruppoSPOwner'
	,(CASE WHEN de.[gruppoSPReader] IS NULL THEN '' ELSE de.[gruppoSPReader]+'_reader' END) AS 'gruppoSPReader'
INTO
	[dipendenti].[test].[estrazionePerAD]
FROM
	[dipendenti].[import].[export_dipendenti_2] AS de