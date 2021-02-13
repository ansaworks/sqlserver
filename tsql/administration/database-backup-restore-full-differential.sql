/* Day 0 */
USE ansaworks
GO
CREATE TABLE dbo.city (
    id INT IDENTITY(1,1) NOT NULL,
    city NVARCHAR(100)
)
GO
INSERT dbo.city VALUES('Hamburg')
INSERT dbo.city VALUES('Berlin')
GO
-- Full backup
BACKUP DATABASE ansaworks
TO DISK = N'C:\Temp\ansaworks_full.bak' 
WITH FORMAT, NAME = N'ansaworks Full Database Backup'   
GO

/* Day 1 */
INSERT dbo.city VALUES('London')
GO
-- Differential backup
BACKUP DATABASE ansaworks 
TO DISK = N'C:\Temp\ansaworks_diff_1.bak' 
WITH FORMAT, NAME = N'ansaworks Diff Database Backup', Differential  
GO

/* Day 2 */
INSERT dbo.city VALUES('Paris')
GO
-- Differential backup
BACKUP DATABASE ansaworks 
TO DISK = N'C:\Temp\ansaworks_diff_2.bak' 
WITH FORMAT, NAME = N'ansaworks Diff Database Backup', Differential  
GO

/* Day 3 */
DROP TABLE ansaworks.dbo.city

-- restore with differential
USE master
GO
RESTORE DATABASE ansaworks FROM DISK = 'C:\Temp\ansaworks_full.bak' WITH NORECOVERY, REPLACE
GO
RESTORE DATABASE ansaworks FROM DISK = 'C:\Temp\ansaworks_diff_2.bak' WITH RECOVERY
GO
