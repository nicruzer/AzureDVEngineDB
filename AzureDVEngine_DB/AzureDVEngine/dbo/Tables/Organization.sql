CREATE TABLE [dbo].[Organization] (
    [Name]       VARCHAR (60) NOT NULL,
    [CreateDate] DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Organization_Name] PRIMARY KEY CLUSTERED ([Name] ASC)
);


GO

