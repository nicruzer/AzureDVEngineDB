CREATE OR ALTER FUNCTION dbo.fn_GetVaultTableSQL()
RETURNS @VaultTableSQL TABLE
(
    TableId INT,
    VaultTableSQL VARCHAR(MAX)
)
AS 
BEGIN
    DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)
    ;WITH sqlParts AS (
    -- DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)
        SELECT DISTINCT ftc.TableId, dbo.fn_GetVaultTableName(ftc.TableId,1,1) AS FQQuotedTableName,
            CONVERT(VARCHAR(MAX),
                CONCAT_WS(', ',
                    dbo.fn_GetVaultTableKey(ftc.TableId),
                    STRING_AGG(QUOTENAME(ISNULL(tca.TargetColumnAlias,ftc.ColumnName)),', ') WITHIN GROUP (ORDER BY ftc.OrdinalPosition),
                    'RSRC, LDDTS' -- Hard coded for now. Need a strategy for getting required columns.
                )
            ) AS SimpleColumnList,
            dbo.fn_GetVaultTableKey(ftc.TableId) AS TableBKeyColumn
        FROM dbo.vw_FullTableColumns ftc
            CROSS APPLY (SELECT DISTINCT TargetColumnAlias FROM dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
        WHERE ftc.TableSchema = 'vault'
            -- Do not include key column in satellite column list
            AND ftc.ColumnName = (CASE WHEN ftc.AttributeAbbreviation = 'BKEY' AND ftc.EntityAbbreviation = 'SAT' THEN NULL ELSE ftc.ColumnName END)
        GROUP BY ftc.TableId
    ), colDef AS (
    -- DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)
        SELECT DISTINCT ftc.TableId, ftc.TableName,
            CASE WHEN ftc.EntityAbbreviation <> 'SAT'
                THEN CONCAT_WS(' ', dbo.fn_GetVaultTableKey(ftc.TableId),'VARCHAR(8000), ')
                ELSE ''
            END +
            CONCAT_WS(', ' + @NewLine,
                STRING_AGG(
                    CONCAT_WS(' ',
                        ISNULL(tca.TargetColumnAlias,ftc.ColumnName),
                        ftc.DataType + 
                        CASE WHEN ISNULL(ftc.CharacterMaxLength,ftc.DateNumPrecision) IS NOT NULL 
                            AND (ftc.DataType LIKE '%CHAR%' OR ftc.DataType LIKE '%DATE%')
                            THEN QUOTENAME(
                                        ISNULL(
                                            CASE WHEN (ftc.CharacterMaxLength = -1 OR ftc.AttributeAbbreviation = 'BKEY')
                                                THEN '8000' -- MAX columns cannot be included in COLUMNSTORE INDEX
                                                ELSE CONVERT(VARCHAR,ftc.CharacterMaxLength)
                                            END,
                                            CONVERT(VARCHAR,ftc.DateNumPrecision)
                                        ) --ISNULL
                                ,'(') -- QUOTENAME
                            ELSE ''
                        END), --CONCAT_WS
                    ', '
                ) WITHIN GROUP (ORDER BY ftc.OrdinalPosition), --STRING_AGG
                'RSRC VARCHAR(8000)',
                'LDDTS DATETIME2(7)'
            ) AS ColumnDefinition
        FROM dbo.vw_FullTableColumns ftc
            CROSS APPLY (SELECT DISTINCT TargetColumnAlias FROM  dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
        WHERE ftc.TableSchema = 'vault'
            -- AND ftc.EntityAbbreviation = 'SAT'
        GROUP BY ftc.TableId, ftc.TableName, ftc.EntityAbbreviation
    ), zgr AS (
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
    SELECT s.TableId,
        STRING_AGG(
            s.GhostNullKeyInsertValue, ' UNION ALL '
        ) WITHIN GROUP (ORDER BY s.TableId) AS ZeroGhostValues
    FROM statements s
    GROUP BY s.TableId
    )

    INSERT INTO @VaultTableSQL
    SELECT
        sp.TableId, 
        CONVERT(VARCHAR(MAX),
            'IF OBJECT_ID(''' + sp.FQQuotedTableName + ''') IS NULL ' + @NewLine
            + 'BEGIN ' + @NewLine
            + 'SET ANSI_NULLS ON; ' + @NewLine 
            + 'SET QUOTED_IDENTIFIER ON; ' + @NewLine
            + @NewLine
            + 'CREATE TABLE ' + sp.FQQuotedTableName + @NewLine
            + '(' + @NewLine
            + cd.ColumnDefinition + @NewLine
            + ')' + @NewLine
            + 'WITH ' + @NewLine
            + '(' + @NewLine
            + 'DISTRIBUTION = HASH( ' + QUOTENAME(sp.TableBKeyColumn) + ' ),' + @NewLine
            + 'CLUSTERED COLUMNSTORE INDEX' + @NewLine
            + '); ' + @NewLine + @NewLine
            + ';WITH ZeroGhostRecords AS (SELECT * FROM (' + zgsql.ZeroGhostValues + ') tbl(' 
            + sp.SimpleColumnList + '))' + @NewLine + @NewLine
            + 'INSERT INTO ' + sp.FQQuotedTableName + ' ' + @NewLine
            + 'SELECT * ' + @NewLine
            + 'FROM ZeroGhostRecords zgr WHERE NOT EXISTS (SELECT 1 FROM ' + sp.FQQuotedTableName + ' tmp ' + @NewLine
            + 'WHERE zgr.' + sp.TableBKeyColumn + ' = tmp.' + sp.TableBKeyColumn + '); ' + @NewLine
            + 'END '
        )
        AS VaultTableSQL
    FROM sqlParts sp 
        INNER JOIN colDef cd ON sp.TableId = cd.TableId
        INNER JOIN zgsql ON sp.TableId = zgsql.TableId

RETURN
END
GO

