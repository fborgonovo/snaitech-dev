INSERT INTO [dipendenti].[dbo].[dipendentiAD] (
	 [id_dipendente]
	,[samAccountName]
	,[dataCreazione]
	,[mailResp]
    ,[codAzienda]
    ,[codDipendente]
	,[Azienda]
	,[cognome]
	,[nome]
	,[mail]
    ,[id_reparto]
    ,[id_squadra]
    ,[id_divisione]
    ,[id_mansione]
    ,[codBU]
	,[Reparto]
	,[Squadra]
	,[Divisione]
	,[Mansione]
	,[codRespStringa]
	,[codAzResp]
	,[codDipResp]
	,[id_avatar]
	,[dataAssunzione]
	,[dataNascita]
	,[inquadramento]
	,[unitaLocale]
	,[unitaProduttiva]
	,[cellulare]
	,[interno]
	,[Thumbnailphoto]
	,[customAttribute6]
	,[gruppoSPOwner]
	,[gruppoSPReader])
SELECT
	 1653
	,'rossi_stefano'
	,'08-10-2019 17.11:10'
	,[mailDelResponsabile]
	,28
	,998
	,[company]
	,[sn]
	,[givenName]
	,[mail]
	,46
	,67
	,7
	,411
	,219
	,[department]
	,[description]
	,[office]
	,[jobTitle]
	,[manager]
	,28
	,1280
	,NULL
	,'2013-12-02'
	,NULL
	,NULL
	,3
	,4
	,[mobile]
	,[telephoneNumber]
	,NULL
	,[customAttribute6]
	,[gruppoSPOwner]
	,[gruppoSPReader]
FROM
	[dipendenti].[import].[export_dipendenti_2]
WHERE
	[dipendenti].[import].[export_dipendenti_2].[mail]='stefano.rossi2@snaitech.it'
