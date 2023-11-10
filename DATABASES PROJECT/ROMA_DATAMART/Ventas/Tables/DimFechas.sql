CREATE TABLE [Ventas].[DimFechas] (
    [Fecha]               DATE         NOT NULL,
    [FlFeriado]           BIT          NULL,
    [FlUltimoDiaAnterior] SMALLINT     NULL,
    [Año]                 SMALLINT     NULL,
    [Mes]                 SMALLINT     NULL,
    [Dia]                 SMALLINT     NULL,
    [DiaMes]              VARCHAR (6)  NULL,
    [DiaAño]              VARCHAR (10) NULL,
    [NuNombreMes]         CHAR (6)     NULL,
    [NombreMes]           VARCHAR (20) NULL,
    [NombreMesAbr]        VARCHAR (20) NULL,
    [NombreDia]           VARCHAR (20) NULL,
    [NombreDiaAbr]        VARCHAR (20) NULL,
    [NombreDiaFull]       VARCHAR (30) NULL,
    [NombreFechaFull]     VARCHAR (50) NULL,
    [NuSemestre]          INT          NULL,
    [NoSemestre]          VARCHAR (30) NULL,
    [FechaKey]            INT          NOT NULL,
    [IdDiezDias]          INT          NULL,
    [NoDiezDias]          VARCHAR (50) NULL,
    [IdSemana]            INT          NULL,
    [NoSemana]            VARCHAR (20) NULL,
    [DiaSemana]           SMALLINT     NULL,
    [IdTrimestre]         INT          NULL,
    [NoTrimestre]         VARCHAR (5)  NULL,
    [NoTrimestreFull]     VARCHAR (20) NULL,
    [NuDiezDias]          SMALLINT     NULL,
    [IdDiaLaboral]        INT          NULL,
    [NuDiaLaboral]        SMALLINT     NULL,
    [NoDiaLaboral]        VARCHAR (5)  NULL,
    [DiasFaltates_xMes]   SMALLINT     NULL,
    [Fl4UltMesesCerrados] CHAR (1)     NULL,
    [FlUlt30DiasHabiles]  CHAR (1)     DEFAULT ('0') NULL,
    CONSTRAINT [PK_DimFechas] PRIMARY KEY CLUSTERED ([FechaKey] ASC)
);


GO


GRANT SELECT
    ON OBJECT::[Ventas].[DimFechas] TO [RBI\uJefes_dVenta]
    AS [dbo];
GO


GRANT SELECT
    ON OBJECT::[Ventas].[DimFechas] TO [RBI\uSupervisores_dVenta]
    AS [dbo];
GO


GRANT SELECT
    ON OBJECT::[Ventas].[DimFechas] TO [RBI\uVendedores]
    AS [dbo];
GO

