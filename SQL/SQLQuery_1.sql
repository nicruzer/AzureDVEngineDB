SELECT *
FROM stage1.superhero_raw

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS C 
WHERE C.TABLE_NAME = 'superhero_raw'

SELECT [Name], LTRIM(RTRIM(a.[value])) AS [Alias]
FROM stage1.superhero_raw sr 
    CROSS APPLY STRING_SPLIT(sr.Aliases, ',') AS a
WHERE REPLACE(sr.Aliases,'-','') <> ''

SELECT C.TABLE_SCHEMA AS TableSchema, C.TABLE_NAME AS TableName,
    C.COLUMN_NAME AS ColumnName, C.ORDINAL_POSITION AS OrdinalPosition,
    C.DATA_TYPE AS DataType, C.IS_NULLABLE AS IsNullable,
    ISNULL(C.DATETIME_PRECISION,C.NUMERIC_PRECISION) AS DateNumPrecision,
    C.CHARACTER_MAXIMUM_LENGTH AS CharacterMaxLength,
    NULL AS Abbreviation
FROM INFORMATION_SCHEMA.COLUMNS C 
ORDER BY C.TABLE_SCHEMA, C.TABLE_NAME, C.ORDINAL_POSITION


