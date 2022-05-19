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

