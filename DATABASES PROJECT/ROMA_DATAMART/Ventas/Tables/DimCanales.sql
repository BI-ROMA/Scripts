CREATE TABLE [Ventas].[DimCanales] (
    [IdCan]  SMALLINT      NOT NULL,
    [CodCan] VARCHAR (2)   NULL,
    [NomCan] VARCHAR (100) NULL,
    CONSTRAINT [PK_DimCanales] PRIMARY KEY CLUSTERED ([IdCan] ASC)
);


GO

