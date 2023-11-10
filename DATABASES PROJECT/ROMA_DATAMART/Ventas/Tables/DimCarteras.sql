CREATE TABLE [Ventas].[DimCarteras] (
    [IdCartera]  SMALLINT     IDENTITY (0, 1) NOT NULL,
    [CodCartera] VARCHAR (15) NOT NULL,
    [NomCartera] VARCHAR (50) NOT NULL,
    [IdVendedor] SMALLINT     NULL,
    CONSTRAINT [PK_DimCarteras] PRIMARY KEY CLUSTERED ([IdCartera] ASC)
);


GO

