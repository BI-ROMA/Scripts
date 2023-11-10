CREATE TABLE [Molitalia].[Clientes] (
    [U_BKS_ALM]        NVARCHAR (10)    NULL,
    [name]             NVARCHAR (100)   NULL,
    [Street]           NVARCHAR (10)    NULL,
    [telefono]         NVARCHAR (50)    NULL,
    [id]               NVARCHAR (15)    NULL,
    [fecha_ingreso]    DATETIME         NULL,
    [LicTradNum]       NVARCHAR (32)    NULL,
    [codigo_provincia] NVARCHAR (10)    NULL,
    [ubigeo]           NVARCHAR (12)    NULL,
    [tiponegocio]      VARCHAR (2)      NULL,
    [dia]              NVARCHAR (10)    NULL,
    [frecuencia]       VARCHAR (1)      NULL,
    [domi]             NVARCHAR (3)     NULL,
    [CreditLine]       NUMERIC (19, 6)  NULL,
    [refx]             NUMERIC (20, 16) NULL,
    [refy]             NUMERIC (20, 16) NULL,
    [tipodocidentidad] NVARCHAR (2)     NULL,
    [ruta]             NVARCHAR (10)    NULL,
    [canal]            VARCHAR (1)      NULL,
    [FeRegistro]       VARCHAR (12)     NULL
);


GO

