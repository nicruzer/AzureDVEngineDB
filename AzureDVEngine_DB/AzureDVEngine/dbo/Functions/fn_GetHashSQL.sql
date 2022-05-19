CREATE   FUNCTION dbo.fn_GetHashSQL
(
    @tblSchema VARCHAR(255),
    @tblName VARCHAR(255),
    @excludeColumnsList VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS 
BEGIN
    DECLARE @sql VARCHAR(MAX)

    ;WITH cols AS (
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Id,
            LTRIM(RTRIM([value])) AS ColumnName,
            COUNT([value]) OVER (ORDER BY (SELECT NULL)) AS Total
        FROM STRING_SPLIT(dbo.fn_GetColumnListByAlphaOrder(@tblSchema, @tblName, @excludeColumnsList), ',') AS tbl
    ), colSQL AS (
        SELECT cols.Id,
            CASE WHEN C.DATA_TYPE NOT IN ('nvarchar','varchar','char')
                THEN 'CONVERT(VARCHAR(1000),' + C.COLUMN_NAME + ')'
                ELSE C.COLUMN_NAME
            END AS columnListSQL,
            cols.Total
        FROM INFORMATION_SCHEMA.COLUMNS C 
            INNER JOIN cols ON c.COLUMN_NAME = cols.ColumnName
        WHERE C.TABLE_SCHEMA = @tblSchema
            AND C.TABLE_NAME = @tblName
    ), SqlStatements AS (
        SELECT 'CONVERT(BINARY(32),HASHBYTES(''SHA2_256'',UPPER(' +
            CASE WHEN cs.Total > 1 THEN 'CONCAT_WS(' ELSE '' END +
            STRING_AGG(cs.columnListSQL,',') WITHIN GROUP (ORDER BY cs.Id) +
            CASE WHEN cs.Total > 1 THEN ')' ELSE '' END + ')))' AS HashSQL
        FROM colSQL cs
        GROUP BY cs.Total
    )

    SELECT @sql = HashSQL
    FROM SqlStatements

    RETURN @sql
END

GO

