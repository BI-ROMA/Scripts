CREATE TABLE [Reports].[DeprodecaFocusManager] (
    [Period]               INT             NOT NULL,
    [Area]                 VARCHAR (6)     NOT NULL,
    [PortfolioCode]        VARCHAR (5)     NULL,
    [SellerName]           VARCHAR (100)   NULL,
    [SupervisorName]       NVARCHAR (120)  COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [TerritoryCode]        CHAR (2)        NULL,
    [ItemName]             NVARCHAR (255)  NULL,
    [BranchName]           VARCHAR (50)    NULL,
    [Sale]                 DECIMAL (18, 4) NULL,
    [UME]                  DECIMAL (18, 4) NULL,
    [Coverage]             INT             NULL,
    [PortfolioQuantity]    INT             NULL,
    [CoveragePreviusMonth] INT             NOT NULL,
    [SaleWeight]           DECIMAL (18, 4) NULL,
    [UMEWeight]            DECIMAL (18, 4) NULL,
    [CoverageGoal]         INT             NULL,
    [SaleGoal]             INT             NULL,
    [TotalGoalSale]        INT             NULL,
    [UMEGoal]              INT             NULL,
    [TotalUMEGoal]         INT             NULL
);


GO

