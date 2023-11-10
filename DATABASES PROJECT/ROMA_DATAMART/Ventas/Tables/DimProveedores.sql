CREATE TABLE [Ventas].[DimProveedores] (
    [IdPrv]     SMALLINT      IDENTITY (0, 1) NOT NULL,
    [CodPrv]    VARCHAR (20)  NULL,
    [NomPrv]    VARCHAR (200) NULL,
    [NomPrvAbr] VARCHAR (100) NULL,
    [U_Login]   VARCHAR (50)  NULL,
    CONSTRAINT [PK_DimProveedores] PRIMARY KEY CLUSTERED ([IdPrv] ASC)
);


GO

