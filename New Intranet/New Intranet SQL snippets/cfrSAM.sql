SELECT [samAccountName]
FROM [dipendenti].[test].[dipendentiAD] dad
WHERE NOT EXISTS
(
	SELECT 1 FROM [dipendenti].[test].[FileConDescrizioniEstese-SAM-corretto] sam
	WHERE dad.[samAccountName] = sam.[samAccountName]
);
