CREATE TABLE [Reports].[DeprodecaVisiCoolerComercial] (
    [Period]              INT              NOT NULL,
    [CustomerCode]        NVARCHAR (15)    COLLATE SQL_Latin1_General_CP850_CI_AS NOT NULL,
    [CustomerName]        NVARCHAR (100)   COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [NameCategory]        VARCHAR (50)     NULL,
    [CustomerAddress]     NVARCHAR (100)   COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [CustomerAddressCode] VARCHAR (10)     COLLATE SQL_Latin1_General_CP850_CI_AS NOT NULL,
    [BrandName]           VARCHAR (100)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [PortfolioCode]       VARCHAR (20)     COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [ModelName]           VARCHAR (100)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [Goal]                NUMERIC (16, 4)  NULL,
    [Serie]               VARCHAR (50)     COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [SellerCode]          SMALLINT         NOT NULL,
    [SellerName]          NVARCHAR (32)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [SupervisorCode]      NVARCHAR (8)     COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [SupervisorName]      NVARCHAR (120)   COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [State]               VARCHAR (1)      COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [TerritoryCode]       VARCHAR (30)     NULL,
    [Day]                 VARCHAR (30)     NULL,
    [Sale]                NUMERIC (38, 11) NOT NULL
);


GO

