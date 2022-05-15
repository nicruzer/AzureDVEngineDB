;WITH tbl AS (
    SELECT *
    FROM (
        VALUES 
            ('ONLINE','GitHub','VeronikaSQL.SuperHero-DataVault.Data.marvel_search','JSON File'),
            ('ONLINE','GitHub','VeronikaSQL.SuperHero-DataVault.Data.superherodb','CSV'),
            ('ONLINE','Kaggle','jonathanbesomi/superheroes-nlp-dataset','CSV'),
            ('SYSTEM', 'DATA_VAULT', 'SYSTEM_DV', 'SYSTEM')
    ) tbl(GeoLocationName, OrganizationName, [Name], SourceTypeName)
)

MERGE dbo.RecordSource AS tgt
USING tbl AS src
    ON tgt.GeoLocationName = src.GeoLocationName
        AND tgt.OrganizationName = src.OrganizationName
        AND tgt.[Name] = src.[Name]
WHEN NOT MATCHED BY TARGET THEN
INSERT (GeoLocationName, OrganizationName, [Name], SourceTypeName)
    VALUES (src.GeoLocationName, src.OrganizationName, src.[Name], src.SourceTypeName)
OUTPUT $action, inserted.*;

GO

SELECT *
FROM dbo.RecordSource rs

SELECT * FROM dbo.GeoLocation
SELECT * FROM dbo.Organization
SELECT * FROM dbo.SourceType
GO

