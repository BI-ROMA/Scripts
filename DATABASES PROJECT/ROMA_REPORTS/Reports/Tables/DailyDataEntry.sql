CREATE TABLE [Reports].[DailyDataEntry] (
    [Id]                    INT             IDENTITY (1, 1) NOT NULL,
    [StartDateEntry]        DATETIME        NULL,
    [EndDateEntry]          DATETIME        NULL,
    [RegistrationDateEntry] DATETIME        NULL,
    [PeriodDateEntry]       INT             NULL,
    [CustomerCode]          INT             NULL,
    [CustomerAddressCode]   INT             NULL,
    [SupplierCode]          SMALLINT        NULL,
    [CategoryCode]          SMALLINT        NULL,
    [ProductCode]           SMALLINT        NULL,
    [PorfolioCode]          SMALLINT        NULL,
    [SellerCode]            SMALLINT        NULL,
    [Sales]                 NUMERIC (38, 2) NULL,
    [UMES]                  NUMERIC (38, 6) NULL,
    [Quantity]              DECIMAL (18, 5) NULL,
    [TeamCode]              SMALLINT        NULL,
    [SupervisorCode]        SMALLINT        NULL,
    [ManagerSaleCode]       SMALLINT        NULL,
    [TerritoryCode]         SMALLINT        NULL,
    [ChannelCode]           SMALLINT        NULL,
    [WarehouseCode]         SMALLINT        NULL,
    [EntryCode]             INT             NULL,
    [EntryType]             CHAR (3)        NULL,
    [ItemNumber]            SMALLINT        NULL,
    [Weight]                DECIMAL (18, 5) NULL,
    [EntryOrNot]            VARCHAR (20)    NULL,
    CONSTRAINT [PK_DailyDataEntry] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

