CREATE TABLE [Zur].[ExtractorSellers] (
    [SupplierCode]   VARCHAR (10)   NOT NULL,
    [CompanyCode]    VARCHAR (20)   NULL,
    [SellerCode]     SMALLINT       NULL,
    [SellerName]     VARCHAR (100)  NOT NULL,
    [DocumentType]   VARCHAR (3)    NOT NULL,
    [DocumentNumber] VARCHAR (20)   NULL,
    [ChannelName]    VARCHAR (100)  NULL,
    [DateIncome]     DATE           NULL,
    [DateUpdate]     DATE           NULL,
    [ProcessDate]    DATE           NULL,
    [Exclusive]      INT            NOT NULL,
    [SupervisorCode] CHAR (4)       NULL,
    [SupervisorName] NVARCHAR (120) COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [Ref1]           VARCHAR (1)    NOT NULL,
    [Ref2]           VARCHAR (1)    NOT NULL,
    [Ref3]           VARCHAR (1)    NOT NULL,
    [Ref4]           VARCHAR (1)    NOT NULL,
    [Ref5]           VARCHAR (1)    NOT NULL,
    [Ref6]           VARCHAR (1)    NOT NULL,
    [Ref7]           VARCHAR (1)    NOT NULL,
    [Ref8]           VARCHAR (1)    NOT NULL,
    [Ref9]           VARCHAR (1)    NOT NULL,
    [Ref10]          VARCHAR (1)    NOT NULL
);


GO

