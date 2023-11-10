CREATE TABLE [Ventas].[DimTipoVenta] (
    [IdTipoVenta] SMALLINT     NOT NULL,
    [TipoVenta]   VARCHAR (20) NULL,
    CONSTRAINT [PK_DimTipoVenta] PRIMARY KEY CLUSTERED ([IdTipoVenta] ASC)
);


GO

