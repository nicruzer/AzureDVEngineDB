CREATE   VIEW dbo.vw_CurrentTableVersion
AS 

    WITH CurrentTableVersion AS (
    SELECT *,
        FIRST_VALUE(tv.Id) OVER (PARTITION BY tv.TableId ORDER BY tv.Major DESC, tv.Minor DESC, tv.Release DESC) AS CurrentId
    FROM dbo.TableVersion tv 
)

SELECT ctv.Id, ctv.TableId, ctv.Major, ctv.Minor, ctv.Release
FROM CurrentTableVersion ctv 
WHERE ctv.Id = ctv.CurrentId

GO

