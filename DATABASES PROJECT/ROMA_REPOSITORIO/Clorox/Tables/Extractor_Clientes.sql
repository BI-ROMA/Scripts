CREATE TABLE [Clorox].[Extractor_Clientes] (
    [CodigoCliente]      VARCHAR (35)    NULL,
    [name]               VARCHAR (100)   NULL,
    [RUC]                VARCHAR (32)    NULL,
    [DNI]                VARCHAR (32)    NULL,
    [TipoNegocio]        VARCHAR (255)   NULL,
    [Zona]               NVARCHAR (30)   NULL,
    [Modulo]             NVARCHAR (10)   NULL,
    [Distrito]           NVARCHAR (6)    NULL,
    [slpcode]            INT             NULL,
    [DiaVisita]          NVARCHAR (4000) NULL,
    [Status]             VARCHAR (1)     NULL,
    [CodCorporativo]     VARCHAR (1)     NULL,
    [Mercado]            VARCHAR (1)     NULL,
    [giro]               VARCHAR (100)   NULL,
    [CodigoDistribuidor] VARCHAR (50)    NULL
);


GO

