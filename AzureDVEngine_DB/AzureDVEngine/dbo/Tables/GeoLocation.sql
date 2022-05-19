CREATE TABLE [dbo].[GeoLocation] (
    [Name]       VARCHAR (60) NOT NULL,
    [CreateDate] DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_GeoLocation_Name] PRIMARY KEY CLUSTERED ([Name] ASC)
);


GO

