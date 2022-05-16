DECLARE @TableName VARCHAR(255) = 'TableColumnMap'
DECLARE @SchemaName VARCHAR(255) = 'dbo'

-- List columns in all tables whose name is like 'TableColumnMap'
;WITH tbls
AS (SELECT TableName = tbl.table_schema + '.' + tbl.table_name,
           ColumnName = col.column_name,
           ColumnDataType = col.data_type,
           OrdinalPosition = ORDINAL_POSITION
    FROM INFORMATION_SCHEMA.TABLES tbl
        INNER JOIN INFORMATION_SCHEMA.COLUMNS col
            ON col.table_name = tbl.table_name
               AND col.table_schema = tbl.table_schema
    WHERE tbl.table_type = 'base table'
          AND tbl.table_name LIKE '%TableColumnMap%')

SELECT STRING_AGG(ColumnName, ', ')WITHIN GROUP(ORDER BY OrdinalPosition) AS ColumnList,
       STRING_AGG(CONCAT_WS('.', 'src', ColumnName), ', ')WITHIN GROUP(ORDER BY OrdinalPosition) AS FQSrcColumnList,
       TableName,
       MergeInsertStatement = 'INSERT (' + STRING_AGG(ColumnName, ', ')WITHIN GROUP(ORDER BY OrdinalPosition) + ') '
                              + 'VALUES ('
                              + STRING_AGG(CONCAT_WS('.', 'src', ColumnName), ', ')WITHIN GROUP(ORDER BY OrdinalPosition)
                              + ') '
FROM tbls
GROUP BY TableName

