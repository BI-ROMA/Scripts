CREATE TABLE [Clorox].[Extractor_Ventas] (
    [DocEntry]             INT           NULL,
    [CodigoDistribuidor]   VARCHAR (50)  NULL,
    [IndicCombo]           VARCHAR (1)   NULL,
    [CodCombo]             VARCHAR (1)   NULL,
    [CodigoPromocion]      VARCHAR (10)  NULL,
    [CantidadDevuelta]     NVARCHAR (50) NULL,
    [BonificacionSoles]    NVARCHAR (50) NULL,
    [BonificacionUnidades] NVARCHAR (50) NULL,
    [NroFactura]           VARCHAR (30)  NULL,
    [Fecha]                DATE          NULL,
    [CodigoCliente]        VARCHAR (35)  NULL,
    [LineNum]              INT           NULL,
    [ItemCode]             VARCHAR (20)  NULL,
    [Quantity]             NVARCHAR (50) NULL,
    [LineTotal]            NVARCHAR (50) NULL,
    [GTotal]               NVARCHAR (50) NULL,
    [descuento]            NVARCHAR (50) NULL,
    [CodigoVendedor]       SMALLINT      NULL,
    [mesa]                 CHAR (3)      NULL,
    [domi]                 VARCHAR (20)  NULL,
    [periodo]              INT           NULL,
    [CodSedeAlmacen]       CHAR (2)      NULL
);


GO

