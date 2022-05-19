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

CREATE UNIQUE NONCLUSTERED INDEX [TableVersion_index_4]
    ON [dbo].[TableVersion]([TableId] ASC, [Major] ASC, [Minor] ASC, [Release] ASC);


GO

