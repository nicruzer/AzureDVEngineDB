CREATE TABLE [dbo].[AbbreviationClassType] (
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [Class]      VARCHAR (60) NULL,
    [Type]       VARCHAR (60) NULL,
    [IsPrefixed] BIT          NULL,
    CONSTRAINT [PK_AbbreviationClassType_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [AbbreviationClassType_index_0]
    ON [dbo].[AbbreviationClassType]([Class] ASC, [Type] ASC);


GO

