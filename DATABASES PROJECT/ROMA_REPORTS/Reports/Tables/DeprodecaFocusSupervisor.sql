CREATE TABLE [Reports].[DeprodecaFocusSupervisor] (
    [Period]            INT              NOT NULL,
    [Date]              DATE             NULL,
    [PortfolioCode]     VARCHAR (5)      NULL,
    [SellerName]        VARCHAR (100)    NULL,
    [SupervisorName]    NVARCHAR (120)   COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [SupervisorCode]    NVARCHAR (8)     COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [Branch]            VARCHAR (50)     NULL,
    [TerritoryCode]     CHAR (2)         NULL,
    [ItemName]          NVARCHAR (255)   NULL,
    [Sale]              NUMERIC (38, 6)  NULL,
    [UME]               NUMERIC (38, 21) NULL,
    [Coverage]          INT              NULL,
    [CoverageMonth]     INT              NULL,
    [PortfolioQuantity] INT              NULL,
    [SaleWeight]        DECIMAL (38, 20) NULL,
    [UMEWeight]         DECIMAL (38, 20) NULL,
    [CoverageGoal]      INT              NULL,
    [SaleGoal]          INT              NULL,
    [TotalSaleGoal]     INT              NULL,
    [UMEGoal]           INT              NULL,
    [TotalUMEGoal]      INT              NULL
);


GO

