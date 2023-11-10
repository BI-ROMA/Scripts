CREATE TABLE [Reports].[DetailReportStock] (
    [SupplierCode]  VARCHAR (20)    NULL,
    [SupplierName]  VARCHAR (200)   NULL,
    [SupplierLogin] VARCHAR (50)    NULL,
    [ProductCode]   VARCHAR (20)    NULL,
    [ProductName]   VARCHAR (100)   NULL,
    [Piece]         VARCHAR (3)     NOT NULL,
    [ValuatedStock] DECIMAL (38, 2) NULL,
    [Ayacucho]      DECIMAL (38, 2) NULL,
    [Chincha]       DECIMAL (38, 2) NULL,
    [Ica]           DECIMAL (38, 2) NULL,
    [total]         DECIMAL (38, 2) NULL
);


GO

