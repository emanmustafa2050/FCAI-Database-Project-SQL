-- SQL Script to extract Conceptual Schema details from SQL Server


-- 1. Get all tables in the database
SELECT TABLE_NAME AS TableName 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';

-- 2. Get all columns and their data types
SELECT 
    TABLE_NAME AS TableName, 
    COLUMN_NAME AS ColumnName, 
    DATA_TYPE AS DataType 
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME;

-- 3. Get all Primary Keys
SELECT ku.TABLE_NAME AS TableName, 
       ku.COLUMN_NAME AS PrimaryKey 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc 
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS ku
ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

-- 4. Get all Foreign Key relationships
SELECT fk.name AS ForeignKeyName,
       tp.name AS ParentTable,
       cp.name AS ParentColumn,
       tr.name AS ReferencedTable,
       cr.name AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS tp ON fk.parent_object_id = tp.object_id
INNER JOIN sys.tables AS tr ON fk.referenced_object_id = tr.object_id
INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns AS cp ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
INNER JOIN sys.columns AS cr ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
ORDER BY ParentTable;

