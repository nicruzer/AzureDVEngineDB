DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)
;WITH sqlParts AS (
    SELECT DISTINCT ftc.TableId, dbo.fn_GetVaultTableName(ftc.TableId,1,1) AS FQQuotedTableName,
        CONCAT_WS(', ' + @NewLine,
            dbo.fn_GetVaultTableKey(ftc.TableId),
            STRING_AGG(QUOTENAME(ISNULL(tca.TargetColumnAlias,ftc.ColumnName)),', ') WITHIN GROUP (ORDER BY ftc.OrdinalPosition),
            'RSRC, LDDTS' -- Hard coded for now. Need a strategy for getting required columns.
        ) AS SimpleColumnList,
        dbo.fn_GetVaultTableKey(ftc.TableId) AS TableBKeyColumn
    FROM dbo.vw_FullTableColumns ftc
        CROSS APPLY (SELECT DISTINCT TargetColumnAlias FROM  dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
    WHERE ftc.TableSchema = 'vault'
        -- Do not include key column in satellite column list
        AND ftc.ColumnName = (CASE WHEN ftc.AttributeAbbreviation = 'BKEY' AND ftc.EntityAbbreviation = 'SAT' THEN NULL ELSE ftc.ColumnName END)
    GROUP BY ftc.TableId
), colDef AS (
    SELECT DISTINCT ftc.TableId, ftc.TableName,
        CASE WHEN ftc.EntityAbbreviation <> 'SAT'
            THEN CONCAT_WS(' ', dbo.fn_GetVaultTableKey(ftc.TableId),'VARCHAR(4000), ')
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
                                            THEN '4000' -- MAX columns cannot be included in COLUMNSTORE INDEX
                                            ELSE CONVERT(VARCHAR,ftc.CharacterMaxLength)
                                        END,
                                        CONVERT(VARCHAR,ftc.DateNumPrecision)
                                    ) --ISNULL
                            ,'(') -- QUOTENAME
                        ELSE ''
                    END), --CONCAT_WS
                ', '
            ) WITHIN GROUP (ORDER BY ftc.OrdinalPosition), --STRING_AGG
            'RSRC VARCHAR(4000)',
            'LDDTS DATETIME2(7)'
        ) AS ColumnDefinition
    FROM dbo.vw_FullTableColumns ftc
        CROSS APPLY (SELECT DISTINCT TargetColumnAlias FROM  dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
    WHERE ftc.TableSchema = 'vault'
        -- AND ftc.EntityAbbreviation = 'SAT'
    GROUP BY ftc.TableId, ftc.TableName, ftc.EntityAbbreviation
)
/* 
    TODO: Auto-generate zero keys and ghost records
 */

SELECT
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
    + 'END '
    AS VaultTableSQL
FROM sqlParts sp 
    INNER JOIN colDef cd ON sp.TableId = cd.TableId
