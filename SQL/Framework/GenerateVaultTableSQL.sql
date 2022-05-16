;WITH vaultTables AS (
    SELECT --ftc.TableSchema,
        dbo.fn_GetVaultTableName(ftc.TableId,0,0) AS SimpleTableName, 
        dbo.fn_GetVaultTableName(ftc.TableId,0,1) AS QuotedTableName, 
        dbo.fn_GetVaultTableName(ftc.TableId,1,0) AS FQSimpleTableName, 
        dbo.fn_GetVaultTableName(ftc.TableId,1,1) AS FQQuotedTableName,
        ftc.*
    FROM dbo.vw_FullTableColumns ftc
    WHERE ftc.TableSchema = 'vault'
)

SELECT *
FROM vaultTables vt
ORDER BY vt.TableId, vt.OrdinalPosition

