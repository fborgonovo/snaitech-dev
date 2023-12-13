INSERT INTO
	[dipendenti].[dbo].[dipendentiAD] (
	[Azienda]
	,[cognome]
	,[nome]
	,[mail]
	,[Reparto]
	,[Squadra]
	,[Divisione]
	,[Mansione]
	,[codRespStringa]
	,[interno]
	,[cellulare]
	,[customAttribute6]
	,[gruppoSPOwner]
	,[gruppoSPReader])
SELECT
	 [company]
	,[sn]
	,[givenName]
	,[mail]
	,[department]
	,[description]
	,[office]
	,[jobTitle]
	,[manager]
	,[telephoneNumber]
	,[mobile]
	,[customAttribute6]
	,[gruppoSPOwner]
	,[gruppoSPReader]
FROM
	[dipendenti].[import].[export_dipendenti_2]
WHERE
	[dipendenti].[import].[export_dipendenti_2].company='Area Scom'