DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)

;WITH zgr AS (
    SELECT 
        ftc.TableId, zgd.RSRCType, tca.TargetTableKey, 
        QUOTENAME(zgd.RSRC, '''') AS RSRC, 
        QUOTENAME(zgd.LDDTS, '''') AS LDDTS,
        QUOTENAME(STRING_AGG(
            zgd.[value],'|'
        ) WITHIN GROUP (ORDER BY ftc.OrdinalPosition),'''') AS BKEY,
        zgd.[value]
    FROM dbo.vw_FullTableColumns ftc 
        CROSS APPLY (SELECT DISTINCT TargetTableKey FROM  dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
        CROSS APPLY (SELECT * FROM vw_ZeroGhostDefault) zgd
    WHERE ftc.TableSchema = 'vault'
        AND tca.TargetTableKey IS NOT NULL
    GROUP BY ftc.TableId, zgd.RSRCType, tca.TargetTableKey, zgd.rsrc, zgd.lddts, zgd.[value]
), statements AS (
    SELECT ftc.TableId, ftc.TableName, ftc.EntityAbbreviation,
        CONCAT_WS(', ',
            'SELECT ' + z.BKEY,
            STRING_AGG(
                CASE WHEN ftc.AttributeAbbreviation = 'BKEY' THEN QUOTENAME(z.[value],'''') ELSE 
                gv.GHOST_VALUE END,
                ', '
            ) WITHIN GROUP (ORDER BY ftc.OrdinalPosition) , --STRING_AGG
            z.RSRC,
            z.LDDTS
        ) AS GhostNullKeyInsertValue
    FROM dbo.vw_FullTableColumns ftc
        CROSS APPLY (SELECT DISTINCT TargetColumnAlias FROM  dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
        CROSS APPLY (SELECT * FROM zgr WHERE ftc.TableId = zgr.TableId) z
        INNER JOIN dbo.vw_GhostValue gv ON ftc.DataType = gv.TYPE_NAME
    WHERE ftc.TableSchema = 'vault'
        AND (
            ftc.ColumnName = CASE WHEN ftc.EntityAbbreviation = 'SAT' AND ftc.AttributeAbbreviation = 'BKEY' THEN NULL ELSE ftc.ColumnName END
        )
    GROUP BY ftc.TableId, ftc.TableName, ftc.EntityAbbreviation, z.RSRCType, z.BKEY, z.RSRC, z.LDDTS
), zgsql AS (
SELECT s.TableId, s.TableName, s.EntityAbbreviation,
    STRING_AGG(
        s.GhostNullKeyInsertValue, ' UNION ALL '
    ) WITHIN GROUP (ORDER BY s.TableId) AS ZeroGhostValues
FROM statements s
GROUP BY s.TableId, s.TableName, s.EntityAbbreviation
)

SELECT * 
FROM zgsql
