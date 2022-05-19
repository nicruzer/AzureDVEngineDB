CREATE   FUNCTION dbo.fn_GetRecordSource
(
    @RecordSourceId INT = -1
) 
RETURNS VARCHAR(1000)
AS 

BEGIN
    DECLARE @return VARCHAR(1000)

    SET @return = (SELECT TOP 1 CONCAT_WS('::', GeoLocationName, OrganizationName, [Name], SourceTypeName) AS RecordSource
        FROM dbo.RecordSource rs 
        WHERE rs.Id = @RecordSourceId
    )

    RETURN @return
END

GO

