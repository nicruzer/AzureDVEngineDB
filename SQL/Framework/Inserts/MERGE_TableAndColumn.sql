-- Populate dbo.Tables with any newly discovered tables

;WITH source AS (
SELECT DISTINCT c.TableSchema, c.TableName AS FullTableName, 
    CASE WHEN ab.IsPrefixed = 1
        THEN RIGHT(c.TableName,LEN(c.TableName) - LEN(ab.PrefixedValue))
        ELSE LEFT (c.TableName,LEN(c.TableName) - LEN(ab.SuffixedValue))
    END AS BaseTableName,
    ab.*, CASE WHEN c.TableSchema = 'vault' THEN 8 ELSE 12 END AS RecordSourceId
FROM stage1.Columns c
INNER JOIN (
    SELECT ac.AbbreviationClassTypeId, ac.Class, ac.Type, ac.[Value], ac.Style, ac.IsPrefixed,
        CASE WHEN ac.IsPrefixed = 1 THEN CONCAT([Value],'_') ELSE NULL END AS PrefixedValue,
        CASE WHEN ac.IsPrefixed = 0 THEN CONCAT('_',[Value]) ELSE NULL END AS SuffixedValue
    FROM dbo.vw_AbbreviationClass ac 
    WHERE ac.Class = 'Entity'
    ) ab 
    ON ISNULL(ab.PrefixedValue,ab.SuffixedValue) = CASE WHEN ISNULL(ab.PrefixedValue,ab.SuffixedValue) = ab.PrefixedValue THEN LEFT(c.TableName,LEN(ab.PrefixedValue)) ELSE RIGHT(c.TableName,LEN(ab.SuffixedValue)) END
)

MERGE dbo.Tables AS tgt 
USING source AS src 
    ON tgt.TableSchema = src.TableSchema
        AND tgt.TableName = src.BaseTableName
        AND tgt.Abbreviation = src.[Value]
WHEN NOT MATCHED BY TARGET THEN 
    INSERT (TableSchema, TableName, Abbreviation, RecordSourceId)
    VALUES (src.TableSchema, src.BaseTableName, src.[Value], src.RecordSourceId)
WHEN MATCHED AND tgt.RecordSourceId <> src.RecordSourceId THEN 
    UPDATE SET RecordSourceId = src.RecordSourceId
OUTPUT deleted.*, $action, inserted.*;

GO

-- Ensure the new tables are in the TableVersion table
;WITH source AS (
    SELECT t.*
    FROM dbo.Tables t 
        LEFT JOIN dbo.TableVersion tv ON t.Id = tv.TableId
)

MERGE INTO dbo.TableVersion AS tgt 
USING source AS src 
    ON tgt.TableId = src.Id 
WHEN NOT MATCHED BY TARGET THEN
    INSERT (TableId, Major, Minor, Release)
    VALUES (src.Id, 0, 1, 0)
OUTPUT $action, inserted.*;

GO

;WITH source AS (
    SELECT *
    FROM stage2.vw_Columns
)

MERGE INTO dbo.Columns AS tgt 
USING source AS src 
    ON tgt.TableVersionId = src.TableVersionId 
        AND tgt.ColumnName = src.ColumnName
WHEN NOT MATCHED BY TARGET THEN
    INSERT (TableVersionId, ColumnName, DataType, CharacterMaxLength, DateNumPrecision, IsNullable, OrdinalPosition, Abbreviation)
    VALUES (src.TableVersionId, src.ColumnName, src.DataType, src.CharacterMaxLength, src.DateNumPrecision, src.IsNullable, src.OrdinalPosition, src.Abbreviation)
WHEN MATCHED THEN
    UPDATE SET 
        DataType = src.DataType,
        CharacterMaxLength = src.CharacterMaxLength,
        DateNumPrecision = src.DateNumPrecision,
        IsNullable = src.IsNullable,
        OrdinalPosition = src.OrdinalPosition,
        Abbreviation = src.Abbreviation
OUTPUT deleted.*, $action, inserted.*;

GO