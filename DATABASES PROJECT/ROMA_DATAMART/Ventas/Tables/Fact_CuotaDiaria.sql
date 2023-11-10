CREATE TABLE [Ventas].[Fact_CuotaDiaria] (
    [periodo]      VARCHAR (6)     NULL,
    [IdSede]       SMALLINT        NULL,
    [IdVen]        SMALLINT        NULL,
    [IdCar]        SMALLINT        NULL,
    [IdSupervisor] SMALLINT        NULL,
    [IdCanal]      SMALLINT        NULL,
    [CodCat]       CHAR (3)        NULL,
    [IdMesa]       SMALLINT        NULL,
    [IdPrv]        SMALLINT        NULL,
    [Cuota]        DECIMAL (38, 2) NULL,
    [FactorSoles]  DECIMAL (18, 4) NULL,
    [TotalIGV]     DECIMAL (38, 2) NOT NULL,
    [fechakey]     VARCHAR (30)    NULL,
    [Cuotadiaria]  DECIMAL (38, 6) NULL
);


GO

