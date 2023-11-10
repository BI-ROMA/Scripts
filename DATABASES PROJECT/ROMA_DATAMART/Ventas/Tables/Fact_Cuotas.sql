CREATE TABLE [Ventas].[Fact_Cuotas] (
    [IdCuota]           INT             IDENTITY (1, 1) NOT NULL,
    [Fecha]             DATE            NULL,
    [IdSede]            SMALLINT        NULL,
    [IdMesa]            SMALLINT        NULL,
    [IdCar]             SMALLINT        NULL,
    [IdVen]             SMALLINT        NULL,
    [IdPrv]             SMALLINT        NULL,
    [Cuota]             DECIMAL (18, 2) NULL,
    [IdCat_xPrv]        SMALLINT        NULL,
    [FechaKey]          INT             NULL,
    [IdCanal]           SMALLINT        NULL,
    [Peso]              DECIMAL (18, 5) NULL,
    [BaseComisionable]  DECIMAL (18, 2) NULL,
    [TopeExcedentePorc] DECIMAL (18, 2) NULL,
    [IdSupervisor]      SMALLINT        NULL,
    [CobMeta]           DECIMAL (18, 2) NULL,
    [FactorCob_xLinea]  DECIMAL (18, 5) NULL,
    [IdJefe_dVenta]     SMALLINT        NULL,
    [IdRelGeneral]      VARCHAR (20)    NULL,
    [IdRelGeneral2]     VARCHAR (14)    NULL,
    CONSTRAINT [PK_Fact_Cuotas] PRIMARY KEY CLUSTERED ([IdCuota] ASC),
    CONSTRAINT [FK_Fact_Cuotas_DimCanales] FOREIGN KEY ([IdCanal]) REFERENCES [Ventas].[DimCanales] ([IdCan]),
    CONSTRAINT [FK_Fact_Cuotas_DimCarteras] FOREIGN KEY ([IdCar]) REFERENCES [Ventas].[DimCarteras] ([IdCartera]),
    CONSTRAINT [FK_Fact_Cuotas_DimCategorias] FOREIGN KEY ([IdCat_xPrv]) REFERENCES [Ventas].[DimCategorias] ([IdCat_xPrv]),
    CONSTRAINT [FK_Fact_Cuotas_DimFechas] FOREIGN KEY ([FechaKey]) REFERENCES [Ventas].[DimFechas] ([FechaKey]),
    CONSTRAINT [FK_Fact_Cuotas_DimMesas] FOREIGN KEY ([IdMesa]) REFERENCES [Ventas].[DimMesas] ([IdMesa]),
    CONSTRAINT [FK_Fact_Cuotas_DimProveedores] FOREIGN KEY ([IdPrv]) REFERENCES [Ventas].[DimProveedores] ([IdPrv]),
    CONSTRAINT [FK_Fact_Cuotas_DimRelGeneral] FOREIGN KEY ([IdRelGeneral]) REFERENCES [Ventas].[DimRelGeneral] ([IdRelGeneral]),
    CONSTRAINT [FK_Fact_Cuotas_DimRelGeneral2] FOREIGN KEY ([IdRelGeneral2]) REFERENCES [Ventas].[DimRelGeneral2] ([IdRelGeneral]),
    CONSTRAINT [FK_Fact_Cuotas_DimSedes] FOREIGN KEY ([IdSede]) REFERENCES [Ventas].[DimSedes] ([IdSede]),
    CONSTRAINT [FK_Fact_Cuotas_DimVendedores] FOREIGN KEY ([IdVen]) REFERENCES [Ventas].[DimVendedores] ([IdVen])
);


GO

