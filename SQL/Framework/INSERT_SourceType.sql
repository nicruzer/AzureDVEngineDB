-- Set up SourceTypes

INSERT INTO dbo.SourceType ([Name])
SELECT [Name]
FROM 
    (VALUES ('SQL Server'),('JSON File'),
            ('CSV'),('Tab Delimited')) AS tbl([Name])
WHERE NOT EXISTS (
    SELECT [Name]
    FROM dbo.SourceType st 
    WHERE st.Name = tbl.Name
)
