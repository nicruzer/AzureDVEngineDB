IF OBJECT_ID('stage1.marvel_search') IS NOT NULL
    BEGIN
        TRUNCATE TABLE [stage1].[marvel_search]
    END
ELSE
    BEGIN
        SET ANSI_NULLS ON
        SET QUOTED_IDENTIFIER ON

        CREATE TABLE [stage1].[marvel_search]
        ( 
            [aliases] [nvarchar](max)  NULL,
            [authors] [nvarchar](max)  NULL,
            [description] [varchar](256)  NULL,
            [images] [nvarchar](max)  NULL,
            [name] [varchar](256)  NULL,
            [partners] [nvarchar](max)  NULL,
            [powers] [nvarchar](max)  NULL,
            [ranking] [nvarchar](max)  NULL,
            [secretIdentities] [nvarchar](max)  NULL,
            [species] [nvarchar](max)  NULL,
            [superName] [varchar](256)  NULL,
            [teams] [nvarchar](max)  NULL,
            [urls] [nvarchar](max)  NULL
        )
    END
GO

CREATE TABLE stage1.marvel_json_raw
(
    doc NVARCHAR(MAX)
)

-- Use master
select name, is_master_key_encrypted_by_server from sys.databases

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Tkabk37!'
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'Tkabk37!'
ALTER MASTER KEY ADD ENCRYPTION BY SERVICE MASTER KEY

CREATE DATABASE SCOPED CREDENTIAL ADV_ABSC
WITH IDENTITY = 'MANAGED IDENTITY'
-- ,SECRET = 'sv=2020-08-04&ss=bfqt&srt=sco&sp=rwdlacupx&se=2022-04-27T10:23:10Z&st=2022-04-27T02:23:10Z&spr=https&sig=O8bfckVTlgDkKmcrbsGZLdCBbE9h1%2FGdXa7%2FatnshnI%3D'

CREATE EXTERNAL DATA SOURCE ADV_EDS
WITH (
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://synapsedvdemo.blob.core.windows.net/synapsedvdemo',
    CREDENTIAL = ADV_ABSC
)

BULK INSERT stage1.marvel_json_raw
FROM 'Data/marvel_search/8-Ball_(comics).json'
WITH (  DATA_SOURCE = 'ADV_EDS' )

CREATE USER [nicruzer@msn.com] FROM EXTERNAL PROVIDER
ALTER ROLE [db_owner] ADD MEMBER [nicruzer@msn.com]
CREATE USER [ADV_SuperUsers] FROM EXTERNAL PROVIDER
CREATE USER [azuredv] FROM EXTERNAL PROVIDER
GRANT CONTROL ON DATABASE::AzureDVEngine TO [nicruzer@msn.com]

select *
from OPENROWSET (
    BULK 'Data/marvel_search/8-Ball_(comics).json',
    DATA_SOURCE = 'ADV_EDS',
    SINGLE_CLOB
) AS J

insert into stage1.marvel_json_raw
select * from #tmp

SELECT * FROM stage1.marvel_json_raw