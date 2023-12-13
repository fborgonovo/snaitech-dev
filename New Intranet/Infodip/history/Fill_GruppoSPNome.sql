DECLARE @int_IDGRUPPOSP INT
DECLARE @vc255_DESC VARCHAR(255)

DECLARE db_cursor CURSOR
FOR SELECT id_GruppoSP, Descrizione
FROM [dipendenti].[dbo].[GruppiSP]

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @int_IDGRUPPOSP, @vc255_DESC

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @vc255_DESC = REPLACE(@vc255_DESC, ',', '')
	SET @vc255_DESC = REPLACE(@vc255_DESC, '&', '')
	SET @vc255_DESC = REPLACE(@vc255_DESC, ' ', '_')
	SET @vc255_DESC = REPLACE(@vc255_DESC, '__', '_')
	SET @vc255_DESC = 'SP_'+@vc255_DESC

	UPDATE [dipendenti].[dbo].[GruppiSP]
	SET GruppoSPNome = @vc255_DESC
	WHERE id_GruppoSP = @int_IDGRUPPOSP

	FETCH NEXT FROM db_cursor INTO @int_IDGRUPPOSP, @vc255_DESC
END

CLOSE db_cursor
DEALLOCATE db_cursor
