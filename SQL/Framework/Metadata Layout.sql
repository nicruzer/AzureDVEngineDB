CREATE TABLE [AbbreviationClassType] (
  [Id] int PRIMARY KEY IDENTITY(1, 1),
  [Class] varchar(60),
  [Type] varchar(60),
  [IsPrefixed] bit
)
GO

CREATE TABLE [Abbreviation] (
  [AbbreviationClassTypeId] int NOT NULL,
  [Style] varchar(20) NOT NULL,
  [Value] varchar(20) PRIMARY KEY NOT NULL
)
GO

CREATE TABLE [GeoLocation] (
  [Name] varchar(60) PRIMARY KEY,
  [CreateDate] datetime DEFAULT (GETDATE())
)
GO

CREATE TABLE [SourceType] (
  [Name] varchar(60) PRIMARY KEY,
  [CreateDate] datetime DEFAULT (GETDATE())
)
GO

CREATE TABLE [Organization] (
  [Name] varchar(60) PRIMARY KEY,
  [CreateDate] datetime DEFAULT (GETDATE())
)
GO

CREATE TABLE [RecordSource] (
  [Id] int PRIMARY KEY IDENTITY(1, 1),
  [GeoLocationName] varchar(60) NOT NULL,
  [OrganizationName] varchar(60) NOT NULL,
  [Name] varchar(60) NOT NULL,
  [SourceTypeName] varchar(60) NOT NULL,
  [CreateDate] datetime DEFAULT (GETDATE())
)
GO

CREATE TABLE [Tables] (
  [Id] int PRIMARY KEY IDENTITY(1, 1),
  [TableSchema] varchar(30) NOT NULL,
  [TableName] varchar(255) NOT NULL,
  [Abbreviation] varchar(20) NOT NULL,
  [CreateDate] datetime NOT NULL DEFAULT (GETDATE()),
  [RecordSourceId] int NOT NULL
)
GO

CREATE TABLE [Columns] (
  [Id] int PRIMARY KEY IDENTITY(1, 1),
  [TableVersionId] int,
  [ColumnName] varchar(255),
  [DataType] varchar(255),
  [CharacterMaxLength] int,
  [DateNumPrecision] int,
  [IsNullable] nvarchar(255) NOT NULL CHECK ([IsNullable] IN ('NO', 'YES')),
  [OrdinalPosition] int NOT NULL,
  [Abbreviation] varchar(20) NOT NULL
)
GO

CREATE TABLE [TableVersion] (
  [Id] int PRIMARY KEY IDENTITY(1, 1),
  [TableId] int NOT NULL,
  [Major] int NOT NULL,
  [Minor] int NOT NULL,
  [Release] int NOT NULL
)
GO

CREATE TABLE [TableColumnMap] (
  [SourceColumnId] int NOT NULL,
  [TargetColumnId] int NOT NULL,
  PRIMARY KEY ([SourceColumnId], [TargetColumnId])
)
GO

CREATE TABLE [DataTypeMap] (
  [Id] int PRIMARY KEY IDENTITY(1, 1),
  [SourceTypeName] varchar(60) NOT NULL,
  [SourceDataType] varchar(255) NOT NULL,
  [TargetDataType] varchar(255) NOT NULL
)
GO

ALTER TABLE [Abbreviation] ADD FOREIGN KEY ([AbbreviationClassTypeId]) REFERENCES [AbbreviationClassType] ([Id])
GO

ALTER TABLE [RecordSource] ADD FOREIGN KEY ([GeoLocationName]) REFERENCES [GeoLocation] ([Name])
GO

ALTER TABLE [RecordSource] ADD FOREIGN KEY ([OrganizationName]) REFERENCES [Organization] ([Name])
GO

ALTER TABLE [RecordSource] ADD FOREIGN KEY ([SourceTypeName]) REFERENCES [SourceType] ([Name])
GO

ALTER TABLE [Tables] ADD FOREIGN KEY ([Abbreviation]) REFERENCES [Abbreviation] ([Value])
GO

ALTER TABLE [Tables] ADD FOREIGN KEY ([RecordSourceId]) REFERENCES [RecordSource] ([Id])
GO

ALTER TABLE [Columns] ADD FOREIGN KEY ([TableVersionId]) REFERENCES [TableVersion] ([Id])
GO

ALTER TABLE [Columns] ADD FOREIGN KEY ([Abbreviation]) REFERENCES [Abbreviation] ([Value])
GO

ALTER TABLE [TableVersion] ADD FOREIGN KEY ([TableId]) REFERENCES [Tables] ([Id])
GO

ALTER TABLE [TableColumnMap] ADD FOREIGN KEY ([SourceColumnId]) REFERENCES [Columns] ([Id])
GO

ALTER TABLE [TableColumnMap] ADD FOREIGN KEY ([TargetColumnId]) REFERENCES [Columns] ([Id])
GO

ALTER TABLE [DataTypeMap] ADD FOREIGN KEY ([SourceTypeName]) REFERENCES [SourceType] ([Name])
GO

CREATE UNIQUE INDEX [AbbreviationClassType_index_0] ON [AbbreviationClassType] ("Class", "Type")
GO

CREATE UNIQUE INDEX [RecordSource_index_1] ON [RecordSource] ("GeoLocationName", "OrganizationName", "Name")
GO

CREATE UNIQUE INDEX [Tables_index_2] ON [Tables] ("TableSchema", "TableName")
GO

CREATE UNIQUE INDEX [Columns_index_3] ON [Columns] ("TableVersionId", "ColumnName")
GO

CREATE UNIQUE INDEX [TableVersion_index_4] ON [TableVersion] ("TableId", "Major", "Minor", "Release")
GO

CREATE UNIQUE INDEX [DataTypeMap_index_5] ON [DataTypeMap] ("SourceTypeName", "SourceDataType")
GO
