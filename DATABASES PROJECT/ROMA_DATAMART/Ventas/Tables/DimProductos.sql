CREATE TABLE [Ventas].[DimProductos] (
    [IdPro]                SMALLINT        IDENTITY (1, 1) NOT NULL,
    [CodPro]               VARCHAR (20)    NULL,
    [NomPro]               VARCHAR (100)   NULL,
    [U_BKS_GRUPO]          VARCHAR (100)   NULL,
    [FeRegistro]           DATETIME        NULL,
    [IdCat_xPrv]           SMALLINT        NULL,
    [LineaRW]              VARCHAR (100)   NULL,
    [Categoria_Roma]       VARCHAR (50)    NULL,
    [Marca_Roma]           VARCHAR (50)    NULL,
    [Familia_Roma]         VARCHAR (50)    NULL,
    [Contenido_Roma]       VARCHAR (100)   NULL,
    [EsPromocionable]      CHAR (2)        NULL,
    [CoUnidadMedidaCompra] CHAR (3)        NULL,
    [QtdPiezas]            SMALLINT        NULL,
    [Pareto]               SMALLINT        NULL,
    [Precio_dCompra]       DECIMAL (18, 4) NULL,
    [Precio_dVenta]        DECIMAL (18, 4) NULL,
    [Peso]                 DECIMAL (18, 4) NULL,
    [UME]                  DECIMAL (18, 4) NULL,
    CONSTRAINT [PK_DimProductos] PRIMARY KEY CLUSTERED ([IdPro] ASC),
    CONSTRAINT [FK_DimProductos_DimCategorias] FOREIGN KEY ([IdCat_xPrv]) REFERENCES [Ventas].[DimCategorias] ([IdCat_xPrv]),
    CONSTRAINT [FK_DimProductos_DimProductos] FOREIGN KEY ([IdPro]) REFERENCES [Ventas].[DimProductos] ([IdPro])
);


GO

