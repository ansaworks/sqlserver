/*** get columns of each tables ***/

DECLARE 
    @table_schema NVARCHAR(10) = 'your_schema', 
    @table_name NVARCHAR(100) = 'your_database'

SELECT 
	COLUMN_NAME,
	DATA_TYPE,
	CHARACTER_MAXIMUM_LENGTH
	--* 
FROM 
	INFORMATION_SCHEMA.COLUMNS
WHERE 
	TABLE_SCHEMA =  @table_schema AND
	TABLE_NAME = @table_name