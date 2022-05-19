CREATE TABLE [dbo].[SourceType] (
    [Name]       VARCHAR (60) NOT NULL,
    [CreateDate] DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_SourceType_Name] PRIMARY KEY CLUSTERED ([Name] ASC)
);


GO

