CREATE TABLE [Molitalia].[BCK_t_ventas_det_v2] (
    [DocEntry]           INT             NULL,
    [CardCode]           VARCHAR (20)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [TaxDate]            DATE            NULL,
    [SlpCode]            INT             NULL,
    [codigo_supervisor]  VARCHAR (4)     COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [ItemCode]           VARCHAR (20)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [unidades_vendidas]  INT             NULL,
    [valor_sinigv]       NUMERIC (12, 2) NULL,
    [mesa]               NVARCHAR (8)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [domi]               NVARCHAR (3)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [tipo_venta]         INT             NULL,
    [tipo_documento]     CHAR (2)        COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [nro_documento]      NVARCHAR (20)   COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [indicadorboni]      NVARCHAR (1)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [codigoboni]         NVARCHAR (10)   COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [codigomotivodev]    NVARCHAR (10)   COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [descuentosinigv]    NUMERIC (12, 2) NULL,
    [importecostosinigv] NUMERIC (12, 2) NULL
);


GO

