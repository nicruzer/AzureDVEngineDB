CREATE OR ALTER VIEW dbo.vw_AbbreviationClass
AS 

    SELECT a.AbbreviationClassTypeId, act.Class, act.[Type], a.[Value],
        a.Style, act.IsPrefixed
    FROM dbo.Abbreviation a 
        INNER JOIN dbo.AbbreviationClassType act ON a.AbbreviationClassTypeId = act.Id

GO

