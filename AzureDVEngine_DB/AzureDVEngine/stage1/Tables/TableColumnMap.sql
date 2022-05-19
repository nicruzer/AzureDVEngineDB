CREATE TABLE [stage1].[TableColumnMap] (
    [SourceColumnId]              NVARCHAR (MAX) NULL,
    [SourceSchema]                NVARCHAR (MAX) NULL,
    [SourceTable]                 NVARCHAR (MAX) NULL,
    [SourceColumn]                NVARCHAR (MAX) NULL,
    [OrdinalPosition]             NVARCHAR (MAX) NULL,
    [TargetTableName]             NVARCHAR (MAX) NULL,
    [TargetTableColumn]           NVARCHAR (MAX) NULL,
    [IsBusinessKey]               NVARCHAR (MAX) NULL,
    [TargetEntityAbbreviation]    NVARCHAR (MAX) NULL,
    [TargetColumnOrdinalPosition] NVARCHAR (MAX) NULL,
    [TargetColumnAlias]           NVARCHAR (MAX) NULL,
    [TargetTableKey]              NVARCHAR (MAX) NULL
);


GO

