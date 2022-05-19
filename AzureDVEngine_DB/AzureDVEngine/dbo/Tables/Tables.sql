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

CREATE UNIQUE NONCLUSTERED INDEX [Tables_SchemaNameAbbreviation]
    ON [dbo].[Tables]([TableSchema] ASC, [TableName] ASC, [Abbreviation] ASC);


GO

