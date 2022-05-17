SELECT *
FROM dbo.vw_FullTableColumns hubs
    INNER JOIN dbo.vw_FullTableColumns ls ON hubs.ColumnName = ls.ColumnName
        AND hubs.EntityAbbreviation = 'HUB'
        AND ls.EntityAbbreviation IN ('LINK','SAT')
        AND hubs.AttributeAbbreviation = 'BKEY'
        AND ls.AttributeAbbreviation = 'BKEY'

SELECT tcm.*, ftc.*
FROM dbo.TableColumnMap tcm
    INNER JOIN dbo.Columns c ON tcm.TargetColumnId = c.Id
    INNER JOIN dbo.vw_FullTableColumns ftc ON c.TableVersionId = ftc.TableVersionId
        AND ftc.ColumnId = c.Id
WHERE IsBusinessKey = 1


SELECT *
FROM dbo.Tables t
    INNER JOIN dbo.vw_CurrentTableVersion ctv ON t.Id = ctv.TableId
    INNER JOIN dbo.Columns c ON ctv.Id = c.TableVersionId
        AND c.Abbreviation = 'BKEY'
WHERE t.TableSchema = 'vault'
    AND t.Abbreviation = 'HUB'

