CREATE TABLE [Ventas].[Fact_Cartera] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [DocDate]      DATE         NOT NULL,
    [IdVen]        SMALLINT     NULL,
    [IdCli]        INT          NULL,
    [CodCli]       VARCHAR (50) NULL,
    [IdCar]        SMALLINT     NULL,
    [Qtd]          SMALLINT     NULL,
    [IdSup]        SMALLINT     NULL,
    [IdSed]        SMALLINT     NULL,
    [PartitionDay] INT          NULL,
    [FechaKey]     INT          NULL,
    [IdCarteraNew] SMALLINT     NULL,
    CONSTRAINT [PK_Fact_Cobertura] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Fact_Cartera_DimCarteras] FOREIGN KEY ([IdCarteraNew]) REFERENCES [Ventas].[DimCarteras] ([IdCartera]),
    CONSTRAINT [FK_Fact_Cartera_DimClientes] FOREIGN KEY ([IdCli]) REFERENCES [Ventas].[DimClientes] ([IdCli]),
    CONSTRAINT [FK_Fact_Cartera_DimFechas] FOREIGN KEY ([FechaKey]) REFERENCES [Ventas].[DimFechas] ([FechaKey]),
    CONSTRAINT [FK_Fact_Cartera_DimVendedores] FOREIGN KEY ([IdVen]) REFERENCES [Ventas].[DimVendedores] ([IdVen])
);


GO

