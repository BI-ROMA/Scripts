CREATE TABLE [Molitalia].[BCK_t_ventas_det_add] (
    [DocEntry]          INT             NULL,
    [CardCode]          VARCHAR (20)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [TaxDate]           DATE            NULL,
    [SlpCode]           INT             NULL,
    [codigo_supervisor] VARCHAR (4)     COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [ItemCode]          VARCHAR (20)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [unidades_vendidas] INT             NULL,
    [valor_sinigv]      NUMERIC (12, 2) NULL,
    [mesa]              NVARCHAR (8)    COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [domi]              VARCHAR (3)     COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [tipo_venta]        INT             NULL,
    [tipo_documento]    NUMERIC (12, 2) NULL
);


GO

