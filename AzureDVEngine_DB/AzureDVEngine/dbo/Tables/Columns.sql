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

CREATE UNIQUE NONCLUSTERED INDEX [Columns_index_3]
    ON [dbo].[Columns]([TableVersionId] ASC, [ColumnName] ASC);


GO

