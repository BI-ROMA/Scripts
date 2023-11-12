CREATE TABLE [Ventas].[Fact_Ventas] (
    [FechaKey]        INT             NOT NULL,
    [IdSede]          SMALLINT        NOT NULL,
    [IdMesa]          SMALLINT        NOT NULL,
    [IdCliente]       INT             NOT NULL,
    [IdProveedor]     SMALLINT        NOT NULL,
    [IdProducto]      SMALLINT        NOT NULL,
    [IdDocumento]     INT             NOT NULL,
    [Item]            SMALLINT        NOT NULL,
    [IdJefe_dVenta]   SMALLINT        NOT NULL,
    [IdSupervisor]    SMALLINT        NOT NULL,
    [IdVendedor]      SMALLINT        NOT NULL,
    [IdCanal]         SMALLINT        NOT NULL,
    [IdCartera]       SMALLINT        NOT NULL,
    [IdCat_xPrv]      SMALLINT        NOT NULL,
    [Cantidad]        DECIMAL (18, 5) NOT NULL,
    [Total]           DECIMAL (18, 2) NOT NULL,
    [TotalIGV]        DECIMAL (18, 2) NOT NULL,
    [PartitionMonth]  INT             NOT NULL,
    [FactorUME]       DECIMAL (18, 5) NULL,
    [IdLLaveCartera]  VARCHAR (12)    NULL,
    [IdRelGeneral]    VARCHAR (20)    NULL,
    [IdRelGeneral2]   VARCHAR (14)    NULL,
    [IdTipoVenta]     SMALLINT        NULL,
    [Item2]           SMALLINT        NULL,
    [Bonificacion]    CHAR (1)        NULL,
    [priceBefDi]      DECIMAL (18, 5) NULL,
    [VatPrcnt]        DECIMAL (18, 5) NULL,
    [CodigoPromocion] VARCHAR (25)    NULL,
    [DiscPrcnt]       DECIMAL (18, 5) NULL,
    [price]           DECIMAL (18, 5) NULL,
    [costo]           DECIMAL (18, 5) NULL
);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [PK_Fact_Ventas] PRIMARY KEY CLUSTERED ([FechaKey] ASC, [IdSede] ASC, [IdMesa] ASC, [IdCliente] ASC, [IdProveedor] ASC, [IdProducto] ASC, [IdDocumento] ASC, [Item] ASC, [IdSupervisor] ASC, [IdVendedor] ASC, [IdCanal] ASC, [IdCartera] ASC, [IdCat_xPrv] ASC);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimMesas] FOREIGN KEY ([IdMesa]) REFERENCES [Ventas].[DimMesas] ([IdMesa]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimClientes] FOREIGN KEY ([IdCliente]) REFERENCES [Ventas].[DimClientes] ([IdCli]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimVendedores] FOREIGN KEY ([IdVendedor]) REFERENCES [Ventas].[DimVendedores] ([IdVen]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimCategorias] FOREIGN KEY ([IdCat_xPrv]) REFERENCES [Ventas].[DimCategorias] ([IdCat_xPrv]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimFechas] FOREIGN KEY ([FechaKey]) REFERENCES [Ventas].[DimFechas] ([FechaKey]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimTipoVenta] FOREIGN KEY ([IdTipoVenta]) REFERENCES [Ventas].[DimTipoVenta] ([IdTipoVenta]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimCarteras] FOREIGN KEY ([IdCartera]) REFERENCES [Ventas].[DimCarteras] ([IdCartera]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimSedes] FOREIGN KEY ([IdSede]) REFERENCES [Ventas].[DimSedes] ([IdSede]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimRelGeneral2] FOREIGN KEY ([IdRelGeneral2]) REFERENCES [Ventas].[DimRelGeneral2] ([IdRelGeneral]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimDocumentos] FOREIGN KEY ([IdDocumento]) REFERENCES [Ventas].[DimDocumentos] ([IdDoc]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimCanales] FOREIGN KEY ([IdCanal]) REFERENCES [Ventas].[DimCanales] ([IdCan]);
GO

ALTER TABLE [Ventas].[Fact_Ventas]
    ADD CONSTRAINT [FK_Fact_Ventas_DimProveedores] FOREIGN KEY ([IdProveedor]) REFERENCES [Ventas].[DimProveedores] ([IdPrv]);
GO

