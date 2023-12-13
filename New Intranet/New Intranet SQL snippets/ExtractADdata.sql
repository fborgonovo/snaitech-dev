select
	 UPPER(dad.[samAccountName]) AS 'samAccountName'
	,dad.[Azienda]
	,dad.[cognome]
	,dad.[nome]
	,LOWER(dad.[mail]) AS 'mail'
	,dad.[Reparto]
	,dad.[Squadra]
	,dad.[Divisione]
	,dad.[Mansione]
	,dad.[codRespStringa]
	,UPPER(LEFT(ul.[unitaLocale],1))+LOWER(SUBSTRING(ul.[unitaLocale],2,LEN(ul.[unitaLocale]))) AS 'unitaLocale'
	,TRIM(SUBSTRING(up.[filiale], CHARINDEX('-', up.[filiale])+1, LEN(up.[filiale])-CHARINDEX('-', up.[filiale]))) AS 'unitaProduttiva'
	,dad.[interno]
	,dad.[cellulare]
	,dad.[Thumbnailphoto]
	,dad.[customAttribute6]
	,dad.[gruppoSPOwner]
	,dad.[gruppoSPReader]
from
	[dipendenti].[dbo].[dipendentiAD] dad
    left outer join	[dipendenti].[dbo].[unitaLocale] ul
		on (dad.unitaLocale=ul.[codUL])
    left outer join	[dipendenti].[dbo].[unitaProduttiva] up
		on (dad.unitaLocale=up.codFiliale)
