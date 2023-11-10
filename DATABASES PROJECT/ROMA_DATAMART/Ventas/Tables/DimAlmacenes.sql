CREATE TABLE [Ventas].[DimAlmacenes] (
    [IdAlmacen]  SMALLINT     IDENTITY (0, 1) NOT NULL,
    [CodAlmacen] VARCHAR (10) NULL,
    [NomAlmacen] VARCHAR (50) NULL,
    CONSTRAINT [PK_DimAlmacenes] PRIMARY KEY CLUSTERED ([IdAlmacen] ASC)
);


GO

