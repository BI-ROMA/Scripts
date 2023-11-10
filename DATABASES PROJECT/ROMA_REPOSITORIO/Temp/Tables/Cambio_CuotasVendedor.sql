CREATE TABLE [Temp].[Cambio_CuotasVendedor] (
    [periodo]      NVARCHAR (255) NULL,
    [codsede]      NVARCHAR (255) NULL,
    [codcartera]   NVARCHAR (255) NULL,
    [codvendedor]  NVARCHAR (255) NOT NULL,
    [nomvendedor]  NVARCHAR (255) NULL,
    [codproveedor] NVARCHAR (255) NOT NULL,
    [nomproveedor] NVARCHAR (255) NULL,
    [codcategoria] NVARCHAR (255) NULL,
    [nomcategoria] NVARCHAR (255) NULL,
    [codcanal]     NVARCHAR (255) NULL,
    [cuota]        FLOAT (53)     NULL,
    [nueva_cuota]  FLOAT (53)     NULL
);


GO

