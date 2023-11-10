CREATE TABLE [J&J].[Productos] (
    [CodigoProducto]     NVARCHAR (20)   NULL,
    [NombreProducto]     NVARCHAR (100)  NULL,
    [Subgrupo5]          VARCHAR (1)     NULL,
    [FactorUnid]         INT             NULL,
    [FactorVta]          INT             NULL,
    [Bonificacion]       VARCHAR (1)     NULL,
    [Peso]               NUMERIC (2, 2)  NULL,
    [PrecioCompra]       NUMERIC (14, 4) NULL,
    [PrecioSugerido]     NUMERIC (14, 4) NULL,
    [PrecioPromedio]     NUMERIC (14, 4) NULL,
    [proveedor]          VARCHAR (1)     NULL,
    [grupo]              VARCHAR (1)     NULL,
    [Subgrupo1]          VARCHAR (1)     NULL,
    [Subgrupo2]          VARCHAR (1)     NULL,
    [Subgrupo3]          VARCHAR (1)     NULL,
    [Subgrupo4]          VARCHAR (1)     NULL,
    [CodigoDistribuidor] VARCHAR (50)    NULL,
    [FeRegistro]         VARCHAR (12)    NULL
);


GO

