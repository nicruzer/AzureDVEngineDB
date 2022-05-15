;WITH vwSQL AS (
    SELECT
        t.Id AS TableId, 
        'CREATE OR ALTER VIEW ' + CONCAT(t.TableSchema, '.', CONCAT_WS('_',t.Abbreviation, t.TableName)) + ' AS ' AS ViewSQL,
        cl.ColumnList AS ColumnSQL,
        CONCAT(s1.TableSchema, '.', CONCAT_WS('_',s1.Abbreviation, s1.TableName)) AS SourceTableName
    FROM dbo.Tables t 
        INNER JOIN dbo.Tables s1 ON t.TableName = s1.TableName
            AND t.RecordSourceId = s1.RecordSourceId
        INNER JOIN (
            SELECT ftc.TableId,
                CONCAT_WS(', ',
                    STRING_AGG(CONCAT_WS('.','tbl',QUOTENAME(ftc.ColumnName)),', ') WITHIN GROUP (ORDER BY ftc.OrdinalPosition),
                    QUOTENAME(ftc.RSRC,'''') + ' AS RSRC',
                    'GETDATE() AS LDDTS'
                ) AS ColumnList
            FROM dbo.vw_FullTableColumns ftc 
            WHERE ftc.TableSchema = 'stage2'
                AND ftc.EntityAbbreviation = 'VW'
            GROUP BY ftc.TableId, ftc.RSRC
        ) AS cl ON t.Id = cl.TableId
    WHERE t.Abbreviation = 'VW'
        AND t.TableSchema = 'stage2'
)

SELECT *
FROM vwSQL
