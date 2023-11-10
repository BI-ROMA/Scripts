CREATE TABLE [Ventas].[DimSedes] (
    [IdSede]    SMALLINT      IDENTITY (1, 1) NOT NULL,
    [CodSede]   VARCHAR (10)  NULL,
    [NomSede]   VARCHAR (100) NULL,
    [Sucursal]  VARCHAR (50)  NULL,
    [Zona]      VARCHAR (15)  NULL,
    [Activo]    BIT           NULL,
    [IdAlmacen] SMALLINT      NULL,
    CONSTRAINT [PK_DimSedes] PRIMARY KEY CLUSTERED ([IdSede] ASC),
    CONSTRAINT [FK_DimSedes_DimAlmacenes] FOREIGN KEY ([IdAlmacen]) REFERENCES [Ventas].[DimAlmacenes] ([IdAlmacen])
);


GO

