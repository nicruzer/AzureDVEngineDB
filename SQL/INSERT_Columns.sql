/* insert into dbo.Columns (
    TableVersionId, ColumnName, DataType, CharacterMaxLength, DateNumPrecision,
    IsNullable, OrdinalPosition, Abbreviation
)
select tv.Id AS TableVersionId, c.ColumnName, c.DataType,
    c.CharacterMaxLength, c.DateNumPrecision, c.IsNullable, c.OrdinalPosition,
    'STG' AS Abbreviation
from dbo.Tables t 
    inner join dbo.TableVersion tv on t.Id = tv.TableId
    inner join stage1.columns c on t.TableSchema = c.TableSchema
        and t.TableName = c.TableName

 */

 SELECT DISTINCT TableSchema, TableName
 FROM stage1.columns c 

 SELECT *
 FROM dbo.Tables

select * from dbo.RecordSource

SELECT *
FROM dbo.vw_AbbreviationClass

SELECT * FROM dbo.Abbreviation ORDER BY AbbreviationClassTypeId

SELECT * FROM dbo.AbbreviationClassType ORDER BY Id