SELECT *
FROM dbo.RecordSource
    WHERE [Name] IN ('GhostRecord','Required','Optional')


SELECT DISTINCT ftc.TableId, ftc.TableName,
    CASE WHEN ftc.EntityAbbreviation <> 'SAT'
        THEN CONCAT_WS(' ', dbo.fn_GetVaultTableKey(ftc.TableId),'VARCHAR(4000), ')
        ELSE ''
    END +
    CONCAT_WS(', ' + CHAR(13) + CHAR(10),
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


SELECT *,
    CASE 
        WHEN ftc.AttributeAbbreviation = 'BKEY' THEN '''0'''
        WHEN ftc.DateNumPrecision IS NULL THEN '' 
        ELSE '0'
    END AS GhostRecordValue,
    CASE 
        WHEN ftc.AttributeAbbreviation = 'BKEY' THEN '''-1'''
        WHEN ftc.DateNumPrecision IS NULL THEN '' 
        ELSE '-1'
    END AS RequiredNullKeyValue,
    CASE 
        WHEN ftc.AttributeAbbreviation = 'BKEY' THEN '''-2'''
        WHEN ftc.DateNumPrecision IS NULL THEN '' 
        ELSE '-2'
    END AS OptionalNullKeyValue
FROM dbo.vw_FullTableColumns ftc 
    CROSS APPLY (SELECT DISTINCT TargetColumnAlias FROM  dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
WHERE ftc.TableSchema = 'vault'
ORDER BY ftc.TableId, ftc.OrdinalPosition