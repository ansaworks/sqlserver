/**********************************************************************************************************
* DISCLAIMER:
* I did NOT create this procedure. Here is the original source from mssqltips.com:
* https://www.mssqltips.com/sqlservertip/4054/creating-a-date-dimension-or-calendar-table-in-sql-server/
*
* I adjusted the procedure so it serves my purpose:
*   @StartDate      --> the start date
*   @NumberOfYears  --> the end date
* In this example, it populates the table dim_date from 2011-01-01 to the next 30 years (2040-12-31)
***********************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.sp_populate_dim_date
    @StartDate DATE = '20110101', 
    @NumberOfYears INT = 30

AS 

BEGIN

    -- prevent set or regional settings from interfering with 
    -- interpretation of dates / literals

    SET DATEFIRST 1;  -- Weekday starts on Monday
    SET DATEFORMAT mdy;
    SET LANGUAGE US_ENGLISH;

    DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

    -- this is just a holding table for intermediate calculations:

    CREATE TABLE #dim
    (
        [date]       DATE, 
        [day]        AS DATEPART(DAY,      [date]),
        [month]      AS DATEPART(MONTH,    [date]),
        FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0)),
        [MonthName]  AS DATENAME(MONTH,    [date]),
        [week]       AS DATEPART(WEEK,     [date]),
        [ISOweek]    AS DATEPART(ISO_WEEK, [date]),
        [DayOfWeek]  AS DATEPART(WEEKDAY,  [date]),
        [quarter]    AS DATEPART(QUARTER,  [date]),
        [year]       AS DATEPART(YEAR,     [date]),
        FirstOfYear  AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [date]), 0)),
        Style112     AS CONVERT(CHAR(8),   [date], 112),
        Style101     AS CONVERT(CHAR(10),  [date], 101)
    );

    -- use the catalog views to generate as many rows as we need

    INSERT #dim([date]) 
    SELECT d
    FROM
    (
    SELECT d = DATEADD(DAY, rn - 1, @StartDate)
    FROM 
    (
        SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
        rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
        FROM sys.all_objects AS s1
        CROSS JOIN sys.all_objects AS s2
        ORDER BY s1.[object_id]
    ) AS x
    ) AS y;


    INSERT dbo.dim_date WITH (TABLOCKX)
    SELECT
    dim_id				    = CONVERT(INT, Style112),
    dim_date			    = [date],
    dim_day				    = CONVERT(TINYINT, [day]),
    day_suffix			    = CONVERT(CHAR(2), CASE WHEN [day] / 10 = 1 THEN 'th' ELSE 
                                    CASE RIGHT([day], 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
                                    WHEN '3' THEN 'rd' ELSE 'th' END END),
    dim_weekday			    = CONVERT(TINYINT, [DayOfWeek]),
    weekday_name		    = CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [date])),
    is_weekend			    = CONVERT(BIT, CASE WHEN [DayOfWeek] IN (6,7) THEN 1 ELSE 0 END),
    is_holiday			    = CONVERT(BIT, 0),
    holiday_text			= CONVERT(VARCHAR(64), NULL),
    day_of_week_in_month	= CONVERT(TINYINT, ROW_NUMBER() OVER 
                                    (PARTITION BY FirstOfMonth, [DayOfWeek] ORDER BY [date])),
    day_of_year			    = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [date])),
    week_of_month			= CONVERT(TINYINT, DENSE_RANK() OVER 
                                    (PARTITION BY [year], [month] ORDER BY [week])),
    week_of_year			= CONVERT(TINYINT, [week]),
    iso_week_of_year		= CONVERT(TINYINT, ISOWeek),
    dim_month				= CONVERT(TINYINT, [month]),
    month_name			    = CONVERT(VARCHAR(10), [MonthName]),
    dim_quarter			    = CONVERT(TINYINT, [quarter]),
    quarter_name			= CONVERT(VARCHAR(6), CASE [quarter] WHEN 1 THEN 'First' 
                                WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' WHEN 4 THEN 'Fourth' END), 
    dim_year				= [year],
    mmyyyy				    = CONVERT(CHAR(6), LEFT(Style101, 2)    + LEFT(Style112, 4)),
    month_year			    = CONVERT(CHAR(7), LEFT([MonthName], 3) + LEFT(Style112, 4)),
    first_day_of_month      = FirstOfMonth,
    last_day_of_month       = MAX([date]) OVER (PARTITION BY [year], [month]),
    first_day_of_quarter    = MIN([date]) OVER (PARTITION BY [year], [quarter]),
    last_day_of_quarter     = MAX([date]) OVER (PARTITION BY [year], [quarter]),
    first_day_of_year       = FirstOfYear,
    last_day_of_year        = MAX([date]) OVER (PARTITION BY [year])
    FROM #dim
    OPTION (MAXDOP 1);

    DROP TABLE #dim

END