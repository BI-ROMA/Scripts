CREATE TABLE [Reports].[DetailReportSale] (
    [DateKey]         VARCHAR (30)     NULL,
    [ProductCode]     VARCHAR (20)     NULL,
    [ProductName]     VARCHAR (100)    NULL,
    [CategoryCode]    CHAR (3)         NULL,
    [CategoryName]    VARCHAR (100)    NULL,
    [SupplierCode]    VARCHAR (20)     NULL,
    [SupplierName]    VARCHAR (200)    NULL,
    [SupplierLogin]   VARCHAR (50)     NULL,
    [PartnerCode]     VARCHAR (15)     NULL,
    [PartnerName]     VARCHAR (100)    NULL,
    [SellerCode]      SMALLINT         NULL,
    [SellerName]      VARCHAR (100)    NOT NULL,
    [TerritoryCode]   VARCHAR (10)     NULL,
    [TerritoryName]   VARCHAR (100)    NULL,
    [InvoiceSequence] VARCHAR (10)     NULL,
    [InvoiceNumber]   VARCHAR (20)     NULL,
    [InvoiceType]     CHAR (2)         NULL,
    [Bonus]           VARCHAR (2)      NOT NULL,
    [Quantity]        DECIMAL (18, 5)  NOT NULL,
    [Price]           DECIMAL (38, 17) NULL,
    [Sale]            DECIMAL (18, 2)  NOT NULL
);


GO

