CREATE   FUNCTION dbo.fn_GetColumnListByAlphaOrder
    (
        @tblSchema VARCHAR(255), 
        @tblName VARCHAR(255), 
        @excludeColumnsList VARCHAR(MAX) = ''
    )
RETURNS VARCHAR(MAX)
--WITH ENCRYPTION|SCHEMABINDING, ...
AS
BEGIN
    DECLARE @fqTable VARCHAR(255) = CONCAT_WS('.',@tblSchema, @tblName)
    DECLARE @list VARCHAR(MAX) =
        (
            SELECT STRING_AGG(C.COLUMN_NAME,', ') WITHIN GROUP (ORDER BY C.COLUMN_NAME) AS ColumnList
            FROM INFORMATION_SCHEMA.COLUMNS C 
            WHERE C.TABLE_NAME = @tblName
                AND C.TABLE_SCHEMA = @tblSchema
                AND C.COLUMN_NAME NOT IN (
                    SELECT LTRIM(RTRIM([value])) AS COLUMN_NAME
                    FROM STRING_SPLIT(@excludeColumnsList,',') tbl
                )
        )
    RETURN @list
END

GO

