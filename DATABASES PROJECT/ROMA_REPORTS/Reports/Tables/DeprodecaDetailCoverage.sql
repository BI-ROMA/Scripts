CREATE TABLE [Reports].[DeprodecaDetailCoverage] (
    [Period]       VARCHAR (6)    NULL,
    [BranchName]   VARCHAR (50)   NOT NULL,
    [CategoryName] VARCHAR (50)   COLLATE SQL_Latin1_General_CP850_CI_AS NOT NULL,
    [BrandName]    VARCHAR (50)   COLLATE SQL_Latin1_General_CP850_CI_AS NOT NULL,
    [FamilyName]   VARCHAR (50)   COLLATE SQL_Latin1_General_CP850_CI_AS NOT NULL,
    [ContentName]  VARCHAR (103)  COLLATE SQL_Latin1_General_CP850_CI_AS NOT NULL,
    [ProductoName] NVARCHAR (100) COLLATE SQL_Latin1_General_CP850_CI_AS NOT NULL,
    [coverage]     INT            NULL
);


GO

