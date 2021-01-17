/*** get the create and modified date of each tables ***/
SELECT
	[name],
	create_date,
	modify_date
FROM
	sys.tables

/*** get last date access of each tables ***/
SELECT    
	OBJECT_NAME(object_id),
	last_user_update, 
	last_user_seek, 
	last_user_scan, 
	last_user_lookup
FROM    
	sys.dm_db_index_usage_stats
WHERE    
	database_id = DB_ID('YourDatabase')