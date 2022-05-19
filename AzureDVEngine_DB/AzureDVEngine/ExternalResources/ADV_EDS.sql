CREATE EXTERNAL DATA SOURCE [ADV_EDS]
    WITH (
    TYPE = BLOB_STORAGE,
    LOCATION = N'https://synapsedvdemo.blob.core.windows.net/synapsedvdemo',
    CREDENTIAL = [ADV_ABSC]
    );


GO

