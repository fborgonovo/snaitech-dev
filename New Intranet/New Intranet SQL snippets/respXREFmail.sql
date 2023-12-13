UPDATE
    [dipendenti].[dbo].[dipendentiAD]
SET
    [codRespStringa] = exm.[mail]
FROM
	[dipendenti].[dbo].[dipendentiAD] AS dad
INNER JOIN
	[dipendenti].[test].[emailxmanager] AS exm
ON 
    dad.[codRespStringa] = exm.[nc]