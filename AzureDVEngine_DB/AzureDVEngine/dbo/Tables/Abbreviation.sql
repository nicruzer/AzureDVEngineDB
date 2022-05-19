CREATE TABLE [dbo].[Abbreviation] (
    [AbbreviationClassTypeId] INT          NOT NULL,
    [Style]                   VARCHAR (20) NOT NULL,
    [Value]                   VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_Abbreviation_value] PRIMARY KEY CLUSTERED ([Value] ASC),
    CONSTRAINT [FK_AbbreviationClassType_Id] FOREIGN KEY ([AbbreviationClassTypeId]) REFERENCES [dbo].[AbbreviationClassType] ([Id]) ON DELETE CASCADE
);


GO

