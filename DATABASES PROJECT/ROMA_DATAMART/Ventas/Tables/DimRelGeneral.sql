CREATE TABLE [Ventas].[DimRelGeneral] (
    [IdRelGeneral] VARCHAR (20)  NOT NULL,
    [IdSede]       SMALLINT      NOT NULL,
    [IdMesa]       SMALLINT      NOT NULL,
    [IdCanal]      SMALLINT      NOT NULL,
    [IdCar]        SMALLINT      NOT NULL,
    [IdPrv]        SMALLINT      NOT NULL,
    [IdCat_xPrv]   SMALLINT      NOT NULL,
    [IdVendedor]   SMALLINT      NOT NULL,
    [NomVendedor]  VARCHAR (100) NULL,
    [FeRegistro]   DATETIME      DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DimRelGeneral] PRIMARY KEY CLUSTERED ([IdRelGeneral] ASC),
    CONSTRAINT [FK_DimRelGeneral_DimCanales] FOREIGN KEY ([IdCanal]) REFERENCES [Ventas].[DimCanales] ([IdCan]),
    CONSTRAINT [FK_DimRelGeneral_DimCarterasNew] FOREIGN KEY ([IdCar]) REFERENCES [Ventas].[DimCarteras] ([IdCartera]),
    CONSTRAINT [FK_DimRelGeneral_DimCategorias] FOREIGN KEY ([IdCat_xPrv]) REFERENCES [Ventas].[DimCategorias] ([IdCat_xPrv]),
    CONSTRAINT [FK_DimRelGeneral_DimMesas] FOREIGN KEY ([IdMesa]) REFERENCES [Ventas].[DimMesas] ([IdMesa]),
    CONSTRAINT [FK_DimRelGeneral_DimMesas1] FOREIGN KEY ([IdMesa]) REFERENCES [Ventas].[DimMesas] ([IdMesa]),
    CONSTRAINT [FK_DimRelGeneral_DimProveedores] FOREIGN KEY ([IdPrv]) REFERENCES [Ventas].[DimProveedores] ([IdPrv]),
    CONSTRAINT [FK_DimRelGeneral_DimSedes] FOREIGN KEY ([IdSede]) REFERENCES [Ventas].[DimSedes] ([IdSede]),
    CONSTRAINT [FK_DimRelGeneral_DimVendedores] FOREIGN KEY ([IdVendedor]) REFERENCES [Ventas].[DimVendedores] ([IdVen])
);


GO

