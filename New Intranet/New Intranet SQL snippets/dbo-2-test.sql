INSERT INTO 
	   [dipendenti].[test].[dipendentiAD]
SELECT
       [samAccountName]
      ,[dataCreazione]
      ,[mailResp]
      ,[codAzienda]
      ,[codDipendente]
      ,[cognome]
      ,[nome]
      ,[mail]
      ,[id_reparto]
      ,[id_squadra]
      ,[id_divisione]
      ,[id_mansione]
      ,[codBU]
      ,[codRespStringa]
      ,[samResp]
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
      ,[sede]
      ,[Azienda]
      ,[Reparto]
      ,[Squadra]
      ,[Divisione]
      ,[Mansione]
      ,[Thumbnailphoto]
      ,[customAttribute6]
      ,[gruppoSPOwner]
      ,[gruppoSPReader]
FROM 
	   [dipendenti].[dbo].[dipendentiAD]