CREATE OR ALTER FUNCTION [dbo].[fn_GetStage2SQL]()
RETURNS @StageTwoViewSQL TABLE 
(
    Stage2ViewDropSQL VARCHAR(MAX),
    Stage2ViewCreateSQL VARCHAR(MAX),
    Stage2TableDropSQL VARCHAR(MAX),
    Stage2TableCreateSQL VARCHAR(MAX)
)
AS
BEGIN
    DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)

    ;WITH RequiredColumns AS (
        SELECT DISTINCT vftcm.MapDenseRank, vftcm.SourceFQTableName, vftcm.SourceFullTableName,
            CASE WHEN vftcm.BKEYColumnCount > 1
                THEN 'CONCAT_WS(''|'', ' + STRING_AGG(CONCAT_WS(', ', 'ISNULL(' + QUOTENAME(vftcm.SourceColumnName), QUOTENAME(vftcm.ValueIfNull,'''')) + ')', ', ') WITHIN GROUP (ORDER BY vftcm.OrdinalPosition) + ')'
                ELSE STRING_AGG(CONCAT_WS(', ', 'ISNULL(' + QUOTENAME(vftcm.SourceColumnName), QUOTENAME(vftcm.ValueIfNull,'''')) + ')', '') WITHIN GROUP (ORDER BY vftcm.OrdinalPosition)
            END + ' AS ' + vftcm.TargetTableKey AS BKEYSQL,
            QUOTENAME(vftcm.RSRC, '''') + ' AS RSRC' AS RSRCSQL,
            'CURRENT_TIMESTAMP AT TIME ZONE ''UTC'' AT TIME ZONE ''Central Standard Time'' AS LDDTS' AS LDDTSSQL
        FROM stage2.vw_FullTableColumnMap vftcm 
        WHERE vftcm.BKEYColumnCount IS NOT NULL
        GROUP BY vftcm.MapDenseRank, vftcm.SourceFQTableName, vftcm.SourceFullTableName, vftcm.TargetTableKey, vftcm.BKEYColumnCount, vftcm.RSRC
    ), DistinctRequiredColumns AS (
        SELECT DISTINCT rc.SourceFQTableName, rc.SourceFullTableName,
            STRING_AGG(
                rc.BKEYSQL,
                ', '
            ) WITHIN GROUP (ORDER BY rc.MapDenseRank) AS BKEYSQL,
            rc.RSRCSQL,
            rc.LDDTSSQL
        FROM RequiredColumns rc
        WHERE rc.MapDenseRank IN (
            SELECT MIN(MapDenseRank)
            FROM RequiredColumns rc2
            GROUP BY rc2.SourceFQTableName, rc2.SourceFullTableName, rc2.BKEYSQL
        )
        GROUP BY rc.SourceFQTableName, rc.SourceFullTableName, rc.RSRCSQL, rc.LDDTSSQL
    ), SourceColumnList AS (
        SELECT DISTINCT 
            vftcm.SourceFQTableName,
            vftcm.SourceFullTableName,
            CASE WHEN vftcm.SourceColumnName <> vftcm.TargetColumnName
                THEN CONCAT_WS(' AS ', QUOTENAME(vftcm.SourceColumnName), QUOTENAME(vftcm.TargetColumnName))
                ELSE QUOTENAME(vftcm.SourceColumnName)
            END AS SourceColumnName,
            vftcm.SourceColumnName AS HashSourceColumnName,
            vftcm.IsSourceCharDataType,
            vftcm.TargetColumnAlias,
            MIN(vftcm.OrdinalPosition) OVER (PARTITION BY vftcm.SourceFQTableName, vftcm.SourceFullTableName, vftcm.TargetColumnName) AS OrdinalPosition,
            MAX(CONVERT(INT,vftcm.IsBusinessKey)) OVER (PARTITION BY vftcm.SourceFQTableName, vftcm.SourceFullTableName, vftcm.TargetColumnName) AS IsBusinessKey
        FROM stage2.vw_FullTableColumnMap vftcm
    ), ColumnList AS (
        SELECT scl.SourceFQTableName, scl.SourceFullTableName,
            STRING_AGG(
                scl.SourceColumnName,
                ', '
            ) WITHIN GROUP (ORDER BY scl.OrdinalPosition) AS ColumnList
        FROM SourceColumnList scl
        GROUP BY scl.SourceFQTableName, scl.SourceFullTableName
    ), HashDiff AS (
        SELECT scl.SourceFQTableName, scl.SourceFullTableName,
            'CONVERT(BINARY(32),HASHBYTES(''SHA2_256'',UPPER(CONCAT_WS(''|'','
            + STRING_AGG(
                CONVERT(VARCHAR(MAX),'ISNULL('
                + CASE WHEN scl.IsSourceCharDataType = 0 THEN 'CONVERT(VARCHAR,' ELSE 'LTRIM(RTRIM(' END 
                + QUOTENAME(scl.HashSourceColumnName) 
                + CASE WHEN scl.IsSourceCharDataType = 0 THEN ')' ELSE '))' END
                + ','''')')
                , ', '
            ) WITHIN GROUP (ORDER BY scl.OrdinalPosition) 
            + ')))) AS HashDiff'
            AS HashDiff
        FROM SourceColumnList scl 
        WHERE scl.IsBusinessKey  = 0
        GROUP BY scl.SourceFQTableName, scl.SourceFullTableName
    )

    INSERT INTO @StageTwoViewSQL
    SELECT 
        'IF OBJECT_ID(''[stage2].' + rc.SourceFullTableName + ''') IS NOT NULL DROP VIEW [stage2].' + rc.SourceFullTableName + ';' 
        AS Stage2ViewDropSQL,
        'CREATE VIEW [stage2].' + rc.SourceFullTableName + @NewLine
        + ' AS ' + @NewLine
        + 'SELECT ' + @NewLine
        + CONCAT_WS(
            ', ',
            rc.BKEYSQL,
            cL.ColumnList,
            rc.RSRCSQL,
            rc.LDDTSSQL, 
            hd.HashDiff
        ) + @NewLine
        + ' FROM ' 
        + rc.SourceFQTableName
        AS Stage2ViewCreateSQL,
        'IF OBJECT_ID(''[stage2].' + REPLACE(rc.SourceFullTableName,'VW_','') + ''') IS NOT NULL DROP TABLE [stage2].' + REPLACE(rc.SourceFullTableName,'VW_','') + ';' 
        AS Stage2TableDropSQL,
        'IF OBJECT_ID(''[stage2].' + rc.SourceFullTableName + ''') IS NOT NULL ' + @NewLine
        + ' CREATE TABLE [stage2].' + REPLACE(rc.SourceFullTableName,'VW_','') + ' WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS ' + @NewLine
        + ' SELECT * FROM [stage2].' + rc.SourceFullTableName + '; '
        AS Stage2TableCreateSQL
    FROM DistinctRequiredColumns rc 
        INNER JOIN ColumnList cl ON rc.SourceFQTableName = cl.SourceFQTableName
            AND rc.SourceFullTableName = cl.SourceFullTableName
        LEFT JOIN HashDiff hd ON rc.SourceFQTableName = hd.SourceFQTableName
            AND rc.SourceFullTableName = hd.SourceFullTableName

RETURN
END 

GO
