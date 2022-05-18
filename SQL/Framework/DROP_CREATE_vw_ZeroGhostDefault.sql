CREATE OR ALTER VIEW dbo.vw_ZeroGhostDefault
AS

WITH base AS (
    SELECT 'GhostRecord' AS RSRCType, '0' AS [Value]
    UNION
    SELECT 'Required', '-1'
    UNION
    SELECT 'Optional', '-2'
)

SELECT *, '1/1/1900' AS LDDTS
FROM base b
    CROSS APPLY (
        SELECT dbo.fn_GetRecordSource(Id) AS RSRC
        FROM dbo.RecordSource rs 
        WHERE rs.[Name] = b.RSRCType
    ) rsrctype