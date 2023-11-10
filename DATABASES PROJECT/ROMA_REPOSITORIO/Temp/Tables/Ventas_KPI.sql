CREATE TABLE [Temp].[Ventas_KPI] (
    [Periodo]      INT            NULL,
    [FeRegistro]   DATETIME       DEFAULT (getdate()) NULL,
    [N]            FLOAT (53)     NULL,
    [HR]           FLOAT (53)     NULL,
    [SERIE]        NVARCHAR (255) NULL,
    [NUMERO]       FLOAT (53)     NULL,
    [CLIENTE]      NVARCHAR (255) NULL,
    [RAZON SOCIAL] NVARCHAR (255) NULL,
    [IMPORTE]      FLOAT (53)     NULL,
    [FECHA]        DATETIME       NULL,
    [ZONA]         NVARCHAR (255) NULL
);


GO

