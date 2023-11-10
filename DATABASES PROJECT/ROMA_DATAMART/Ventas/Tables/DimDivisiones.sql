CREATE TABLE [Ventas].[DimDivisiones] (
    [IdGrupoVenta] SMALLINT     IDENTITY (1, 1) NOT NULL,
    [GrupoVenta]   VARCHAR (50) NULL,
    CONSTRAINT [PK_DimGrupoVenta] PRIMARY KEY CLUSTERED ([IdGrupoVenta] ASC)
);


GO

