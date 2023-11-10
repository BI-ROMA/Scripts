CREATE TABLE [Reports].[JSONCommissions] (
    [Period]     VARCHAR (6)    NULL,
    [Username]   VARCHAR (100)  NULL,
    [SellerCode] SMALLINT       NULL,
    [TypeUser]   VARCHAR (2)    NOT NULL,
    [data_json]  NVARCHAR (MAX) NULL
);


GO

