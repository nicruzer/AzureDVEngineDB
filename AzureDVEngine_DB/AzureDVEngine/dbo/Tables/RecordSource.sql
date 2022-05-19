CREATE TABLE [dbo].[RecordSource] (
    [Id]               INT          IDENTITY (1, 1) NOT NULL,
    [GeoLocationName]  VARCHAR (60) NOT NULL,
    [OrganizationName] VARCHAR (60) NOT NULL,
    [Name]             VARCHAR (60) NOT NULL,
    [SourceTypeName]   VARCHAR (60) NOT NULL,
    [CreateDate]       DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_RecordSource_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_GeoLocation_Name] FOREIGN KEY ([GeoLocationName]) REFERENCES [dbo].[GeoLocation] ([Name]) ON DELETE CASCADE,
    CONSTRAINT [FK_Organization_Name] FOREIGN KEY ([OrganizationName]) REFERENCES [dbo].[Organization] ([Name]) ON DELETE CASCADE,
    CONSTRAINT [FK_SourceType_Name] FOREIGN KEY ([SourceTypeName]) REFERENCES [dbo].[SourceType] ([Name]) ON DELETE CASCADE
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [RecordSource_index_1]
    ON [dbo].[RecordSource]([GeoLocationName] ASC, [OrganizationName] ASC, [Name] ASC);


GO

