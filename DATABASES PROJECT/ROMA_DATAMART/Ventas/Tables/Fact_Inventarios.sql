CREATE TABLE [Ventas].[Fact_Inventarios] (
    [FechaKey]         INT             NOT NULL,
    [IdAlmacen]        SMALLINT        NOT NULL,
    [IdProveedor]      SMALLINT        NOT NULL,
    [IdProducto]       SMALLINT        NOT NULL,
    [IdCat_xPrv]       SMALLINT        NOT NULL,
    [Cantidad]         DECIMAL (18, 2) NULL,
    [Valorizado]       DECIMAL (18, 2) NULL,
    [Cuota_xCat]       DECIMAL (18, 2) NULL,
    [Qtd]              DECIMAL (18, 2) NULL,
    [QtdPry]           DECIMAL (18, 2) NULL,
    [Vta]              DECIMAL (18, 2) NULL,
    [VtaPry]           DECIMAL (18, 2) NULL,
    [Cantidad_xPiezas] DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_Fact_Inventarios] PRIMARY KEY CLUSTERED ([FechaKey] ASC, [IdAlmacen] ASC, [IdProveedor] ASC, [IdProducto] ASC, [IdCat_xPrv] ASC),
    CONSTRAINT [FK_Fact_Inventarios_DimAlmacenes] FOREIGN KEY ([IdAlmacen]) REFERENCES [Ventas].[DimAlmacenes] ([IdAlmacen]),
    CONSTRAINT [FK_Fact_Inventarios_DimCategorias] FOREIGN KEY ([IdCat_xPrv]) REFERENCES [Ventas].[DimCategorias] ([IdCat_xPrv]),
    CONSTRAINT [FK_Fact_Inventarios_DimFechas] FOREIGN KEY ([FechaKey]) REFERENCES [Ventas].[DimFechas] ([FechaKey]),
    CONSTRAINT [FK_Fact_Inventarios_DimProductos] FOREIGN KEY ([IdProducto]) REFERENCES [Ventas].[DimProductos] ([IdPro]),
    CONSTRAINT [FK_Fact_Inventarios_DimProveedores] FOREIGN KEY ([IdProveedor]) REFERENCES [Ventas].[DimProveedores] ([IdPrv])
);


GO

