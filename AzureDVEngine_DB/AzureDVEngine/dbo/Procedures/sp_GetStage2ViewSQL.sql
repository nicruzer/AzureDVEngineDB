
CREATE PROCEDURE [dbo].[sp_GetStage2ViewSQL]
AS
BEGIN
    DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)

    ;WITH RequiredColumns AS (
    SELECT vftcm.MapDenseRank, vftcm.SourceFQTableName, vftcm.SourceFullTableName,
        CASE WHEN vftcm.BKEYColumnCount > 1
            THEN 'CONCAT_WS(''|'', ' + STRING_AGG(CONCAT_WS(', ', 'ISNULL(' + QUOTENAME(vftcm.SourceColumnName), QUOTENAME(vftcm.ValueIfNull,'''')) + ')', ', ') WITHIN GROUP (ORDER BY vftcm.OrdinalPosition) + ')'
            ELSE STRING_AGG(CONCAT_WS(', ', 'ISNULL(' + QUOTENAME(vftcm.SourceColumnName), QUOTENAME(vftcm.ValueIfNull,'''')) + ')', '') WITHIN GROUP (ORDER BY vftcm.OrdinalPosition)
        END + ' AS ' + vftcm.TargetTableKey AS BKEYSQL,
        QUOTENAME(vftcm.RSRC, '''') + ' AS RSRC' AS RSRCSQL,
        'CURRENT_TIMESTAMP AT TIME ZONE ''UTC'' AT TIME ZONE ''Central Standard Time'' AS LDDTS' AS LDDTSSQL
    FROM stage2.vw_FullTableColumnMap vftcm 
    WHERE vftcm.BKEYColumnCount IS NOT NULL
    GROUP BY vftcm.MapDenseRank, vftcm.SourceFQTableName, vftcm.SourceFullTableName, vftcm.TargetTableKey, vftcm.BKEYColumnCount, vftcm.RSRC
    ), Columns AS (
    SELECT vftcm.MapDenseRank,
        STRING_AGG(
            QUOTENAME(vftcm.SourceColumnName)
            + CASE WHEN vftcm.SourceColumnName <> vftcm.TargetColumnName THEN ' AS ' + QUOTENAME(vftcm.TargetColumnName) ELSE '' END
            , ', '
        ) WITHIN GROUP (ORDER BY vftcm.OrdinalPosition) AS ColumnList,
        CASE WHEN vftcm.TargetEntityAbbreviation = 'SAT' THEN
            'CONVERT(BINARY(32),HASHBYTES(''SHA2_256'',UPPER(CONCAT_WS(''|'','
            + STRING_AGG(
                CONVERT(VARCHAR(MAX),'ISNULL('
                + CASE WHEN vftcm.IsSourceCharDataType = 0 THEN 'CONVERT(VARCHAR,' ELSE 'LTRIM(RTRIM(' END 
                + QUOTENAME(vftcm.SourceColumnName) 
                + CASE WHEN vftcm.IsSourceCharDataType = 0 THEN ')' ELSE '))' END
                + ','''')')
                , ', '
            ) WITHIN GROUP (ORDER BY vftcm.OrdinalPosition) 
            + ')))) AS HashDiff'
            ELSE NULL
        END AS HashDiffSQL
    FROM stage2.vw_FullTableColumnMap vftcm 
    WHERE vftcm.SourceColumnName = (
        CASE WHEN vftcm.TargetColumnAlias IS NOT NULL AND vftcm.TargetEntityAbbreviation = 'SAT' THEN NULL ELSE vftcm.SourceColumnName END
    )
    GROUP BY vftcm.MapDenseRank, vftcm.TargetEntityAbbreviation
    )

    SELECT 
        'CREATE OR ALTER VIEW [stage2].' + rc.SourceFullTableName + @NewLine
        + ' AS ' + @NewLine
        + 'SELECT ' + @NewLine
        + CONCAT_WS(
            ', ',
            rc.BKEYSQL,
            c.ColumnList,
            rc.RSRCSQL,
            rc.LDDTSSQL, 
            c.HashDiffSQL
        ) + @NewLine
        + ' FROM ' 
        + rc.SourceFQTableName
    FROM RequiredColumns rc 
        INNER JOIN Columns c ON rc.MapDenseRank = c.MapDenseRank
END
GO