CREATE TABLE [Zur].[ExtractorCustomers] (
    [SupplierCode]     VARCHAR (20)  NULL,
    [CompanyCode]      VARCHAR (20)  NULL,
    [CustomerCode]     VARCHAR (15)  NULL,
    [CustomerName]     VARCHAR (100) NULL,
    [DocumentType]     VARCHAR (3)   NOT NULL,
    [DocumentName]     VARCHAR (15)  NULL,
    [CustomerAddress]  VARCHAR (200) NULL,
    [Market]           VARCHAR (1)   NOT NULL,
    [Module]           VARCHAR (1)   NOT NULL,
    [ChannelName]      VARCHAR (100) NULL,
    [BussinessType]    VARCHAR (100) NULL,
    [BussinessSubType] VARCHAR (1)   NOT NULL,
    [Ubigeo]           VARCHAR (1)   NOT NULL,
    [Distrit]          VARCHAR (1)   NOT NULL,
    [Status]           VARCHAR (1)   NOT NULL,
    [X]                VARCHAR (1)   NOT NULL,
    [Y]                VARCHAR (1)   NOT NULL,
    [ParentCustomer]   VARCHAR (1)   NOT NULL,
    [IncomeDate]       DATE          NULL,
    [UpdateDate]       DATE          NULL,
    [ProcessDate]      DATETIME      NOT NULL,
    [Ref1]             VARCHAR (1)   NOT NULL,
    [Ref2]             VARCHAR (1)   NOT NULL,
    [Ref3]             VARCHAR (1)   NOT NULL,
    [Ref4]             VARCHAR (1)   NOT NULL,
    [Ref5]             VARCHAR (1)   NOT NULL,
    [Ref6]             VARCHAR (1)   NOT NULL,
    [Ref7]             VARCHAR (1)   NOT NULL,
    [Ref8]             VARCHAR (1)   NOT NULL,
    [Ref9]             VARCHAR (1)   NOT NULL,
    [Ref10]            VARCHAR (1)   NOT NULL
);


GO

