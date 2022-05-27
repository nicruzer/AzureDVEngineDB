CREATE OR ALTER FUNCTION dbo.fn_GetVaultTableName
(
    @TableId INT,
    @WithSchema BIT = 0,
    @Quoted BIT = 0
)
RETURNS VARCHAR(1000)
AS
BEGIN
    DECLARE @VaultTableName VARCHAR(1000)

    ;WITH base AS (
        SELECT 
            t.TableSchema,
            CONCAT_WS('_',t.Abbreviation, t.TableName) AS TableName
        FROM dbo.Tables t 
        WHERE t.Id = @TableId
            AND t.TableSchema = 'vault' -- Ensure only vault tables are used, even when a non-vault ID is passed in
    )

    SELECT @VaultTableName = 
        CASE WHEN @Quoted = 1
            THEN CASE WHEN @WithSchema = 1
                    THEN CONCAT_WS('.',QUOTENAME(b.TableSchema),QUOTENAME(b.TableName))
                    ELSE QUOTENAME(b.TableName)
                END
            ELSE 
                CASE WHEN @WithSchema = 1
                    THEN CONCAT_WS('.',b.TableSchema,b.TableName)
                    ELSE b.TableName
                END 
        END
    FROM base b

    RETURN @VaultTableName
END
GO

/* -- All of the various possibilities
SELECT 
    dbo.fn_GetVaultTableName(225,0,0) AS SimpleTableName, 
    dbo.fn_GetVaultTableName(225,0,1) AS QuotedTableName, 
    dbo.fn_GetVaultTableName(225,1,0) AS FQSimpleTableName, 
    dbo.fn_GetVaultTableName(225,1,1) AS FQQuotedTableName
*/