CREATE TABLE [Quala].[ExtractorSales] (
    [NumberInvoice]  VARCHAR (30)    NOT NULL,
    [ProductCode]    VARCHAR (20)    NULL,
    [ProductName]    VARCHAR (100)   NULL,
    [Unit]           VARCHAR (3)     NOT NULL,
    [Sale]           DECIMAL (18, 2) NOT NULL,
    [Quantity]       DECIMAL (18, 5) NOT NULL,
    [CustomerCode]   SMALLINT        NULL,
    [CustomerName]   VARCHAR (100)   NOT NULL,
    [SupervisorCode] NVARCHAR (8)    COLLATE SQL_Latin1_General_CP850_CI_AS NOT NULL,
    [SupervisorName] NVARCHAR (120)  COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [PartnerCode]    VARCHAR (15)    NULL,
    [Date]           VARCHAR (30)    NULL,
    [CompanyCode]    VARCHAR (2)     NOT NULL,
    [Period]         CHAR (6)        NULL
);


GO

