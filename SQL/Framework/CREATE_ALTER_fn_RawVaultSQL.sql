CREATE OR ALTER FUNCTION [dbo].[fn_RawVaultSQL]()
RETURNS @StageTwoViewSQL TABLE 
(
    SourceView VARCHAR(512), 
    TargetView VARCHAR(512), 
    TargetFQTableName VARCHAR(512), 
    TargetTableKey VARCHAR(256), 
    TargetEntityAbbreviation VARCHAR(10),
    DropTargetViewSQL VARCHAR(8000),
    CreateTargetViewSQL VARCHAR(8000),
    InsertVaultTableSQL VARCHAR(8000)
)
AS
BEGIN

    DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10)

    ;WITH ColumnList AS (
        SELECT vftc.TableId,
            vftc.TableVersionId,
            vftc.FQTableName,
            PARSENAME(vftc.FullTableName,1) AS FullTableName,

            CONCAT_WS(
                ', ',
                CONCAT_WS('.','STG',dbo.fn_GetVaultTableKey(vftc.TableId)),
                STRING_AGG(
                    CONCAT_WS('.','STG', QUOTENAME(
                        CASE WHEN vftc.ColumnName = LinkAlias.TargetColumnName
                            THEN LinkAlias.TargetColumnAlias
                            ELSE vftc.ColumnName
                        END
                    )),
                    ', '
                ) WITHIN GROUP (ORDER BY vftc.OrdinalPosition),
                'STG.RSRC',
                'CURRENT_TIMESTAMP AT TIME ZONE ''UTC'' AT TIME ZONE ''Central Standard Time'' AS LDDTS',
                CASE WHEN vftc.EntityAbbreviation = 'SAT' THEN 'STG.HashDiff' ELSE NULL END
            )
            AS SourceColumnList,

            CONCAT_WS(
                ', ',
                dbo.fn_GetVaultTableKey(vftc.TableId),
                STRING_AGG(
                    QUOTENAME(
                        CASE WHEN vftc.ColumnName = LinkAlias.TargetColumnName
                            THEN LinkAlias.TargetColumnAlias
                            ELSE vftc.ColumnName
                        END
                    ),
                    ', '
                ) WITHIN GROUP (ORDER BY vftc.OrdinalPosition),
                'RSRC',
                'LDDTS',
                CASE WHEN vftc.EntityAbbreviation = 'SAT' THEN 'HashDiff' ELSE NULL END
            )
            AS TargetColumnList
        FROM dbo.vw_FullTableColumns vftc 
            OUTER APPLY (
                SELECT DISTINCT TargetColumnAlias, TargetColumnName
                FROM stage2.vw_FullTableColumnMap vftcm
                WHERE vftc.FQTableName = vftcm.TargetFQTableName
                    AND vftc.ColumnName = vftcm.TargetColumnName
                    AND vftc.EntityAbbreviation = 'LINK'
            ) LinkAlias
        WHERE vftc.TableSchema = 'vault'
            AND vftc.ColumnName = CASE WHEN vftc.AttributeAbbreviation = 'BKEY' AND vftc.EntityAbbreviation = 'SAT' THEN NULL ELSE vftc.ColumnName END
        GROUP BY vftc.TableId, vftc.TableVersionId, vftc.FQTableName, vftc.FullTableName, vftc.EntityAbbreviation
    ), SQLElements AS (
        SELECT DISTINCT 
            CONCAT_WS('.',QUOTENAME('stage2'),ftcm.SourceFullTableName) AS SourceView,
            '[stage2].' + QUOTENAME(CONCAT_WS('_','rv',PARSENAME(ftcm.SourceFullTableName,1),PARSENAME(ftcm.TargetFQTableName,1))) AS TargetView,
            ftcm.TargetFQTableName,
            ftcm.TargetTableKey,
            ftcm.TargetEntityAbbreviation,
            cl.SourceColumnList,
            cl.TargetColumnList,
            ' WHERE ' +
            CASE 
                WHEN ftcm.TargetEntityAbbreviation IN ('HUB','LINK')
                    THEN CONCAT_WS('.', ftcm.TargetEntityAbbreviation, ftcm.TargetTableKey) + ' IS NULL'
                WHEN ftcm.TargetEntityAbbreviation = 'SAT'
                    THEN CONCAT_WS('.', ftcm.TargetEntityAbbreviation, ftcm.TargetTableKey) + ' IS NULL'
                        + ' OR ('
                        + CONCAT_WS('.', 'STG', ftcm.TargetTableKey) + ' = ' + CONCAT_WS('.', ftcm.TargetEntityAbbreviation, ftcm.TargetTableKey) 
                        + ' AND ('
                        + CONCAT_WS('.', 'STG', 'HashDiff') + ' != ' + CONCAT_WS('.', ftcm.TargetEntityAbbreviation, 'HashDiff') 
                        + '))'
                ELSE ''
            END
            AS PredicateSQL,
            ' ON ' +
            CASE
                WHEN ftcm.TargetEntityAbbreviation IN ('HUB','LINK')
                    THEN CONCAT_WS('.','STG',ftcm.TargetTableKey) + ' = ' + CONCAT_WS('.',ftcm.TargetEntityAbbreviation,ftcm.TargetTableKey) + ' COLLATE DATABASE_DEFAULT '
                WHEN ftcm.TargetEntityAbbreviation = 'SAT'
                    THEN '('
                        + CONCAT_WS('.','STG',ftcm.TargetTableKey) + ' = ' + CONCAT_WS('.',ftcm.TargetEntityAbbreviation,ftcm.TargetTableKey) + ' COLLATE DATABASE_DEFAULT ' + @NewLine
                        + ' AND ' + CONCAT_WS('.',ftcm.TargetEntityAbbreviation,'LDDTS') 
                        + ' = '
                        + '('
                        + 'SELECT MAX(z.LDDTS) FROM '
                        + ftcm.TargetFQTableName + ' AS z ' + @NewLine
                        + ' WHERE ' + CONCAT_WS('.',ftcm.TargetEntityAbbreviation,ftcm.TargetTableKey) + ' = ' + CONCAT_WS('.','z',ftcm.TargetTableKey)
                        + '))'
            END
            AS OnSQL
        FROM stage2.vw_FullTableColumnMap ftcm
            INNER JOIN ColumnList cl ON ftcm.TargetFQTableName = cl.FQTableName
        WHERE ftcm.TargetTableKey IS NOT NULL
    )

    INSERT @StageTwoViewSQL
    SELECT 
        se.SourceView, se.TargetView, se.TargetFQTableName, se.TargetTableKey, se.TargetEntityAbbreviation,

        'IF OBJECT_ID(''' + se.TargetView + ''') IS NOT NULL DROP VIEW ' + se.TargetView + '; ' 
        AS DropTargetViewSQL,

        'CREATE VIEW ' + se.TargetView + ' AS ' + @NewLine
        + 'SELECT DISTINCT ' + @NewLine
        + se.SourceColumnList + @NewLine
        + ' FROM ' + CONCAT_WS(' AS ',se.SourceView, 'STG') + @NewLine
        + ' LEFT OUTER JOIN ' + CONCAT_WS(' AS ', se.TargetFQTableName, se.TargetEntityAbbreviation) + @NewLine
        + se.OnSQL + @NewLine
        + se.PredicateSQL
        AS CreateTargetViewSQL,

        'INSERT INTO ' + se.TargetFQTableName + @NewLine
        + ' (' + se.TargetColumnList + ') ' + @NewLine
        + ' SELECT ' + se.TargetColumnList + @NewLine
        + ' FROM ' + se.TargetView + '; '
        AS InsertVaultTableSQL
    FROM SQLElements se

RETURN
END

GO