
/* restore a database with a different name in SQL Server */

USE master
GO
RESTORE DATABASE my_database_copy FROM DISK='D:\backup\my_real_database.bak'
WITH 
   MOVE 'my_real_database' TO 'D:\mssql\my_database_copy.mdf',
   MOVE 'my_real_database_log' TO 'D:\mssql\my_database_copy_log.ldf'



/* replace (overwrite) the existing database with a full backup file */

USE master
GO
RESTORE DATABASE my_real_database FROM DISK='D:\backup\my_real_database.bak'
 WITH REPLACE