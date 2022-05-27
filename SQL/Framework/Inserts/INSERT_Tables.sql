;WITH tbl AS (
    SELECT *
    FROM (VALUES
        ('stage1', 'kaggle_superhero', 'STG', 6),
        ('stage1', 'marvel_hero_raw', 'STG', 4),
        ('stage1', 'superhero_raw', 'STG', 5),
        ('vault', 'BEING', 'HUB', 8),
        ('vault', 'BEING_KAGGLE_SUPERHERO', 'SAT', 8),
        ('vault', 'BEING_MARVEL_HERO', 'SAT', 8),
        ('vault', 'BEING_SUPERHERO', 'SAT', 8)
    ) tmp(TableSchema, TableName, Abbreviation, RecordSourceId)
)

MERGE dbo.Tables AS tgt 
USING tbl AS src 
ON tgt.TableSchema = src.TableSchema
    AND tgt.TableName = src.TableName
    AND tgt.RecordSourceId = src.RecordSourceId
WHEN NOT MATCHED BY TARGET THEN
    INSERT (TableSchema, TableName, Abbreviation, RecordSourceId)
    VALUES (src.TableSchema, src.TableName, src.Abbreviation, src.RecordSourceId)
OUTPUT $action, inserted.*;
GO

SELECT *
FROM dbo.Tables