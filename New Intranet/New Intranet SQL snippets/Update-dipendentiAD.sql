begin tran

UPDATE
			dad
SET
			dad.[unitaLocale]		= sam.[l],
			dad.[unitaProduttiva]	= sam.[streetAddress]
FROM		
			[dipendenti].[test].[dipendentiAD] AS dad
INNER JOIN
			[dipendenti].[test].[FileConDescrizioniEstese-SAM-corretto] AS sam
ON
			dad.[samAccountName] = sam.[samAccountName]

commit tran