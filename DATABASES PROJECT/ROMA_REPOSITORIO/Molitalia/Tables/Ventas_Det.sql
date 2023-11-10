CREATE TABLE [Molitalia].[Ventas_Det] (
    [U_BKS_ALM]          NVARCHAR (10)    NULL,
    [DocEntry]           INT              NULL,
    [CardCode]           NVARCHAR (15)    NULL,
    [TaxDate]            DATETIME         NULL,
    [SlpCode]            SMALLINT         NULL,
    [codigo_supervisor]  NVARCHAR (8)     NULL,
    [ItemCode]           NVARCHAR (20)    NULL,
    [unidades_vendidas]  NUMERIC (38, 11) NULL,
    [valor_sinigv]       NUMERIC (38, 6)  NULL,
    [mesa]               NVARCHAR (5)     NULL,
    [domi]               NVARCHAR (20)    NULL,
    [tipo_venta]         INT              NULL,
    [tipo_documento]     NVARCHAR (10)    NULL,
    [Nro_documento]      NVARCHAR (30)    NULL,
    [indicadorboni]      VARCHAR (1)      NULL,
    [codigoboni]         NVARCHAR (MAX)   NULL,
    [codigomotivodev]    VARCHAR (2)      NULL,
    [descuentosinigv]    NUMERIC (38, 6)  NULL,
    [importecostosinigv] NUMERIC (38, 6)  NULL,
    [FeRegistro]         VARCHAR (12)     NULL
);


GO

