CREATE TABLE [Reports].[CommissionsConsolidatedReport] (
    [Period]            VARCHAR (6)     NULL,
    [TypeUser]          VARCHAR (20)    NOT NULL,
    [UserCode]          VARCHAR (10)    NULL,
    [UserName]          VARCHAR (100)   NOT NULL,
    [TerritoryCode]     VARCHAR (20)    NULL,
    [TerritoryName]     CHAR (50)       NULL,
    [TeamCode]          VARCHAR (10)    NULL,
    [TeamName]          VARCHAR (50)    NULL,
    [ChannelCode]       VARCHAR (10)    NULL,
    [ChannelName]       VARCHAR (50)    NULL,
    [SalePreviousMonth] DECIMAL (18, 2) NULL,
    [Goal]              DECIMAL (18, 2) NULL,
    [Sale]              DECIMAL (18, 2) NULL,
    [SalePercentage]    DECIMAL (10, 6) NULL,
    [Salary]            DECIMAL (18, 2) NULL
);


GO

