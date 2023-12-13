SELECT [codUL]
FROM [dipendenti].[test].[unitaLocale] ul
WHERE NOT EXISTS
(
	SELECT 1 FROM [dipendenti].[test].[dipendentiAD] dad
	WHERE dad.[unitaLocale] = ul.[unitaLocale]
);
