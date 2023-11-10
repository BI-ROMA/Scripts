CREATE TABLE [Reports].[DeprodecaFocusSeller] (
    [Period]           INT              NOT NULL,
    [CustomerCode]     VARCHAR (15)     NOT NULL,
    [CustomerName]     VARCHAR (100)    NULL,
    [SellerCode]       SMALLINT         NULL,
    [Day]              VARCHAR (20)     NULL,
    [HomeCode]         VARCHAR (3)      NOT NULL,
    [ItemName]         NVARCHAR (255)   NULL,
    [Sale]             NUMERIC (38, 6)  NOT NULL,
    [BranchName]       VARCHAR (50)     NULL,
    [TotalSaleGoal]    DECIMAL (18, 2)  NULL,
    [CustomerSaleGoal] DECIMAL (18, 2)  NULL,
    [SaleWeight]       DECIMAL (38, 20) NULL
);


GO

