CREATE TABLE [Ventas].[Fact_CarteraInicial_xVendedor] (
    [FechaKey]       INT          NOT NULL,
    [IdMesa]         SMALLINT     NOT NULL,
    [IdSede]         SMALLINT     NOT NULL,
    [IdCartera]      SMALLINT     NOT NULL,
    [IdJefe_dVenta]  SMALLINT     NOT NULL,
    [IdSupervisor]   SMALLINT     NOT NULL,
    [IdVen]          SMALLINT     NOT NULL,
    [CarteraInicial] SMALLINT     NOT NULL,
    [CodCli]         VARCHAR (15) NOT NULL,
    [IdCanal]        SMALLINT     NOT NULL,
    [IdProveedor]    SMALLINT     NOT NULL,
    [IdCat_xPrv]     SMALLINT     NOT NULL,
    [IdRelGeneral]   VARCHAR (20) NULL,
    [IdRelGeneral2]  VARCHAR (14) NULL,
    [CodDom]         VARCHAR (3)  NOT NULL,
    [Periodo]        VARCHAR (6)  NULL,
    CONSTRAINT [PK_Fact_CarteraInicial_xVendedor] PRIMARY KEY CLUSTERED ([FechaKey] ASC, [IdMesa] ASC, [IdSede] ASC, [IdCartera] ASC, [IdJefe_dVenta] ASC, [IdSupervisor] ASC, [IdVen] ASC, [CodCli] ASC, [IdCanal] ASC, [IdProveedor] ASC, [IdCat_xPrv] ASC, [CodDom] ASC),
    CONSTRAINT [FK_Fact_CarteraInicial_xVendedor_DimCategorias] FOREIGN KEY ([IdCat_xPrv]) REFERENCES [Ventas].[DimCategorias] ([IdCat_xPrv]),
    CONSTRAINT [FK_Fact_CarteraInicial_xVendedor_DimFechas] FOREIGN KEY ([FechaKey]) REFERENCES [Ventas].[DimFechas] ([FechaKey]),
    CONSTRAINT [FK_Fact_CarteraInicial_xVendedor_DimMesas] FOREIGN KEY ([IdMesa]) REFERENCES [Ventas].[DimMesas] ([IdMesa]),
    CONSTRAINT [FK_Fact_CarteraInicial_xVendedor_DimRelGeneral2] FOREIGN KEY ([IdRelGeneral2]) REFERENCES [Ventas].[DimRelGeneral2] ([IdRelGeneral]),
    CONSTRAINT [FK_Fact_CarteraInicial_xVendedor_DimVendedores] FOREIGN KEY ([IdVen]) REFERENCES [Ventas].[DimVendedores] ([IdVen])
);


GO

