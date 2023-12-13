UPDATE
	[dipendenti].[test].[estrazionePerAD]
SET
	[Manager]=UPPER(RIGHT(LEFT([Manager], CHARINDEX('@', [Manager]) - 1), LEN(LEFT([Manager], CHARINDEX('@', [Manager]) - 1)) - CHARINDEX('.', [Manager])))+'_'+UPPER(LEFT(LEFT([Manager], CHARINDEX('@', [Manager]) - 1), CHARINDEX('.', [Manager]) - 1))
