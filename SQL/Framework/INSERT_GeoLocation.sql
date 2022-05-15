INSERT INTO dbo.GeoLocation ([Name])
    SELECT [Name] 
    FROM (VALUES
        ('ONLINE'),('USA')
        ) AS tbl([Name]) 
    WHERE NOT EXISTS (
        SELECT [Name]
        FROM dbo.GeoLocation gl 
        WHERE gl.[Name] = tbl.[Name]
    )

SELECT *
FROM dbo.GeoLocation