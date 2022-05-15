CREATE OR ALTER VIEW stage2.vw_Columns
AS

WITH source AS (
    SELECT ctv.Id AS TableVersionId, c.ColumnName, c.DataType, c.CharacterMaxLength, c.DateNumPrecision,
        c.IsNullable, c.OrdinalPosition, c.Abbreviation
    FROM stage1.Columns c 
        INNER JOIN dbo.Tables t ON c.TableName = CONCAT_WS('_',t.Abbreviation,t.TableName)
            AND c.TableSchema = t.TableSchema
        INNER JOIN dbo.vw_CurrentTableVersion ctv ON t.Id = ctv.TableId
        -- Exclude system generated columns
        LEFT JOIN dbo.vw_AbbreviationClass vac ON c.ColumnName = vac.[Value]
            AND vac.Class = 'Attribute'
    WHERE vac.AbbreviationClassTypeId IS NULL
)

SELECT s.*
FROM source s 
    LEFT JOIN dbo.Columns c ON s.TableVersionId = c.TableVersionId 
        AND c.ColumnName = s.ColumnName

GO

SELECT * FROM stagE1.Columns WHERE Abbreviation IS NOT NULL