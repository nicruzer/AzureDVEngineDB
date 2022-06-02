CREATE TABLE [dbo].[Tables] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [TableSchema]    VARCHAR (30)  NOT NULL,
    [TableName]      VARCHAR (255) NOT NULL,
    [Abbreviation]   VARCHAR (20)  NOT NULL,
    [CreateDate]     DATETIME      DEFAULT (getdate()) NOT NULL,
    [RecordSourceId] INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_RecordSource_Id] FOREIGN KEY ([RecordSourceId]) REFERENCES [dbo].[RecordSource] ([Id]) ON DELETE CASCADE
);


GO

CREATE TABLE [dbo].[DataTypeMap] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [SourceTypeName] VARCHAR (60)  NOT NULL,
    [SourceDataType] VARCHAR (255) NOT NULL,
    [TargetDataType] VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_DataTypeMap_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE TABLE [dbo].[Organization] (
    [Name]       VARCHAR (60) NOT NULL,
    [CreateDate] DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Organization_Name] PRIMARY KEY CLUSTERED ([Name] ASC)
);


GO

CREATE TABLE [dbo].[Columns] (
    [Id]                 INT            IDENTITY (1, 1) NOT NULL,
    [TableVersionId]     INT            NULL,
    [ColumnName]         VARCHAR (255)  NULL,
    [DataType]           VARCHAR (255)  NULL,
    [CharacterMaxLength] INT            NULL,
    [DateNumPrecision]   INT            NULL,
    [IsNullable]         NVARCHAR (255) NOT NULL,
    [OrdinalPosition]    INT            NOT NULL,
    [Abbreviation]       VARCHAR (20)   NULL,
    CONSTRAINT [PK_Columns_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CHECK ([IsNullable]='YES' OR [IsNullable]='NO'),
    CONSTRAINT [FK_Abbreviation_Value] FOREIGN KEY ([Abbreviation]) REFERENCES [dbo].[Abbreviation] ([Value]),
    CONSTRAINT [FK_TableVersion_Id] FOREIGN KEY ([TableVersionId]) REFERENCES [dbo].[TableVersion] ([Id]) ON DELETE CASCADE
);


GO

CREATE TABLE [stage1].[TableColumnMap] (
    [SourceColumnId]              NVARCHAR (MAX) NULL,
    [SourceSchema]                NVARCHAR (MAX) NULL,
    [SourceTable]                 NVARCHAR (MAX) NULL,
    [SourceColumn]                NVARCHAR (MAX) NULL,
    [OrdinalPosition]             NVARCHAR (MAX) NULL,
    [TargetTableName]             NVARCHAR (MAX) NULL,
    [TargetTableColumn]           NVARCHAR (MAX) NULL,
    [IsBusinessKey]               NVARCHAR (MAX) NULL,
    [TargetEntityAbbreviation]    NVARCHAR (MAX) NULL,
    [TargetColumnOrdinalPosition] NVARCHAR (MAX) NULL,
    [TargetColumnAlias]           NVARCHAR (MAX) NULL,
    [TargetTableKey]              NVARCHAR (MAX) NULL
);


GO

CREATE TABLE [dbo].[GeoLocation] (
    [Name]       VARCHAR (60) NOT NULL,
    [CreateDate] DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_GeoLocation_Name] PRIMARY KEY CLUSTERED ([Name] ASC)
);


GO

CREATE TABLE [dbo].[SourceType] (
    [Name]       VARCHAR (60) NOT NULL,
    [CreateDate] DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_SourceType_Name] PRIMARY KEY CLUSTERED ([Name] ASC)
);


GO

CREATE TABLE [dbo].[RecordSource] (
    [Id]               INT          IDENTITY (1, 1) NOT NULL,
    [GeoLocationName]  VARCHAR (60) NOT NULL,
    [OrganizationName] VARCHAR (60) NOT NULL,
    [Name]             VARCHAR (60) NOT NULL,
    [SourceTypeName]   VARCHAR (60) NOT NULL,
    [CreateDate]       DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_RecordSource_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_GeoLocation_Name] FOREIGN KEY ([GeoLocationName]) REFERENCES [dbo].[GeoLocation] ([Name]) ON DELETE CASCADE,
    CONSTRAINT [FK_Organization_Name] FOREIGN KEY ([OrganizationName]) REFERENCES [dbo].[Organization] ([Name]) ON DELETE CASCADE,
    CONSTRAINT [FK_SourceType_Name] FOREIGN KEY ([SourceTypeName]) REFERENCES [dbo].[SourceType] ([Name]) ON DELETE CASCADE
);


GO

CREATE TABLE [stage1].[Columns] (
    [TableSchema]        NVARCHAR (128) NULL,
    [TableName]          NVARCHAR (128) NULL,
    [ColumnName]         NVARCHAR (128) NULL,
    [OrdinalPosition]    INT            NULL,
    [DataType]           NVARCHAR (128) NULL,
    [IsNullable]         VARCHAR (3)    NULL,
    [DateNumPrecision]   SMALLINT       NULL,
    [CharacterMaxLength] INT            NULL,
    [Abbreviation]       VARCHAR (20)   NULL
);


GO

CREATE TABLE [dbo].[Abbreviation] (
    [AbbreviationClassTypeId] INT          NOT NULL,
    [Style]                   VARCHAR (20) NOT NULL,
    [Value]                   VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_Abbreviation_value] PRIMARY KEY CLUSTERED ([Value] ASC),
    CONSTRAINT [FK_AbbreviationClassType_Id] FOREIGN KEY ([AbbreviationClassTypeId]) REFERENCES [dbo].[AbbreviationClassType] ([Id]) ON DELETE CASCADE
);


GO

CREATE TABLE [dbo].[TableVersion] (
    [Id]      INT IDENTITY (1, 1) NOT NULL,
    [TableId] INT NOT NULL,
    [Major]   INT NOT NULL,
    [Minor]   INT NOT NULL,
    [Release] INT NOT NULL,
    CONSTRAINT [PK_TableVersion_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Tables_Id] FOREIGN KEY ([TableId]) REFERENCES [dbo].[Tables] ([Id]) ON DELETE CASCADE
);


GO

CREATE TABLE [dbo].[AbbreviationClassType] (
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [Class]      VARCHAR (60) NULL,
    [Type]       VARCHAR (60) NULL,
    [IsPrefixed] BIT          NULL,
    CONSTRAINT [PK_AbbreviationClassType_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE TABLE [dbo].[TableColumnMap] (
    [SourceColumnId]    INT           NOT NULL,
    [TargetColumnId]    INT           NOT NULL,
    [IsBusinessKey]     BIT           CONSTRAINT [DEF_IsBusinessKey] DEFAULT ((0)) NOT NULL,
    [IsDrivingKey]      BIT           CONSTRAINT [DEF_IsDrivingKey] DEFAULT ((0)) NOT NULL,
    [IsDependentChild]  BIT           CONSTRAINT [DEF_IsDependentChild] DEFAULT ((0)) NOT NULL,
    [TargetColumnAlias] VARCHAR (100) NULL,
    [TargetTableKey]    VARCHAR (100) NULL,
    CONSTRAINT [PK_TableColumnMap_SrcTgtColIds] PRIMARY KEY CLUSTERED ([SourceColumnId] ASC, [TargetColumnId] ASC),
    CONSTRAINT [FK_Columns_Source_Id] FOREIGN KEY ([SourceColumnId]) REFERENCES [dbo].[Columns] ([Id]),
    CONSTRAINT [FK_Columns_Target_Id] FOREIGN KEY ([TargetColumnId]) REFERENCES [dbo].[Columns] ([Id]) ON DELETE CASCADE
);


GO

CREATE TABLE [dbo].[DataTypeGhostValues] (
    [TYPE_NAME]      NVARCHAR (50) NOT NULL,
    [LITERAL_PREFIX] NVARCHAR (50) NULL,
    [LITERAL_SUFFIX] NVARCHAR (50) NULL,
    CONSTRAINT [PK_DataTypeGhostValues] PRIMARY KEY CLUSTERED ([TYPE_NAME] ASC)
);


GO

CREATE   VIEW dbo.vw_AbbreviationClass
AS 

    SELECT a.AbbreviationClassTypeId, act.Class, act.[Type], a.[Value],
        a.Style, act.IsPrefixed
    FROM dbo.Abbreviation a 
        INNER JOIN dbo.AbbreviationClassType act ON a.AbbreviationClassTypeId = act.Id

GO

CREATE   VIEW dbo.vw_ZeroGhostDefault
AS

WITH base AS (
    SELECT 'GhostRecord' AS RSRCType, '0' AS [Value]
    UNION
    SELECT 'Required', '-1'
    UNION
    SELECT 'Optional', '-2'
)

SELECT *, '1/1/1900' AS LDDTS
FROM base b
    CROSS APPLY (
        SELECT dbo.fn_GetRecordSource(Id) AS RSRC
        FROM dbo.RecordSource rs 
        WHERE rs.[Name] = b.RSRCType
    ) rsrctype

GO

CREATE   VIEW dbo.vw_GhostValue
AS 
    SELECT *,
        CASE 
            WHEN TYPE_NAME LIKE '%date%' THEN CONCAT(LITERAL_PREFIX,'1/1/1900',LITERAL_SUFFIX)
            ELSE CONVERT(VARCHAR,ISNULL(ISNULL(LITERAL_PREFIX + LITERAL_SUFFIX, LITERAL_PREFIX + '0'),'0'))
        END AS GHOST_VALUE
    FROM dbo.DataTypeGhostValues

GO

CREATE   VIEW dbo.vw_FullTableColumns
AS
    SELECT vctv.Id AS TableVersionId, vctv.TableId,
        t.TableSchema, t.TableName, t.Abbreviation AS EntityAbbreviation,
        CONCAT_WS('.',QUOTENAME(t.TableSchema),QUOTENAME(CONCAT_WS('_',t.Abbreviation, t.TableName))) AS FQTableName,
        QUOTENAME(CONCAT_WS('_',t.Abbreviation,t.TableName)) AS FullTableName,
        t.RecordSourceId, dbo.fn_GetRecordSource(t.RecordSourceId) AS RSRC,
        c.Id AS ColumnId, c.ColumnName, c.DataType, c.CharacterMaxLength,
        c.DateNumPrecision, c.IsNullable, c.OrdinalPosition, c.Abbreviation AS AttributeAbbreviation
    FROM dbo.vw_CurrentTableVersion vctv
        INNER JOIN dbo.Tables t ON vctv.TableId = t.Id
        INNER JOIN dbo.Columns c ON vctv.Id = c.TableVersionId

GO

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

CREATE   VIEW dbo.vw_CurrentTableVersion
AS 

    WITH CurrentTableVersion AS (
    SELECT *,
        FIRST_VALUE(tv.Id) OVER (PARTITION BY tv.TableId ORDER BY tv.Major DESC, tv.Minor DESC, tv.Release DESC) AS CurrentId
    FROM dbo.TableVersion tv 
)

SELECT ctv.Id, ctv.TableId, ctv.Major, ctv.Minor, ctv.Release
FROM CurrentTableVersion ctv 
WHERE ctv.Id = ctv.CurrentId

GO

CREATE   VIEW stage2.vw_FullTableColumnMap
AS
    SELECT 
        DENSE_RANK() OVER (ORDER BY tgtftc.FQTableName, srcftc.FQTableName) AS MapDenseRank,
        srcftc.TableSchema AS SourceTableSchema,
        srcftc.TableName AS SourceTableName,
        srcftc.ColumnName AS SourceColumnName,
        CASE WHEN srcftc.DataType LIKE '%CHAR%' THEN 1 ELSE 0 END AS IsSourceCharDataType,
        srcftc.FQTableName AS SourceFQTableName,
        srcftc.FullTableName AS SourceFullTableName,
        CASE WHEN tcm.IsBusinessKey = 1 THEN 
            COUNT(srcftc.ColumnName) OVER (PARTITION BY tgtftc.TableName, srcftc.TableName, tcm.TargetTableKey ORDER BY (SELECT NULL))
        END AS BKEYColumnCount,
        tcm.IsBusinessKey, tcm.IsDrivingKey, tcm.IsDependentChild, tcm.TargetColumnAlias, tcm.TargetTableKey,
        CASE 
            WHEN tcm.IsBusinessKey = 1 AND tgtftc.EntityAbbreviation = 'LINK' THEN 
                CASE WHEN tcm.IsDrivingKey = 1
                    THEN '-1'
                    ELSE '-2'
                END
            WHEN tcm.IsBusinessKey = 1 AND tgtftc.EntityAbbreviation <> 'LINK' THEN '-1'
            ELSE NULL
        END AS ValueIfNull,
        srcftc.RSRC,
        tgtftc.TableSchema AS TargetTableSchema,
        tgtftc.TableName AS TargetTableName,
        tgtftc.ColumnName AS TargetColumnName,
        tgtftc.FQTableName AS TargetFQTableName,
        tgtftc.EntityAbbreviation AS TargetEntityAbbreviation,
        tgtftc.OrdinalPosition
        -- , *
    FROM dbo.TableColumnMap tcm
        INNER JOIN dbo.vw_FullTableColumns srcftc ON tcm.SourceColumnId = srcftc.ColumnId
        INNER JOIN dbo.vw_FullTableColumns tgtftc ON tcm.TargetColumnId = tgtftc.ColumnId
    -- ORDER BY tgtftc.TableId, srcftc.TableId, tgtftc.OrdinalPosition

GO

CREATE   VIEW stage2.vw_Columns
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

CREATE UNIQUE NONCLUSTERED INDEX [DataTypeMap_index_5]
    ON [dbo].[DataTypeMap]([SourceTypeName] ASC, [SourceDataType] ASC);


GO

CREATE UNIQUE NONCLUSTERED INDEX [AbbreviationClassType_index_0]
    ON [dbo].[AbbreviationClassType]([Class] ASC, [Type] ASC);


GO

CREATE UNIQUE NONCLUSTERED INDEX [Tables_SchemaNameAbbreviation]
    ON [dbo].[Tables]([TableSchema] ASC, [TableName] ASC, [Abbreviation] ASC);


GO

CREATE UNIQUE NONCLUSTERED INDEX [TableVersion_index_4]
    ON [dbo].[TableVersion]([TableId] ASC, [Major] ASC, [Minor] ASC, [Release] ASC);


GO

CREATE UNIQUE NONCLUSTERED INDEX [Columns_index_3]
    ON [dbo].[Columns]([TableVersionId] ASC, [ColumnName] ASC);


GO

CREATE UNIQUE NONCLUSTERED INDEX [RecordSource_index_1]
    ON [dbo].[RecordSource]([GeoLocationName] ASC, [OrganizationName] ASC, [Name] ASC);


GO

CREATE USER [nicruzer@msn.com] FOR EXTERNAL PROVIDER;


GO

CREATE USER [ADV_SuperUsers] FOR EXTERNAL PROVIDER;


GO

CREATE USER [azuredv] FOR EXTERNAL PROVIDER;


GO

ALTER ROLE [db_owner] ADD MEMBER [nicruzer@msn.com];


GO

CREATE   FUNCTION dbo.fn_GetColumnListByAlphaOrder
    (
        @tblSchema VARCHAR(255), 
        @tblName VARCHAR(255), 
        @excludeColumnsList VARCHAR(MAX) = ''
    )
RETURNS VARCHAR(MAX)
--WITH ENCRYPTION|SCHEMABINDING, ...
AS
BEGIN
    DECLARE @fqTable VARCHAR(255) = CONCAT_WS('.',@tblSchema, @tblName)
    DECLARE @list VARCHAR(MAX) =
        (
            SELECT STRING_AGG(C.COLUMN_NAME,', ') WITHIN GROUP (ORDER BY C.COLUMN_NAME) AS ColumnList
            FROM INFORMATION_SCHEMA.COLUMNS C 
            WHERE C.TABLE_NAME = @tblName
                AND C.TABLE_SCHEMA = @tblSchema
                AND C.COLUMN_NAME NOT IN (
                    SELECT LTRIM(RTRIM([value])) AS COLUMN_NAME
                    FROM STRING_SPLIT(@excludeColumnsList,',') tbl
                )
        )
    RETURN @list
END

GO

CREATE   FUNCTION dbo.fn_GetRecordSource
(
    @RecordSourceId INT = -1
) 
RETURNS VARCHAR(1000)
AS 

BEGIN
    DECLARE @return VARCHAR(1000)

    SET @return = (SELECT TOP 1 CONCAT_WS('::', GeoLocationName, OrganizationName, [Name], SourceTypeName) AS RecordSource
        FROM dbo.RecordSource rs 
        WHERE rs.Id = @RecordSourceId
    )

    RETURN @return
END

GO

CREATE   FUNCTION dbo.fn_GetVaultTableKey
(
    @TableId INT
)
RETURNS VARCHAR(100)
AS 
BEGIN 
    DECLARE @VaultTableKey VARCHAR(100)
    
    SELECT @VaultTableKey = TargetTableKey
    FROM (
        SELECT DISTINCT TOP 1 tcm.TargetTableKey
        FROM dbo.vw_CurrentTableVersion ctv 
            INNER JOIN dbo.Tables t ON ctv.TableId = t.Id 
            INNER JOIN dbo.Columns c ON ctv.Id = c.TableVersionId
            INNER JOIN dbo.TableColumnMap tcm ON c.Id = tcm.TargetColumnId
        WHERE t.TableSchema = 'vault'
            AND tcm.IsBusinessKey = 1
            AND t.Id = @TableId
    ) tbl
            
    RETURN @VaultTableKey
END

GO

CREATE   FUNCTION dbo.fn_GetVaultTableName
(
    @TableId INT,
    @WithSchema BIT = 0,
    @Quoted BIT = 0
)
RETURNS VARCHAR(1000)
AS
BEGIN
    DECLARE @VaultTableName VARCHAR(1000)

    ;WITH base AS (
        SELECT 
            t.TableSchema,
            CONCAT_WS('_',t.Abbreviation, t.TableName) AS TableName
        FROM dbo.Tables t 
        WHERE t.Id = @TableId
            AND t.TableSchema = 'vault' -- Ensure only vault tables are used, even when a non-vault ID is passed in
    )

    SELECT @VaultTableName = 
        CASE WHEN @Quoted = 1
            THEN CASE WHEN @WithSchema = 1
                    THEN CONCAT_WS('.',QUOTENAME(b.TableSchema),QUOTENAME(b.TableName))
                    ELSE QUOTENAME(b.TableName)
                END
            ELSE 
                CASE WHEN @WithSchema = 1
                    THEN CONCAT_WS('.',b.TableSchema,b.TableName)
                    ELSE b.TableName
                END 
        END
    FROM base b

    RETURN @VaultTableName
END

GO

CREATE   FUNCTION dbo.fn_GetHashSQL
(
    @tblSchema VARCHAR(255),
    @tblName VARCHAR(255),
    @excludeColumnsList VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS 
BEGIN
    DECLARE @sql VARCHAR(MAX)

    ;WITH cols AS (
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Id,
            LTRIM(RTRIM([value])) AS ColumnName,
            COUNT([value]) OVER (ORDER BY (SELECT NULL)) AS Total
        FROM STRING_SPLIT(dbo.fn_GetColumnListByAlphaOrder(@tblSchema, @tblName, @excludeColumnsList), ',') AS tbl
    ), colSQL AS (
        SELECT cols.Id,
            CASE WHEN C.DATA_TYPE NOT IN ('nvarchar','varchar','char')
                THEN 'CONVERT(VARCHAR(1000),' + C.COLUMN_NAME + ')'
                ELSE C.COLUMN_NAME
            END AS columnListSQL,
            cols.Total
        FROM INFORMATION_SCHEMA.COLUMNS C 
            INNER JOIN cols ON c.COLUMN_NAME = cols.ColumnName
        WHERE C.TABLE_SCHEMA = @tblSchema
            AND C.TABLE_NAME = @tblName
    ), SqlStatements AS (
        SELECT 'CONVERT(BINARY(32),HASHBYTES(''SHA2_256'',UPPER(' +
            CASE WHEN cs.Total > 1 THEN 'CONCAT_WS(' ELSE '' END +
            STRING_AGG(cs.columnListSQL,',') WITHIN GROUP (ORDER BY cs.Id) +
            CASE WHEN cs.Total > 1 THEN ')' ELSE '' END + ')))' AS HashSQL
        FROM colSQL cs
        GROUP BY cs.Total
    )

    SELECT @sql = HashSQL
    FROM SqlStatements

    RETURN @sql
END

GO

CREATE   FUNCTION dbo.fn_GetVaultTableSQL()
RETURNS @VaultTableSQL TABLE
(
    TableId INT,
    VaultTableSQL VARCHAR(MAX)
)
AS 
BEGIN
    DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)
    ;WITH sqlParts AS (
    -- DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)
        SELECT DISTINCT ftc.TableId, dbo.fn_GetVaultTableName(ftc.TableId,1,1) AS FQQuotedTableName,
            CONVERT(VARCHAR(MAX),
                CONCAT_WS(', ',
                    dbo.fn_GetVaultTableKey(ftc.TableId),
                    STRING_AGG(QUOTENAME(ISNULL(tca.TargetColumnAlias,ftc.ColumnName)),', ') WITHIN GROUP (ORDER BY ftc.OrdinalPosition),
                    'RSRC, LDDTS' 
                    + CASE WHEN ftc.EntityAbbreviation = 'SAT' THEN ', HashDiff' ELSE '' END -- Hard coded for now. Need a strategy for getting required columns.
                )
            ) AS SimpleColumnList,
            dbo.fn_GetVaultTableKey(ftc.TableId) AS TableBKeyColumn
        FROM dbo.vw_FullTableColumns ftc
            CROSS APPLY (SELECT DISTINCT TargetColumnAlias FROM dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
        WHERE ftc.TableSchema = 'vault'
            -- Do not include key column in satellite column list
            AND ftc.ColumnName = (CASE WHEN ftc.AttributeAbbreviation = 'BKEY' AND ftc.EntityAbbreviation = 'SAT' THEN NULL ELSE ftc.ColumnName END)
        GROUP BY ftc.TableId, ftc.EntityAbbreviation
    ), colDef AS (
    -- DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)
        SELECT DISTINCT ftc.TableId, ftc.TableName,
            CASE WHEN ftc.EntityAbbreviation <> 'SAT'
                THEN CONCAT_WS(' ', dbo.fn_GetVaultTableKey(ftc.TableId),'VARCHAR(8000) COLLATE SQL_Latin1_General_CP1_CI_AS, ')
                ELSE ''
            END +
            CONCAT_WS(', ' + @NewLine,
                STRING_AGG(
                    CONCAT_WS(' ',
                        QUOTENAME(ISNULL(tca.TargetColumnAlias,ftc.ColumnName)),
                        ftc.DataType + 
                        CASE WHEN ISNULL(ftc.CharacterMaxLength,ftc.DateNumPrecision) IS NOT NULL 
                            AND (ftc.DataType LIKE '%CHAR%' OR ftc.DataType LIKE '%DATE%')
                            THEN QUOTENAME(
                                        ISNULL(
                                            CASE WHEN (ftc.CharacterMaxLength = -1 OR ftc.AttributeAbbreviation = 'BKEY')
                                                THEN '8000' -- MAX columns cannot be included in COLUMNSTORE INDEX
                                                ELSE CONVERT(VARCHAR,ftc.CharacterMaxLength)
                                            END,
                                            CONVERT(VARCHAR,ftc.DateNumPrecision)
                                        ) --ISNULL
                                ,'(') 
                                + CASE WHEN ftc.DataType LIKE '%CHAR%' THEN ' COLLATE SQL_Latin1_General_CP1_CI_AS' ELSE '' END
                                + CASE WHEN ftc.AttributeAbbreviation = 'BKEY' THEN ' NOT NULL' ELSE '' END -- QUOTENAME
                            ELSE ''
                        END), --CONCAT_WS
                    ', '
                ) WITHIN GROUP (ORDER BY ftc.OrdinalPosition), --STRING_AGG
                'RSRC VARCHAR(8000)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL',
                'LDDTS DATETIME2(7) NOT NULL'
            )
            + CASE WHEN ftc.EntityAbbreviation = 'SAT' THEN ', HashDiff BINARY(32)' ELSE '' END
            AS ColumnDefinition
        FROM dbo.vw_FullTableColumns ftc
            CROSS APPLY (SELECT DISTINCT TargetColumnAlias FROM  dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
        WHERE ftc.TableSchema = 'vault'
            -- AND ftc.EntityAbbreviation = 'SAT'
        GROUP BY ftc.TableId, ftc.TableName, ftc.EntityAbbreviation
    ), zgr AS (
        SELECT 
            ftc.TableId, zgd.RSRCType, tca.TargetTableKey, 
            QUOTENAME(zgd.RSRC, '''') AS RSRC, 
            QUOTENAME(zgd.LDDTS, '''') AS LDDTS,
            QUOTENAME(STRING_AGG(
                zgd.[value],'|'
            ) WITHIN GROUP (ORDER BY ftc.OrdinalPosition),'''') AS BKEY,
            zgd.[value]
        FROM dbo.vw_FullTableColumns ftc 
            CROSS APPLY (SELECT DISTINCT TargetTableKey FROM  dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
            CROSS APPLY (SELECT * FROM vw_ZeroGhostDefault) zgd
        WHERE ftc.TableSchema = 'vault'
            AND tca.TargetTableKey IS NOT NULL
        GROUP BY ftc.TableId, zgd.RSRCType, tca.TargetTableKey, zgd.rsrc, zgd.lddts, zgd.[value]
    ), statements AS (
        SELECT ftc.TableId, ftc.TableName, ftc.EntityAbbreviation,
            CONCAT_WS(', ',
                'SELECT ' + z.BKEY,
                STRING_AGG(
                    CASE WHEN ftc.AttributeAbbreviation = 'BKEY' THEN QUOTENAME(z.[value],'''') ELSE 
                    gv.GHOST_VALUE END,
                    ', '
                ) WITHIN GROUP (ORDER BY ftc.OrdinalPosition) , --STRING_AGG
                z.RSRC,
                z.LDDTS
            ) 
            -- HashDiff Logic
            + CASE WHEN ftc.EntityAbbreviation = 'SAT' 
                THEN ', CONVERT(BINARY(32),HASHBYTES(''SHA2_256'',UPPER(REPLACE(''' + 
                    CONVERT(VARCHAR(MAX),STRING_AGG(
                        CASE WHEN ftc.AttributeAbbreviation = 'BKEY' THEN REPLACE(z.[value],'''','') ELSE 
                        gv.GHOST_VALUE END,
                        '|'
                    ) WITHIN GROUP (ORDER BY ftc.OrdinalPosition)) + ''','''''''',''''))))'
                ELSE ''
            END
            -- End HashDiff Logic
            AS GhostNullKeyInsertValue
        FROM dbo.vw_FullTableColumns ftc
            CROSS APPLY (SELECT DISTINCT TargetColumnAlias FROM  dbo.TableColumnMap tcm WHERE ftc.ColumnId = tcm.TargetColumnId) tca
            CROSS APPLY (SELECT * FROM zgr WHERE ftc.TableId = zgr.TableId) z
            INNER JOIN dbo.vw_GhostValue gv ON ftc.DataType = gv.TYPE_NAME
        WHERE ftc.TableSchema = 'vault'
            AND (
                ftc.ColumnName = CASE WHEN ftc.EntityAbbreviation = 'SAT' AND ftc.AttributeAbbreviation = 'BKEY' THEN NULL ELSE ftc.ColumnName END
            )
        GROUP BY ftc.TableId, ftc.TableName, ftc.EntityAbbreviation, z.RSRCType, z.BKEY, z.RSRC, z.LDDTS
    ), zgsql AS (
    SELECT s.TableId,
        STRING_AGG(
            s.GhostNullKeyInsertValue, ' UNION ALL '
        ) WITHIN GROUP (ORDER BY s.TableId) AS ZeroGhostValues
    FROM statements s
    GROUP BY s.TableId
    )

    INSERT INTO @VaultTableSQL
    SELECT
        sp.TableId, 
        CONVERT(VARCHAR(MAX),
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
            + ';WITH ZeroGhostRecords AS (SELECT * FROM (' + zgsql.ZeroGhostValues + ') tbl(' 
            + sp.SimpleColumnList + '))' + @NewLine + @NewLine
            + 'INSERT INTO ' + sp.FQQuotedTableName + ' ' + @NewLine
            + 'SELECT * ' + @NewLine
            + 'FROM ZeroGhostRecords zgr WHERE NOT EXISTS (SELECT 1 FROM ' + sp.FQQuotedTableName + ' tmp ' + @NewLine
            + 'WHERE zgr.' + sp.TableBKeyColumn + ' = tmp.' + sp.TableBKeyColumn + '); ' + @NewLine
            + 'END '
        )
        AS VaultTableSQL
    FROM sqlParts sp 
        INNER JOIN colDef cd ON sp.TableId = cd.TableId
        INNER JOIN zgsql ON sp.TableId = zgsql.TableId

RETURN
END

GO

CREATE   FUNCTION [dbo].[fn_GetStage2SQL]()
RETURNS @StageTwoViewSQL TABLE 
(
    Stage2ViewDropSQL VARCHAR(MAX),
    Stage2ViewCreateSQL VARCHAR(MAX),
    Stage2TableDropSQL VARCHAR(MAX),
    Stage2TableCreateSQL VARCHAR(MAX)
)
AS
BEGIN
    DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)

    ;WITH RequiredColumns AS (
        SELECT DISTINCT vftcm.MapDenseRank, vftcm.SourceFQTableName, vftcm.SourceFullTableName,
            CASE WHEN vftcm.BKEYColumnCount > 1
                THEN 'CONCAT_WS(''|'', ' + STRING_AGG(CONCAT_WS(', ', 'ISNULL(' + QUOTENAME(vftcm.SourceColumnName), QUOTENAME(vftcm.ValueIfNull,'''')) + ')', ', ') WITHIN GROUP (ORDER BY vftcm.OrdinalPosition) + ')'
                ELSE STRING_AGG(CONCAT_WS(', ', 'ISNULL(' + QUOTENAME(vftcm.SourceColumnName), QUOTENAME(vftcm.ValueIfNull,'''')) + ')', '') WITHIN GROUP (ORDER BY vftcm.OrdinalPosition)
            END + ' AS ' + vftcm.TargetTableKey AS BKEYSQL,
            QUOTENAME(vftcm.RSRC, '''') + ' AS RSRC' AS RSRCSQL,
            'CURRENT_TIMESTAMP AT TIME ZONE ''UTC'' AT TIME ZONE ''Central Standard Time'' AS LDDTS' AS LDDTSSQL
        FROM stage2.vw_FullTableColumnMap vftcm 
        WHERE vftcm.BKEYColumnCount IS NOT NULL
        GROUP BY vftcm.MapDenseRank, vftcm.SourceFQTableName, vftcm.SourceFullTableName, vftcm.TargetTableKey, vftcm.BKEYColumnCount, vftcm.RSRC
    ), DistinctRequiredColumns AS (
        SELECT DISTINCT rc.SourceFQTableName, rc.SourceFullTableName,
            STRING_AGG(
                rc.BKEYSQL,
                ', '
            ) WITHIN GROUP (ORDER BY rc.MapDenseRank) AS BKEYSQL,
            rc.RSRCSQL,
            rc.LDDTSSQL
        FROM RequiredColumns rc
        WHERE rc.MapDenseRank IN (
            SELECT MIN(MapDenseRank)
            FROM RequiredColumns rc2
            GROUP BY rc2.SourceFQTableName, rc2.SourceFullTableName, rc2.BKEYSQL
        )
        GROUP BY rc.SourceFQTableName, rc.SourceFullTableName, rc.RSRCSQL, rc.LDDTSSQL
    ), SourceColumnList AS (
        SELECT DISTINCT 
            vftcm.SourceFQTableName,
            vftcm.SourceFullTableName,
            CASE WHEN vftcm.SourceColumnName <> vftcm.TargetColumnName
                THEN CONCAT_WS(' AS ', QUOTENAME(vftcm.SourceColumnName), QUOTENAME(vftcm.TargetColumnName))
                ELSE QUOTENAME(vftcm.SourceColumnName)
            END AS SourceColumnName,
            vftcm.SourceColumnName AS HashSourceColumnName,
            vftcm.IsSourceCharDataType,
            MIN(vftcm.OrdinalPosition) OVER (PARTITION BY vftcm.SourceFQTableName, vftcm.SourceFullTableName, vftcm.TargetColumnName) AS OrdinalPosition,
            MAX(CONVERT(INT,vftcm.IsBusinessKey)) OVER (PARTITION BY vftcm.SourceFQTableName, vftcm.SourceFullTableName, vftcm.TargetColumnName) AS IsBusinessKey
        FROM stage2.vw_FullTableColumnMap vftcm
    ), ColumnList AS (
        SELECT scl.SourceFQTableName, scl.SourceFullTableName,
            STRING_AGG(
                scl.SourceColumnName,
                ', '
            ) WITHIN GROUP (ORDER BY scl.OrdinalPosition) AS ColumnList
        FROM SourceColumnList scl
        GROUP BY scl.SourceFQTableName, scl.SourceFullTableName
    ), HashDiff AS (
        SELECT scl.SourceFQTableName, scl.SourceFullTableName,
            'CONVERT(BINARY(32),HASHBYTES(''SHA2_256'',UPPER(CONCAT_WS(''|'','
            + STRING_AGG(
                CONVERT(VARCHAR(MAX),'ISNULL('
                + CASE WHEN scl.IsSourceCharDataType = 0 THEN 'CONVERT(VARCHAR,' ELSE 'LTRIM(RTRIM(' END 
                + QUOTENAME(scl.HashSourceColumnName) 
                + CASE WHEN scl.IsSourceCharDataType = 0 THEN ')' ELSE '))' END
                + ','''')')
                , ', '
            ) WITHIN GROUP (ORDER BY scl.OrdinalPosition) 
            + ')))) AS HashDiff'
            AS HashDiff
        FROM SourceColumnList scl 
        WHERE scl.IsBusinessKey  = 0
        GROUP BY scl.SourceFQTableName, scl.SourceFullTableName
    )

    INSERT INTO @StageTwoViewSQL
    SELECT 
        'IF OBJECT_ID(''[stage2].' + rc.SourceFullTableName + ''') IS NOT NULL DROP VIEW [stage2].' + rc.SourceFullTableName + ';' 
        AS Stage2ViewDropSQL,
        'CREATE VIEW [stage2].' + rc.SourceFullTableName + @NewLine
        + ' AS ' + @NewLine
        + 'SELECT ' + @NewLine
        + CONCAT_WS(
            ', ',
            rc.BKEYSQL,
            cL.ColumnList,
            rc.RSRCSQL,
            rc.LDDTSSQL, 
            hd.HashDiff
        ) + @NewLine
        + ' FROM ' 
        + rc.SourceFQTableName
        AS Stage2ViewCreateSQL,
        'IF OBJECT_ID(''[stage2].' + REPLACE(rc.SourceFullTableName,'VW_','') + ''') IS NOT NULL DROP TABLE [stage2].' + REPLACE(rc.SourceFullTableName,'VW_','') + ';' 
        AS Stage2TableDropSQL,
        'IF OBJECT_ID(''[stage2].' + rc.SourceFullTableName + ''') IS NOT NULL ' + @NewLine
        + ' CREATE TABLE [stage2].' + REPLACE(rc.SourceFullTableName,'VW_','') + ' WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS ' + @NewLine
        + ' SELECT * FROM [stage2].' + rc.SourceFullTableName + '; '
        AS Stage2TableCreateSQL
    FROM DistinctRequiredColumns rc 
        INNER JOIN ColumnList cl ON rc.SourceFQTableName = cl.SourceFQTableName
            AND rc.SourceFullTableName = cl.SourceFullTableName
        LEFT JOIN HashDiff hd ON rc.SourceFQTableName = hd.SourceFQTableName
            AND rc.SourceFullTableName = hd.SourceFullTableName

RETURN
END

GO

CREATE   FUNCTION [dbo].[fn_RawVaultSQL]()
RETURNS @StageTwoViewSQL TABLE 
(
    SourceView VARCHAR(512), 
    TargetView VARCHAR(512), 
    TargetFQTableName VARCHAR(512), 
    TargetTableKey VARCHAR(256), 
    TargetEntityAbbreviation VARCHAR(10),
    DropTargetViewSQL VARCHAR(8000),
    CreateTargetViewSQL VARCHAR(8000),
    InsertVaultTableSQL VARCHAR(8000)
)
AS
BEGIN

    DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)

    ;WITH ColumnList AS (
        SELECT vftc.TableId,
            vftc.TableVersionId,
            vftc.FQTableName,
            PARSENAME(vftc.FullTableName,1) AS FullTableName,

            CONCAT_WS(
                ', ',
                CONCAT_WS('.','STG',dbo.fn_GetVaultTableKey(vftc.TableId)),
                STRING_AGG(
                    CONCAT_WS('.','STG', QUOTENAME(
                        CASE WHEN vftc.ColumnName = LinkAlias.TargetColumnName
                            THEN LinkAlias.TargetColumnAlias
                            ELSE vftc.ColumnName
                        END
                    )),
                    ', '
                ) WITHIN GROUP (ORDER BY vftc.OrdinalPosition),
                'STG.RSRC',
                'CURRENT_TIMESTAMP AT TIME ZONE ''UTC'' AT TIME ZONE ''Central Standard Time'' AS LDDTS',
                CASE WHEN vftc.EntityAbbreviation = 'SAT' THEN 'STG.HashDiff' ELSE NULL END
            )
            AS SourceColumnList,

            CONCAT_WS(
                ', ',
                dbo.fn_GetVaultTableKey(vftc.TableId),
                STRING_AGG(
                    QUOTENAME(
                        CASE WHEN vftc.ColumnName = LinkAlias.TargetColumnName
                            THEN LinkAlias.TargetColumnAlias
                            ELSE vftc.ColumnName
                        END
                    ),
                    ', '
                ) WITHIN GROUP (ORDER BY vftc.OrdinalPosition),
                'RSRC',
                'LDDTS',
                CASE WHEN vftc.EntityAbbreviation = 'SAT' THEN 'HashDiff' ELSE NULL END
            )
            AS TargetColumnList
        FROM dbo.vw_FullTableColumns vftc 
            OUTER APPLY (
                SELECT DISTINCT TargetColumnAlias, TargetColumnName
                FROM stage2.vw_FullTableColumnMap vftcm
                WHERE vftc.FQTableName = vftcm.TargetFQTableName
                    AND vftc.ColumnName = vftcm.TargetColumnName
                    AND vftc.EntityAbbreviation = 'LINK'
            ) LinkAlias
        WHERE vftc.TableSchema = 'vault'
            AND vftc.ColumnName = CASE WHEN vftc.AttributeAbbreviation = 'BKEY' AND vftc.EntityAbbreviation = 'SAT' THEN NULL ELSE vftc.ColumnName END
        GROUP BY vftc.TableId, vftc.TableVersionId, vftc.FQTableName, vftc.FullTableName, vftc.EntityAbbreviation
    ), SQLElements AS (
        SELECT DISTINCT 
            CONCAT_WS('.',QUOTENAME('stage2'),ftcm.SourceFullTableName) AS SourceView,
            '[stage2].' + QUOTENAME(CONCAT_WS('_','rv',PARSENAME(ftcm.SourceFullTableName,1),PARSENAME(ftcm.TargetFQTableName,1))) AS TargetView,
            ftcm.TargetFQTableName,
            ftcm.TargetTableKey,
            ftcm.TargetEntityAbbreviation,
            cl.SourceColumnList,
            cl.TargetColumnList,
            ' WHERE ' +
            CASE 
                WHEN ftcm.TargetEntityAbbreviation IN ('HUB','LINK')
                    THEN CONCAT_WS('.', ftcm.TargetEntityAbbreviation, ftcm.TargetTableKey) + ' IS NULL'
                WHEN ftcm.TargetEntityAbbreviation = 'SAT'
                    THEN CONCAT_WS('.', ftcm.TargetEntityAbbreviation, ftcm.TargetTableKey) + ' IS NULL'
                        + ' OR ('
                        + CONCAT_WS('.', 'STG', ftcm.TargetTableKey) + ' = ' + CONCAT_WS('.', ftcm.TargetEntityAbbreviation, ftcm.TargetTableKey) 
                        + ' AND ('
                        + CONCAT_WS('.', 'STG', 'HashDiff') + ' != ' + CONCAT_WS('.', ftcm.TargetEntityAbbreviation, 'HashDiff') 
                        + '))'
                ELSE ''
            END
            AS PredicateSQL,
            ' ON ' +
            CASE
                WHEN ftcm.TargetEntityAbbreviation IN ('HUB','LINK')
                    THEN CONCAT_WS('.','STG',ftcm.TargetTableKey) + ' = ' + CONCAT_WS('.',ftcm.TargetEntityAbbreviation,ftcm.TargetTableKey) + ' COLLATE SQL_Latin1_General_CP1_CI_AS '
                WHEN ftcm.TargetEntityAbbreviation = 'SAT'
                    THEN '('
                        + CONCAT_WS('.','STG',ftcm.TargetTableKey) + ' = ' + CONCAT_WS('.',ftcm.TargetEntityAbbreviation,ftcm.TargetTableKey) + ' COLLATE SQL_Latin1_General_CP1_CI_AS ' + @NewLine
                        + ' AND ' + CONCAT_WS('.',ftcm.TargetEntityAbbreviation,'LDDTS') 
                        + ' = '
                        + '('
                        + 'SELECT MAX(z.LDDTS) FROM '
                        + ftcm.TargetFQTableName + ' AS z ' + @NewLine
                        + ' WHERE ' + CONCAT_WS('.',ftcm.TargetEntityAbbreviation,ftcm.TargetTableKey) + ' = ' + CONCAT_WS('.','z',ftcm.TargetTableKey)
                        + '))'
            END
            AS OnSQL
        FROM stage2.vw_FullTableColumnMap ftcm
            INNER JOIN ColumnList cl ON ftcm.TargetFQTableName = cl.FQTableName
        WHERE ftcm.TargetTableKey IS NOT NULL
    )

    INSERT @StageTwoViewSQL
    SELECT 
        se.SourceView, se.TargetView, se.TargetFQTableName, se.TargetTableKey, se.TargetEntityAbbreviation,

        'IF OBJECT_ID(''' + se.TargetView + ''') IS NOT NULL DROP VIEW ' + se.TargetView + '; ' 
        AS DropTargetViewSQL,

        'CREATE VIEW ' + se.TargetView + ' AS ' + @NewLine
        + 'SELECT DISTINCT ' + @NewLine
        + se.SourceColumnList + @NewLine
        + ' FROM ' + CONCAT_WS(' AS ',se.SourceView, 'STG') + @NewLine
        + ' LEFT OUTER JOIN ' + CONCAT_WS(' AS ', se.TargetFQTableName, se.TargetEntityAbbreviation) + @NewLine
        + se.OnSQL + @NewLine
        + se.PredicateSQL
        AS CreateTargetViewSQL,

        'INSERT INTO ' + se.TargetFQTableName + @NewLine
        + ' (' + se.TargetColumnList + ') ' + @NewLine
        + ' SELECT ' + se.TargetColumnList + @NewLine
        + ' FROM ' + se.TargetView + '; '
        AS InsertVaultTableSQL
    FROM SQLElements se

RETURN
END

GO


CREATE PROCEDURE [dbo].[sp_GetStage2ViewSQL]
AS
BEGIN
    DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)

    ;WITH RequiredColumns AS (
    SELECT vftcm.MapDenseRank, vftcm.SourceFQTableName, vftcm.SourceFullTableName,
        CASE WHEN vftcm.BKEYColumnCount > 1
            THEN 'CONCAT_WS(''|'', ' + STRING_AGG(CONCAT_WS(', ', 'ISNULL(' + QUOTENAME(vftcm.SourceColumnName), QUOTENAME(vftcm.ValueIfNull,'''')) + ')', ', ') WITHIN GROUP (ORDER BY vftcm.OrdinalPosition) + ')'
            ELSE STRING_AGG(CONCAT_WS(', ', 'ISNULL(' + QUOTENAME(vftcm.SourceColumnName), QUOTENAME(vftcm.ValueIfNull,'''')) + ')', '') WITHIN GROUP (ORDER BY vftcm.OrdinalPosition)
        END + ' AS ' + vftcm.TargetTableKey AS BKEYSQL,
        QUOTENAME(vftcm.RSRC, '''') + ' AS RSRC' AS RSRCSQL,
        'CURRENT_TIMESTAMP AT TIME ZONE ''UTC'' AT TIME ZONE ''Central Standard Time'' AS LDDTS' AS LDDTSSQL
    FROM stage2.vw_FullTableColumnMap vftcm 
    WHERE vftcm.BKEYColumnCount IS NOT NULL
    GROUP BY vftcm.MapDenseRank, vftcm.SourceFQTableName, vftcm.SourceFullTableName, vftcm.TargetTableKey, vftcm.BKEYColumnCount, vftcm.RSRC
    ), Columns AS (
    SELECT vftcm.MapDenseRank,
        STRING_AGG(
            QUOTENAME(vftcm.SourceColumnName)
            + CASE WHEN vftcm.SourceColumnName <> vftcm.TargetColumnName THEN ' AS ' + QUOTENAME(vftcm.TargetColumnName) ELSE '' END
            , ', '
        ) WITHIN GROUP (ORDER BY vftcm.OrdinalPosition) AS ColumnList,
        CASE WHEN vftcm.TargetEntityAbbreviation = 'SAT' THEN
            'CONVERT(BINARY(32),HASHBYTES(''SHA2_256'',UPPER(CONCAT_WS(''|'','
            + STRING_AGG(
                CONVERT(VARCHAR(MAX),'ISNULL('
                + CASE WHEN vftcm.IsSourceCharDataType = 0 THEN 'CONVERT(VARCHAR,' ELSE 'LTRIM(RTRIM(' END 
                + QUOTENAME(vftcm.SourceColumnName) 
                + CASE WHEN vftcm.IsSourceCharDataType = 0 THEN ')' ELSE '))' END
                + ','''')')
                , ', '
            ) WITHIN GROUP (ORDER BY vftcm.OrdinalPosition) 
            + ')))) AS HashDiff'
            ELSE NULL
        END AS HashDiffSQL
    FROM stage2.vw_FullTableColumnMap vftcm 
    WHERE vftcm.SourceColumnName = (
        CASE WHEN vftcm.TargetColumnAlias IS NOT NULL AND vftcm.TargetEntityAbbreviation = 'SAT' THEN NULL ELSE vftcm.SourceColumnName END
    )
    GROUP BY vftcm.MapDenseRank, vftcm.TargetEntityAbbreviation
    )

    SELECT 
        'CREATE OR ALTER VIEW [stage2].' + rc.SourceFullTableName + @NewLine
        + ' AS ' + @NewLine
        + 'SELECT ' + @NewLine
        + CONCAT_WS(
            ', ',
            rc.BKEYSQL,
            c.ColumnList,
            rc.RSRCSQL,
            rc.LDDTSSQL, 
            c.HashDiffSQL
        ) + @NewLine
        + ' FROM ' 
        + rc.SourceFQTableName
    FROM RequiredColumns rc 
        INNER JOIN Columns c ON rc.MapDenseRank = c.MapDenseRank
END

GO

  
-- Create procedure to retrieve error information.  
CREATE PROCEDURE usp_GetErrorInfo  
AS  
SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage;

GO

-- Create the stored procedure in the specified schema
CREATE PROCEDURE dbo.sp_InsertTableColumnMap
AS
BEGIN

    -- Clear the way for new inserts
    IF OBJECT_ID('tempdb..#NewTables') IS NOT NULL
        DROP TABLE #NewTables

    IF OBJECT_ID('tempdb..#NewTableRecords') IS NOT NULL
        DROP TABLE #NewTableRecords

    IF OBJECT_ID('tempdb..#NewTableVersionRecords') IS NOT NULL
        DROP TABLE #NewTableVersionRecords

    IF OBJECT_ID('tempdb..#NewTableColumns') IS NOT NULL    
        DROP TABLE #NewTableColumns

    IF OBJECT_ID('tempdb..#NewTableColumnMap') IS NOT NULL
        DROP TABLE #NewTableColumnMap

    BEGIN TRANSACTION

    BEGIN TRY
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

        DECLARE @vaultRSRCId INT = (SELECT Id FROM dbo.RecordSource rs WHERE rs.OrganizationName = 'DATA_VAULT' AND rs.[Name] = 'SYSTEM_DV')

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
        WHEN MATCHED AND
            (
                tgt.TableVersionId <> src.TableVersionId 
                OR tgt.ColumnName <> src.ColumnName 
                OR tgt.DataType <> src.DataType 
                OR tgt.CharacterMaxLength <> src.CharacterMaxLength 
                OR tgt.DateNumPrecision <> src.DateNumPrecision 
                OR tgt.IsNullable <> src.IsNullable 
                OR tgt.OrdinalPosition <> src.OrdinalPosition 
                OR tgt.Abbreviation <> src.Abbreviation
            )
        THEN
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

        CREATE TABLE #NewTableColumnMap
        (
            [SourceColumnId] INT NOT NULL,
            [TargetColumnId] INT NOT NULL,
            [IsBusinessKey] BIT NOT NULL,
            [IsDrivingKey] BIT NOT NULL,
            [IsDependentChild] BIT NOT NULL,
            [TargetColumnAlias] VARCHAR(100) NULL,
            [TargetTableKey] VARCHAR(100) NULL
        ) 

        ;WITH source AS (
        SELECT DISTINCT tcm.SourceColumnId, ntc.Id AS TargetColumnId, tcm.IsBusinessKey, 0 AS IsDrivingKey, 0 AS IsDependentChild,
            tcm.TargetColumnAlias, tcm.TargetTableKey
        FROM #NewTableColumns ntc 
            INNER JOIN dbo.vw_fulltablecolumns ftc ON ntc.TableVersionId = ftc.TableVersionId
                AND ntc.ColumnName = ftc.ColumnName
            INNER JOIN stage1.TableColumnMap tcm ON ftc.TableName = tcm.TargetTableName
                AND ftc.ColumnName = tcm.TargetTableColumn
                AND ftc.EntityAbbreviation = tcm.TargetEntityAbbreviation

        UNION

        SELECT DISTINCT ftcsrc.ColumnId AS SourceColumnId, ftc.ColumnId AS TargetColumnId, tcm.IsBusinessKey,
            dtcm.IsDrivingKey, dtcm.IsDependentChild, -- These two are still updated manually until something better is designed
            tcm.TargetColumnAlias, tcm.TargetTableKey
        FROM dbo.vw_fulltablecolumns ftc
            INNER JOIN stage1.TableColumnMap tcm ON ftc.TableName = tcm.TargetTableName
                AND ftc.ColumnName = tcm.TargetTableColumn
                AND ftc.EntityAbbreviation = tcm.TargetEntityAbbreviation
            INNER JOIN dbo.vw_FullTableColumns ftcsrc ON ftcsrc.ColumnId = tcm.SourceColumnId
            INNER JOIN dbo.TableColumnMap dtcm ON ftcsrc.ColumnId = dtcm.SourceColumnId
                AND ftc.ColumnId = dtcm.TargetColumnId
        )

        MERGE INTO dbo.TableColumnMap AS tgt 
        USING source AS src 
            ON tgt.SourceColumnId = src.SourceColumnId
                AND tgt.TargetColumnId = src.TargetColumnId
        WHEN NOT MATCHED BY TARGET THEN 
            INSERT (SourceColumnId, TargetColumnId, IsBusinessKey, IsDrivingKey, IsDependentChild) 
            VALUES (src.SourceColumnId, src.TargetColumnId, src.IsBusinessKey, src.IsDrivingKey, src.IsDependentChild) 
        WHEN MATCHED AND
            (
                tgt.SourceColumnId <> src.SourceColumnId
                OR tgt.TargetColumnId <> src.TargetColumnId
                OR tgt.IsBusinessKey <> src.IsBusinessKey
                OR tgt.IsDrivingKey <> src.IsDrivingKey
                OR tgt.IsDependentChild <> src.IsDependentChild
                OR tgt.TargetColumnAlias <> src.TargetColumnAlias
                OR tgt.TargetTableKey <> src.TargetTableKey
            )
        THEN
            UPDATE
                SET SourceColumnId = src.SourceColumnId,
                TargetColumnId = src.TargetColumnId,
                IsBusinessKey = src.IsBusinessKey,
                IsDrivingKey = src.IsDrivingKey,
                IsDependentChild = src.IsDependentChild,
                TargetColumnAlias = src.TargetColumnAlias,
                TargetTableKey = src.TargetTableKey
        OUTPUT inserted.* INTO #NewTableColumnMap;


        SELECT * FROM #NewTables
        SELECT * FROM #NewTableRecords
        SELECT * FROM #NewTableVersionRecords
        SELECT * FROM #NewTableColumns
        SELECT * FROM #NewTableColumnMap
    END TRY

    BEGIN CATCH
        EXECUTE usp_GetErrorInfo;  
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
    END CATCH;

    IF @@TRANCOUNT > 0
        COMMIT TRANSACTION;

END

GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD= N'mgCnki=bqou|rhhsg?hFAjz.msFT7_&#$!~<{{ood?vuJ{:e';


GO

CREATE DATABASE SCOPED CREDENTIAL [ADV_ABSC]
    WITH IDENTITY = N'MANAGED IDENTITY';


GO

CREATE SCHEMA [stage1]
    AUTHORIZATION [dbo];


GO

CREATE SCHEMA [stage2]
    AUTHORIZATION [dbo];


GO

CREATE EXTERNAL DATA SOURCE [ADV_EDS]
    WITH (
    TYPE = BLOB_STORAGE,
    LOCATION = N'https://synapsedvdemo.blob.core.windows.net/synapsedvdemo',
    CREDENTIAL = [ADV_ABSC]
    );


GO

