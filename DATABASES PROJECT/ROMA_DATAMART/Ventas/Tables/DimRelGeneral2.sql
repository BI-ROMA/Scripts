CREATE TABLE [Ventas].[DimRelGeneral2] (
    [IdRelGeneral] VARCHAR (14)  NOT NULL,
    [IdSede]       SMALLINT      NOT NULL,
    [IdCanal]      SMALLINT      NOT NULL,
    [IdCar]        SMALLINT      NOT NULL,
    [IdPrv]        SMALLINT      NOT NULL,
    [IdCat_xPrv]   SMALLINT      NOT NULL,
    [NomVendedor]  VARCHAR (100) NULL,
    [FeRegistro]   DATETIME      DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DimRelGeneral2] PRIMARY KEY CLUSTERED ([IdRelGeneral] ASC),
    CONSTRAINT [FK_DimRelGeneral2_DimCanales] FOREIGN KEY ([IdCanal]) REFERENCES [Ventas].[DimCanales] ([IdCan]),
    CONSTRAINT [FK_DimRelGeneral2_DimCarterasNew] FOREIGN KEY ([IdCar]) REFERENCES [Ventas].[DimCarteras] ([IdCartera]),
    CONSTRAINT [FK_DimRelGeneral2_DimCategorias] FOREIGN KEY ([IdCat_xPrv]) REFERENCES [Ventas].[DimCategorias] ([IdCat_xPrv]),
    CONSTRAINT [FK_DimRelGeneral2_DimProveedores] FOREIGN KEY ([IdPrv]) REFERENCES [Ventas].[DimProveedores] ([IdPrv]),
    CONSTRAINT [FK_DimRelGeneral2_DimSedes] FOREIGN KEY ([IdSede]) REFERENCES [Ventas].[DimSedes] ([IdSede])
);


GO

