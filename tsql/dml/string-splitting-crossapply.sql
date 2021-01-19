DECLARE @T TABLE
(
 customer_address NVARCHAR(100)
)
INSERT INTO @T 
VALUES
    ('Hauptstrasse@2;Hamburg;DE--'),
    ('Main Street@10;Madison;US--'),
    ('Park Boulevard@5A;Hong Kong;HK--')


SELECT 
  substring(customer_address, 1, P1.Pos - 1)                    AS Street,
  substring(customer_address, P1.Pos + 1, P2.Pos - P1.Pos - 1)  AS StreetNo,
  substring(customer_address, P2.Pos + 1, P3.Pos - P2.Pos - 1)  AS City,
  substring(customer_address, P3.Pos + 1, P4.Pos - P3.Pos - 1)  AS Country
FROM @T
  CROSS APPLY (SELECT (charindex('@', customer_address)))               AS P1(Pos)
  CROSS APPLY (SELECT (charindex(';', customer_address, P1.Pos+1)))     AS P2(Pos)
  CROSS APPLY (SELECT (charindex(';', customer_address, P2.Pos+1)))     AS P3(Pos)
  CROSS APPLY (SELECT (charindex('--', customer_address, P3.Pos+1)))    AS P4(Pos)