;WITH vaultTables AS (
    SELECT DISTINCT ftc.TableSchema,
        dbo.fn_GetVaultTableName(ftc.TableId,0,0) AS SimpleTableName, 
        dbo.fn_GetVaultTableName(ftc.TableId,0,1) AS QuotedTableName, 
        dbo.fn_GetVaultTableName(ftc.TableId,1,0) AS FQSimpleTableName, 
        dbo.fn_GetVaultTableName(ftc.TableId,1,1) AS FQQuotedTableName,
        dbo.fn_GetVaultTableKey(ftc.TableId) AS VaultTableKey
    FROM dbo.vw_FullTableColumns ftc
    WHERE ftc.TableSchema = 'vault'
)

SELECT *
FROM vaultTables vt

