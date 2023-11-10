CREATE TABLE [Ventas].[DimMotivosPedido] (
    [CodMotivo]   VARCHAR (4)  NOT NULL,
    [NomMotivo]   VARCHAR (50) COLLATE Latin1_General_CI_AI NOT NULL,
    [GrupoMotivo] VARCHAR (50) NULL,
    CONSTRAINT [PK_DimMotivosPedido] PRIMARY KEY CLUSTERED ([CodMotivo] ASC)
);


GO

