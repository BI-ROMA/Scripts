CREATE TABLE [Ventas].[DimComisiones] (
    [IdMesa]        INT             NOT NULL,
    [IdTipoUser]    INT             NOT NULL,
    [Escala]        NUMERIC (18, 2) NULL,
    [RemFija]       NUMERIC (18, 2) NULL,
    [ExcedentePorc] NUMERIC (5, 2)  NULL,
    [Factor_xVta]   NUMERIC (5, 2)  NULL,
    [Factor_xCob]   NUMERIC (5, 2)  NULL,
    [Factor_xDev]   NUMERIC (5, 2)  NULL
);


GO

