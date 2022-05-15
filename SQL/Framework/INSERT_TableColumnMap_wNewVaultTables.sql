
-- Clear the way for new inserts
IF OBJECT_ID('tempdb..#NewTables') IS NOT NULL
    DROP TABLE #NewTables
GO

IF OBJECT_ID('tempdb..#NewTableRecords') IS NOT NULL
    DROP TABLE #NewTableRecords
GO

IF OBJECT_ID('tempdb..#NewTableVersionRecords') IS NOT NULL
    DROP TABLE #NewTableVersionRecords
GO

IF OBJECT_ID('tempdb..#NewTableColumns') IS NOT NULL    
    DROP TABLE #NewTableColumns
GO

BEGIN TRANSACTION

CREATE TABLE #NewTables
(
    [Abbreviation] VARCHAR(256) NULL,
    [TargetTableSchema] VARCHAR(256) DEFAULT 'vault',
    [TargetTableName] VARCHAR(256) NULL,
    [TargetTableColumn] VARCHAR(256) NULL,
    [OrdinalPosition] INT NULL,
    [IsBusinessKey] BIT NULL
)

INSERT INTO #NewTables (
    Abbreviation,
    TargetTableName,
    TargetTableColumn,
    OrdinalPosition,
    IsBusinessKey
)
SELECT DISTINCT 
    tcm.TargetEntityAbbreviation AS Abbreviation,
    tcm.TargetTableName,
    tcm.TargetTableColumn,
    CONVERT(INT,tcm.TargetColumnOrdinalPosition) AS OrdinalPosition,
    CONVERT(BIT,tcm.IsBusinessKey) AS IsBusinessKey
FROM stage1.TableColumnMap tcm
    INNER JOIN dbo.Columns c ON tcm.SourceColumnId = c.Id
ORDER BY 
    tcm.TargetEntityAbbreviation,
    tcm.TargetTableName,
    CONVERT(INT,tcm.TargetColumnOrdinalPosition),
    tcm.TargetTableColumn

DECLARE @vaultRSRCId INT = (SELECT Id FROM dbo.RecordSource rs WHERE rs.OrganizationName = 'DATA_VAULT')

-- Insert new table definitions
CREATE TABLE #NewTableRecords 
(
    [Id] INT NOT NULL,
    [TableSchema] VARCHAR(30) NOT NULL,
    [TableName] VARCHAR(255) NOT NULL,
    [Abbreviation] VARCHAR(20) NOT NULL,
    [CreateDate] DATETIME NOT NULL,
    [RecordSourceId] INT NOT NULL
)

;WITH new AS (
    SELECT DISTINCT 
        nt.Abbreviation, nt.TargetTableName, nt.TargetTableSchema
    FROM #NewTables nt
)
MERGE INTO dbo.Tables AS tgt 
USING new AS src 
    ON tgt.TableSchema = src.TargetTableSchema
        AND tgt.TableName = src.TargetTableName
        AND tgt.Abbreviation = src.Abbreviation
WHEN NOT MATCHED BY TARGET THEN
    INSERT (TableSchema, TableName, Abbreviation, RecordSourceId)
    VALUES (src.TargetTableSchema, src.TargetTableName, src.Abbreviation, @vaultRSRCId)
OUTPUT inserted.* INTO #NewTableRecords;

-- Insert new vault tables into version table with default version 0.1.0
CREATE TABLE #NewTableVersionRecords
(
    [Id] INT NOT NULL,
    [TableId] INT NOT NULL,
    [Major] INT NOT NULL,
    [Minor] INT NOT NULL,
    [Release] INT NOT NULL
)

;WITH ntvr AS (
    SELECT Id
    FROM #NewTableRecords
)

MERGE INTO dbo.TableVersion AS tgt
USING ntvr AS src 
    ON tgt.TableId = src.Id
WHEN NOT MATCHED BY TARGET THEN
    INSERT (TableId, Major, Minor, Release)
    VALUES (src.Id, 0, 1, 0)
OUTPUT inserted.* INTO #NewTableVersionRecords;

-- Insert/Update columns for vault tables
CREATE TABLE #NewTableColumns
(
    [Id] INT NOT NULL,
    [TableVersionId] INT NULL,
    [ColumnName] VARCHAR(255) NULL,
    [DataType] VARCHAR(255) NULL,
    [CharacterMaxLength] INT NULL,
    [DateNumPrecision] INT NULL,
    [IsNullable] NVARCHAR(255) NOT NULL,
    [OrdinalPosition] INT NOT NULL,
    [Abbreviation] VARCHAR(20) NULL
)

;WITH ntc AS (
SELECT DISTINCT ctv.Id AS TableVersionId, tcm.TargetTableColumn AS ColumnName,
    UPPER(REPLACE(c.DataType,'nvarchar','varchar')) AS DataType,
    CASE 
        WHEN MIN(c.CharacterMaxLength) OVER (PARTITION BY ctv.Id, tcm.TargetTableColumn) = -1 THEN -1
        ELSE MAX(c.CharacterMaxLength) OVER (PARTITION BY ctv.Id, tcm.TargetTableColumn)
    END AS CharacterMaxLength,
    c.DateNumPrecision, 'YES' AS IsNullable, 
    MIN(tcm.OrdinalPosition) OVER (PARTITION BY ctv.Id, tcm.TargetTableColumn) AS OrdinalPosition, 
    CASE WHEN tcm.IsBusinessKey = 1 THEN 'BKEY' END AS Abbreviation
FROM stage1.TableColumnMap tcm
    INNER JOIN dbo.Columns c ON tcm.SourceColumnId = c.Id
    INNER JOIN dbo.Tables t ON tcm.TargetTableName = t.TableName 
        AND tcm.TargetEntityAbbreviation = t.Abbreviation
    INNER JOIN dbo.vw_CurrentTableVersion ctv ON t.Id = ctv.TableId
)

MERGE INTO dbo.Columns AS tgt 
USING ntc AS src 
    ON tgt.TableVersionId = src.TableVersionId
        AND tgt.ColumnName = src.ColumnName
WHEN NOT MATCHED BY TARGET THEN 
    INSERT (TableVersionId, ColumnName, DataType, CharacterMaxLength, DateNumPrecision, IsNullable, OrdinalPosition, Abbreviation)
    VALUES (src.TableVersionId, src.ColumnName, src.DataType, src.CharacterMaxLength, src.DateNumPrecision, src.IsNullable, src.OrdinalPosition, src.Abbreviation)
WHEN MATCHED THEN
    UPDATE
        SET TableVersionId = src.TableVersionId, 
        ColumnName = src.ColumnName, 
        DataType = src.DataType, 
        CharacterMaxLength = src.CharacterMaxLength, 
        DateNumPrecision = src.DateNumPrecision, 
        IsNullable = src.IsNullable, 
        OrdinalPosition = src.OrdinalPosition, 
        Abbreviation = src.Abbreviation
OUTPUT inserted.* INTO #NewTableColumns;

SELECT * 
FROM stage1.TableColumnMap tcm
    INNER JOIN #NewTableColumns ntc ON tcm

ROLLBACK TRANSACTION