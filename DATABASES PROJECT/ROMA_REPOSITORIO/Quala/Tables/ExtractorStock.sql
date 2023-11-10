CREATE TABLE [Quala].[ExtractorStock] (
    [ProductCode] VARCHAR (20)    NULL,
    [ProductName] VARCHAR (100)   NULL,
    [Unit]        VARCHAR (3)     NOT NULL,
    [Quantity]    DECIMAL (24, 2) NULL,
    [Date]        VARCHAR (30)    NULL,
    [CompanyCode] VARCHAR (2)     NOT NULL,
    [Period]      CHAR (6)        NULL
);


GO

