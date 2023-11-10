CREATE TABLE [Clorox].[Extractor_Stock] (
    [CodigoDistribuidor]        VARCHAR (50)    NULL,
    [CodigoAlmacen]             VARCHAR (20)    NULL,
    [NombreAlmacen]             VARCHAR (100)   NULL,
    [CodigoProveedor]           VARCHAR (20)    NULL,
    [Proveedor]                 VARCHAR (200)   NULL,
    [CodigoProducto]            VARCHAR (50)    NULL,
    [StockEnUnidadDeConsumo]    INT             NULL,
    [UnidadDeMedidaDeConsumo]   VARCHAR (3)     NULL,
    [StockEnUnidadDeCompra]     NUMERIC (14, 4) NULL,
    [UnidadDeMedidaDeCompra]    VARCHAR (20)    NULL,
    [ValorStock]                NUMERIC (14, 4) NULL,
    [FechaStock]                VARCHAR (10)    NULL,
    [IngresosEnUnidadDeConsumo] INT             NULL,
    [ValorIngresos]             NVARCHAR (10)   NULL,
    [VentasEnUnidadDeConsumo]   INT             NULL,
    [ValorVentas]               NVARCHAR (10)   NULL,
    [OtrosEnUnidadDeConsumo]    INT             NULL,
    [ValorOtros]                INT             NULL,
    [Periodo]                   INT             NULL
);


GO

