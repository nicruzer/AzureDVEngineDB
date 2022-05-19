CREATE   VIEW stage1.vw_Stage2ViewStaging
AS
    WITH stage2Views AS (
        SELECT *
        FROM dbo.vw_FullTableColumns vftc
        WHERE vftc.TableSchema = 'stage2'
            AND vftc.EntityAbbreviation = 'VW'
    )

    SELECT 'stage2' AS TableSchema, vftc.TableName, 'VW' AS EntityAbbreviation,
        vftc.RecordSourceId,vftc.ColumnId, vftc.ColumnName, vftc.DataType, vftc.CharacterMaxLength,
        vftc.DateNumPrecision, vftc.IsNullable, vftc.OrdinalPosition, vftc.AttributeAbbreviation
    FROM dbo.vw_FullTableColumns vftc
        LEFT JOIN stage2Views s2v ON vftc.TableName = s2v.TableName
            AND vftc.RecordSourceId = s2v.RecordSourceId
            AND vftc.ColumnName = s2v.ColumnName
    WHERE vftc.TableSchema = 'stage1'
        AND s2v.TableName IS NULL

GO

