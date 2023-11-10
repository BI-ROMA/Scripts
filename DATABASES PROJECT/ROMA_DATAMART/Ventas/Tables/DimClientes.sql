CREATE TABLE [Ventas].[DimClientes] (
    [IdCli]           INT            IDENTITY (1, 1) NOT NULL,
    [CodCli]          VARCHAR (15)   NULL,
    [NomCli]          VARCHAR (100)  NULL,
    [FeRegistro]      DATETIME       DEFAULT (getdate()) NULL,
    [Origen]          VARCHAR (50)   NULL,
    [TiCliente]       VARCHAR (50)   NULL,
    [DiaVisita]       VARCHAR (20)   NULL,
    [TiNegocio]       VARCHAR (100)  NULL,
    [CodDom]          VARCHAR (10)   NULL,
    [Direccion]       VARCHAR (200)  NULL,
    [ClasifDeprodeca] VARCHAR (20)   NULL,
    [NumDoc]          VARCHAR (15)   NULL,
    [TipDoc]          VARCHAR (10)   NULL,
    [Latitude]        NVARCHAR (200) NULL,
    [Longitude]       NVARCHAR (200) NULL,
    CONSTRAINT [PK_DimClientes] PRIMARY KEY CLUSTERED ([IdCli] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_Cliente_CodCli]
    ON [Ventas].[DimClientes]([CodCli] ASC);


GO

