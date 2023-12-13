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
	,de.[l] AS 'unitaLocale'
	,de.[streetAddress] AS 'unitaProduttiva'
	,dad.[interno]
	,dad.[cellulare]
	,dad.[Thumbnailphoto]
	,dad.[customAttribute6]
	,dad.[gruppoSPOwner]
	,dad.[gruppoSPReader]
from
	[dipendenti].[dbo].[dipendentiAD] dad
    left outer join	[dipendenti].[import].[FileConDescrizioniEstese] de
		on (dad.mail=de.[mail])