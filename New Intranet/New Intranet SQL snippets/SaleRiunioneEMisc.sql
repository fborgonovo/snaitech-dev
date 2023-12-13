INSERT INTO [dipendenti].[dbo].[dipendentiAD] ([id_dipendente],[samAccountName],[nome],[cognome],[interno],[cellulare],[Azienda])
SELECT
	 [Id]
	,[Nominativo]
	,[Nominativo]
	,[Nominativo]
    ,[Interno]
    ,[Cellulare]
	,'Snaitech'
FROM [dipendenti].[import].[SaleRiunioneEMisc]