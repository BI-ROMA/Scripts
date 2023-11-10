CREATE TABLE [J&J].[Ventas] (
    [DocEntry]             INT             NULL,
    [CodigoDistribuidor]   VARCHAR (50)    NULL,
    [IndicCombo]           VARCHAR (1)     NULL,
    [CodCombo]             VARCHAR (1)     NULL,
    [CodigoPromocion]      VARCHAR (10)    NULL,
    [CantidadDevuelta]     NUMERIC (21, 6) NULL,
    [BonificacionSoles]    NUMERIC (38, 6) NULL,
    [BonificacionUnidades] NUMERIC (19, 6) NULL,
    [NroFactura]           VARCHAR (30)    NULL,
    [Fecha]                DATE            NULL,
    [CodigoCliente]        NVARCHAR (35)   NULL,
    [LineNum]              INT             NULL,
    [ItemCode]             VARCHAR (20)    NULL,
    [Quantity]             NUMERIC (21, 6) NULL,
    [LineTotal]            NUMERIC (21, 6) NULL,
    [GTotal]               NUMERIC (21, 6) NULL,
    [descuento]            NUMERIC (38, 6) NULL,
    [CodigoVendedor]       SMALLINT        NULL,
    [mesa]                 CHAR (3)        NULL,
    [domi]                 NVARCHAR (20)   NULL,
    [periodo]              INT             NULL,
    [FeRegistro]           VARCHAR (12)    NULL,
    [CodSedeAlmacen]       NCHAR (2)       NULL
);


GO

