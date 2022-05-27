INSERT INTO dbo.Organization ([Name])
    SELECT [Name] 
    FROM (VALUES
        ('GitHub'), ('Kaggle')
        ) AS tbl([Name])
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.Organization o
        WHERE o.[Name] = tbl.[Name]
        )

SELECT *
FROM dbo.Organization