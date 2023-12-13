SELECT *
FROM sys.dm_io_virtual_file_stats(DB_ID(''), NULL) divfs
ORDER BY divfs.io_stall DESC;