SELECT 
    DENSE_RANK() OVER (ORDER BY tgtftc.FQTableName, srcftc.FQTableName) AS MapDenseRank,
    srcftc.TableSchema AS SourceTableSchema,
    srcftc.TableName AS SourceTableName,
    srcftc.ColumnName AS SourceColumnName,
    CASE WHEN srcftc.DataType LIKE '%CHAR%' THEN 1 ELSE 0 END AS IsSourceCharDataType,
    srcftc.FQTableName AS SourceFQTableName,
    srcftc.FullTableName AS SourceFullTableName,
    CASE WHEN tcm.IsBusinessKey = 1 THEN 
        COUNT(srcftc.ColumnName) OVER (PARTITION BY tgtftc.TableName, srcftc.TableName, tcm.TargetTableKey ORDER BY (SELECT NULL))
    END AS BKEYColumnCount,
    tcm.IsBusinessKey, tcm.IsDrivingKey, tcm.IsDependentChild, tcm.TargetColumnAlias, tcm.TargetTableKey,
    CASE 
        WHEN tcm.IsBusinessKey = 1 AND tgtftc.EntityAbbreviation = 'LINK' THEN 
            CASE WHEN tcm.IsDrivingKey = 1
                THEN '-1'
                ELSE '-2'
            END
        WHEN tcm.IsBusinessKey = 1 AND tgtftc.EntityAbbreviation <> 'LINK' THEN '-1'
        ELSE NULL
    END AS ValueIfNull,
    srcftc.RSRC,
    tgtftc.TableSchema AS TargetTableSchema,
    tgtftc.TableName AS TargetTableName,
    tgtftc.ColumnName AS TargetColumnName,
    tgtftc.FQTableName AS TargetFQTableName,
    tgtftc.EntityAbbreviation AS TargetEntityAbbreviation,
    tgtftc.OrdinalPosition
    -- , *
FROM dbo.TableColumnMap tcm
    INNER JOIN dbo.vw_FullTableColumns srcftc ON tcm.SourceColumnId = srcftc.ColumnId
    INNER JOIN dbo.vw_FullTableColumns tgtftc ON tcm.TargetColumnId = tgtftc.ColumnId
-- ORDER BY tgtftc.TableId, srcftc.TableId, tgtftc.OrdinalPosition