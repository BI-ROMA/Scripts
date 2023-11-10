CREATE TABLE [Zur].[ExtractorStock] (
    [SupplierCode]          VARCHAR (20)    NULL,
    [CompanyCode]           VARCHAR (20)    NULL,
    [WarehouseCode]         VARCHAR (10)    NULL,
    [WarehouseName]         VARCHAR (50)    NULL,
    [ProductCode]           VARCHAR (20)    NULL,
    [Lot]                   VARCHAR (1)     NOT NULL,
    [DueDate]               VARCHAR (1)     NOT NULL,
    [StockMinUnit]          INT             NULL,
    [UnitMin]               VARCHAR (3)     NOT NULL,
    [StockMaxUnit]          INT             NULL,
    [UnitMax]               VARCHAR (3)     NOT NULL,
    [ValuedStock]           DECIMAL (18, 4) NULL,
    [ProcessDate]           DATETIME        NULL,
    [IncomeConsumptionUnit] INT             NOT NULL,
    [IncomeValues]          DECIMAL (18, 4) NULL,
    [SalesConsumptionUnit]  INT             NOT NULL,
    [SalesValues]           DECIMAL (18, 4) NULL,
    [OtherConsuMptionUnit]  INT             NOT NULL,
    [OtherValues]           DECIMAL (18, 4) NULL,
    [Period]                VARCHAR (6)     NULL,
    [Ref1]                  VARCHAR (1)     NOT NULL,
    [Ref2]                  VARCHAR (1)     NOT NULL,
    [Ref3]                  VARCHAR (1)     NOT NULL,
    [Ref4]                  VARCHAR (1)     NOT NULL,
    [Ref5]                  VARCHAR (1)     NOT NULL,
    [Ref6]                  VARCHAR (1)     NOT NULL,
    [Ref7]                  VARCHAR (1)     NOT NULL,
    [Ref8]                  VARCHAR (1)     NOT NULL,
    [Ref9]                  VARCHAR (1)     NOT NULL,
    [Ref10]                 VARCHAR (1)     NOT NULL
);


GO

