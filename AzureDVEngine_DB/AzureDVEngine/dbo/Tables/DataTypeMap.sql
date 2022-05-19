CREATE TABLE [dbo].[DataTypeMap] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [SourceTypeName] VARCHAR (60)  NOT NULL,
    [SourceDataType] VARCHAR (255) NOT NULL,
    [TargetDataType] VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_DataTypeMap_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [DataTypeMap_index_5]
    ON [dbo].[DataTypeMap]([SourceTypeName] ASC, [SourceDataType] ASC);


GO

