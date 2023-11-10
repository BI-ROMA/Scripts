CREATE TABLE [dbo].[PesosVolumenes] (
    [CodigoProveedor]       NVARCHAR (255) NULL,
    [NombreProveedor]       NVARCHAR (255) NULL,
    [CodigoProducto]        NVARCHAR (255) NULL,
    [NombreProducto]        NVARCHAR (255) NULL,
    [CodigoBarra]           NVARCHAR (255) NULL,
    [UnidadAlmacenamiento]  NVARCHAR (255) NULL,
    [FactorDeConversion]    FLOAT (53)     NULL,
    [UnidadPeso]            NVARCHAR (255) NULL,
    [Peso]                  FLOAT (53)     NULL,
    [UnidadVolumen]         NVARCHAR (255) NULL,
    [Ancho]                 FLOAT (53)     NULL,
    [Largo]                 FLOAT (53)     NULL,
    [Alto]                  FLOAT (53)     NULL,
    [Volumen]               FLOAT (53)     NULL,
    [FactorPesoVolumetrico] FLOAT (53)     NULL
);


GO

