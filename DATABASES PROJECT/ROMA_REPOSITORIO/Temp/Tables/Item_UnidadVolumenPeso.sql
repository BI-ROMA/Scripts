CREATE TABLE [Temp].[Item_UnidadVolumenPeso] (
    [itemcode]            VARCHAR (11)    NOT NULL,
    [valor1]              NUMERIC (15, 4) NULL,
    [peso]                NUMERIC (15, 4) NULL,
    [volumen]             NUMERIC (15, 4) NULL,
    [LineaRW]             VARCHAR (50)    NULL,
    [Valor2]              NUMERIC (18, 5) NULL,
    [Categoria]           VARCHAR (50)    NULL,
    [Marca]               VARCHAR (50)    NULL,
    [Familia]             VARCHAR (50)    NULL,
    [Contenido]           VARCHAR (50)    NULL,
    [Envase]              VARCHAR (50)    NULL,
    [ContenidoOriginal]   VARCHAR (200)   NULL,
    [CODIGOLINEA]         CHAR (10)       NULL,
    [CODIGOCATEGORIA]     CHAR (10)       NULL,
    [CODIGOFAMILIA]       CHAR (10)       NULL,
    [PZAUNI]              NUMERIC (18, 2) NULL,
    [DESCRIPCIONPRODUCTO] VARCHAR (200)   NULL,
    [FeRegistro]          DATETIME        NULL,
    [CodPrv]              VARCHAR (15)    NULL,
    [CodFam]              CHAR (6)        NULL,
    [CodCat]              CHAR (3)        NULL,
    [CatJes]              VARCHAR (30)    NULL,
    [FeModifica]          DATETIME        NULL,
    [Qtd_Ult30D]          INT             NULL,
    [Vta_Ult30D]          NUMERIC (15, 2) NULL,
    [UNI_Compra]          CHAR (5)        NULL,
    [Piezas_xUNI]         NUMERIC (18, 2) NULL,
    [Stock]               NUMERIC (18, 2) NULL,
    [PrecioCompra]        NUMERIC (18, 2) NULL,
    [FeUltimaCompra]      DATE            NULL,
    [FeFactura]           DATE            NULL,
    [FeEntrada]           DATE            NULL
);


GO

