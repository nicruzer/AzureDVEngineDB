CREATE OR ALTER VIEW dbo.vw_GhostValue
AS 
    SELECT *,
        CASE 
            WHEN TYPE_NAME LIKE '%date%' THEN CONCAT(LITERAL_PREFIX,'1/1/1900',LITERAL_SUFFIX)
            ELSE CONVERT(VARCHAR,ISNULL(ISNULL(LITERAL_PREFIX + LITERAL_SUFFIX, LITERAL_PREFIX + '0'),'0'))
        END AS GHOST_VALUE
    FROM dbo.DataTypeGhostValues
GO