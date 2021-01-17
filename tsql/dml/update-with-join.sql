UPDATE  t1
SET 
    t1.column1 = t2.column_from_t2,
    t1.column2 = 'some new value'
FROM 
    table1 t1
        JOIN table2 t2 ON t1.id = t2.id
WHERE 
    t2.is_deleted = 0