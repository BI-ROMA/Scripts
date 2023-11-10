CREATE TABLE [Upload].[CoverageFactorFormat] (
    [Period]       INT            NOT NULL,
    [SupplierCode] NVARCHAR (255) NULL,
    [SupplierName] NVARCHAR (255) NULL,
    [CategoryCode] NVARCHAR (255) NULL,
    [CategoryName] NVARCHAR (255) NULL,
    [Origin]       NVARCHAR (255) NOT NULL,
    [FactorCov]    FLOAT (53)     NULL
);


GO

