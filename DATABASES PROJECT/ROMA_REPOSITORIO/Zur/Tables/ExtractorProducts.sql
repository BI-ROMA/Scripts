CREATE TABLE [Zur].[ExtractorProducts] (
    [SupplierCode] VARCHAR (20)    NULL,
    [CompanyCode]  VARCHAR (20)    NULL,
    [ProductCode]  VARCHAR (20)    NULL,
    [ProductName]  VARCHAR (100)   NULL,
    [EAN]          VARCHAR (1)     NOT NULL,
    [DUN]          VARCHAR (1)     NOT NULL,
    [BoxFactor]    SMALLINT        NULL,
    [Weight]       DECIMAL (18, 4) NULL,
    [FlagBonus]    VARCHAR (1)     NOT NULL,
    [Tax]          VARCHAR (1)     NOT NULL,
    [BuyPrice]     DECIMAL (18, 4) NULL,
    [SalePrice]    DECIMAL (18, 4) NULL,
    [AveragePrice] DECIMAL (21, 6) NULL,
    [ProcessDate]  DATETIME        NOT NULL,
    [Ref1]         VARCHAR (1)     NOT NULL,
    [Ref2]         VARCHAR (1)     NOT NULL,
    [Ref3]         VARCHAR (1)     NOT NULL,
    [Ref4]         VARCHAR (1)     NOT NULL,
    [Ref5]         VARCHAR (1)     NOT NULL,
    [Ref6]         VARCHAR (1)     NOT NULL,
    [Ref7]         VARCHAR (1)     NOT NULL,
    [Ref8]         VARCHAR (1)     NOT NULL,
    [Ref9]         VARCHAR (1)     NOT NULL,
    [Ref10]        VARCHAR (1)     NOT NULL
);


GO

