-- INSERT to dbo.Tables
;WITH source AS (
    SELECT DISTINCT vsvs.TableSchema, vsvs.TableName, vsvs.EntityAbbreviation, vsvs.RecordSourceId
    FROM stage1.vw_Stage2ViewStaging vsvs
)

MERGE INTO dbo.Tables AS tgt 
USING source AS src
    ON tgt.TableSchema = src.TableSchema
        AND tgt.TableName = src.TableName
        AND tgt.Abbreviation = src.EntityAbbreviation
        AND tgt.RecordSourceId = src.RecordSourceId
WHEN NOT MATCHED BY TARGET THEN
    INSERT (TableSchema, TableName, Abbreviation, RecordSourceId)
    VALUES (src.TableSchema, src.TableName, src.EntityAbbreviation, src.RecordSourceId)
OUTPUT $action, inserted.*;

-- INSERT to dbo.TableVersion
;WITH source AS (
    SELECT DISTINCT t.Id AS TableId, 0 AS Major, 1 AS Minor, 0 AS Release
    FROM stage1.vw_Stage2ViewStaging vsvs
        INNER JOIN dbo.Tables t ON vsvs.TableSchema = t.TableSchema
            AND vsvs.TableName = t.TableName
            AND vsvs.EntityAbbreviation = t.Abbreviation
            AND vsvs.RecordSourceId = t.RecordSourceId
)

MERGE INTO dbo.TableVersion AS tgt 
USING source AS src 
    ON tgt.TableId = src.TableId 
        AND tgt.Major = src.Major
        AND tgt.Minor = src.Minor
        AND tgt.Release = src.Release 
WHEN NOT MATCHED BY TARGET THEN
    INSERT (TableId, Major, Minor, Release)
    VALUES (src.TableId, src.Major, src.Minor, src.Release)
OUTPUT $action, inserted.*;

-- INSERT to dbo.Columns
;WITH source AS (
    SELECT vctv.Id AS TableVersionId, vsvs.ColumnName, vsvs.DataType, vsvs.CharacterMaxLength,
        vsvs.DateNumPrecision, vsvs.IsNullable, vsvs.OrdinalPosition, vsvs.AttributeAbbreviation AS Abbreviation
    FROM stage1.vw_Stage2ViewStaging vsvs 
        INNER JOIN dbo.Tables t ON vsvs.TableName = t.TableName
            AND vsvs.TableSchema = t.TableSchema
            AND vsvs.EntityAbbreviation = t.Abbreviation
            AND vsvs.RecordSourceId = t.RecordSourceId
        INNER JOIN dbo.vw_CurrentTableVersion vctv ON t.Id = vctv.TableId
)

MERGE INTO dbo.Columns AS tgt 
USING source AS src 
    ON tgt.TableVersionId = src.TableVersionId
        AND tgt.ColumnName = src.ColumnName
WHEN NOT MATCHED BY TARGET THEN
    INSERT (TableVersionId, ColumnName, DataType, CharacterMaxLength, DateNumPrecision, IsNullable, OrdinalPosition, Abbreviation)
    VALUES (src.TableVersionId, src.ColumnName, src.DataType, src.CharacterMaxLength, src.DateNumPrecision, src.IsNullable, src.OrdinalPosition, src.Abbreviation)
WHEN MATCHED  
    AND (
        tgt.DataType <> src.DataType
        OR tgt.CharacterMaxLength <> src.CharacterMaxLength
        OR tgt.DateNumPrecision <> src.DateNumPrecision
        OR tgt.IsNullable <> src.IsNullable
        OR tgt.OrdinalPosition <> src.OrdinalPosition
        OR tgt.Abbreviation <> src.Abbreviation
    )
 THEN
    UPDATE SET 
        tgt.DataType = src.DataType
        , tgt.CharacterMaxLength = src.CharacterMaxLength
        , tgt.DateNumPrecision = src.DateNumPrecision
        , tgt.IsNullable = src.IsNullable
        , tgt.OrdinalPosition = src.OrdinalPosition
        , tgt.Abbreviation = src.Abbreviation
OUTPUT deleted.*, $action, inserted.*;

