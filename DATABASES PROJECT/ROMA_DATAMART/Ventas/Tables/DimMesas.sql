CREATE TABLE [Ventas].[DimMesas] (
    [IdMesa]  SMALLINT      IDENTITY (1, 1) NOT NULL,
    [CodMesa] NVARCHAR (8)  NOT NULL,
    [NomMesa] NVARCHAR (30) NOT NULL,
    [Grupo]   VARCHAR (20)  NULL,
    CONSTRAINT [PK_DimMesas] PRIMARY KEY CLUSTERED ([IdMesa] ASC)
);


GO

