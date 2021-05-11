/***
dbo.my_city:

id		city
------------
1		Hamburg
2		Berlin
3		Munich
4		Paris
78		London

***/


/* Check the current identity */
dbcc checkident ('dbo.my_city')

/* copy the affected record(s) into another table */
SELECT * INTO #my_city
FROM dbo.my_city WHERE id = 78

/* delete the affected record(s) from the origin table */
DELETE FROM dbo.mycity WHERE id = 78

/* reseed the identity */
dbcc checkident ('dbo.my_city', RESEED,4)

/* copy the affected record(s) back onto the origin table */
INSERT INTO dbo.mycity (id, city)
SELECT id, city FROM #my_city

