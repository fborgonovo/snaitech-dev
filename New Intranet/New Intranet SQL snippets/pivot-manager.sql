WITH C AS(
	SELECT [Manager]
		  ,value
		  ,ROW_NUMBER() OVER(PARTITION BY [Manager] ORDER BY (SELECT NULL)) as RN
	FROM [dipendenti].[test].[estrazionePerAD] BO
		CROSS APPLY STRING_SPLIT([Manager], ' ') AS S
)
SELECT [Manager]
      ,[1] AS S1
      ,[2] AS S2
      ,[3] AS S3
      ,[4] AS S4
FROM C
PIVOT(
    MAX(VALUE)
    FOR RN IN([1],[2],[3],[4])
) as PVT
