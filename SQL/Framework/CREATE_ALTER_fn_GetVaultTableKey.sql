CREATE OR ALTER FUNCTION dbo.fn_GetVaultTableKey
(
    @TableId INT
)
RETURNS VARCHAR(100)
AS 
BEGIN 
    DECLARE @VaultTableKey VARCHAR(100)
    
    SELECT @VaultTableKey = TargetTableKey
    FROM (
        SELECT DISTINCT TOP 1 tcm.TargetTableKey
        FROM dbo.vw_CurrentTableVersion ctv 
            INNER JOIN dbo.Tables t ON ctv.TableId = t.Id 
            INNER JOIN dbo.Columns c ON ctv.Id = c.TableVersionId
            INNER JOIN dbo.TableColumnMap tcm ON c.Id = tcm.TargetColumnId
        WHERE t.TableSchema = 'vault'
            AND tcm.IsBusinessKey = 1
            AND t.Id = @TableId
    ) tbl
            
    RETURN @VaultTableKey
END
GO


