CREATE   VIEW dbo.vw_FullTableColumns
AS
    SELECT vctv.Id AS TableVersionId, vctv.TableId,
        t.TableSchema, t.TableName, t.Abbreviation AS EntityAbbreviation,
        t.RecordSourceId, dbo.fn_GetRecordSource(t.RecordSourceId) AS RSRC,
        c.Id AS ColumnId, c.ColumnName, c.DataType, c.CharacterMaxLength,
        c.DateNumPrecision, c.IsNullable, c.OrdinalPosition, c.Abbreviation AS AttributeAbbreviation
    FROM dbo.vw_CurrentTableVersion vctv
        INNER JOIN dbo.Tables t ON vctv.TableId = t.Id
        INNER JOIN dbo.Columns c ON vctv.Id = c.TableVersionId

GO

