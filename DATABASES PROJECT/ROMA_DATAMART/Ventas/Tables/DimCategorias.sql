CREATE TABLE [Ventas].[DimCategorias] (
    [IdCat_xPrv] SMALLINT      IDENTITY (1, 1) NOT NULL,
    [CodCat]     CHAR (3)      NULL,
    [NomCat]     VARCHAR (100) NULL,
    [IdPrv]      SMALLINT      NULL,
    [CatJes]     VARCHAR (100) DEFAULT ('No Definido') NULL,
    [CatPrv]     VARCHAR (20)  NULL,
    CONSTRAINT [PK_DimCategorias] PRIMARY KEY CLUSTERED ([IdCat_xPrv] ASC),
    CONSTRAINT [FK_DimCategorias_DimProveedores] FOREIGN KEY ([IdPrv]) REFERENCES [Ventas].[DimProveedores] ([IdPrv])
);


GO

