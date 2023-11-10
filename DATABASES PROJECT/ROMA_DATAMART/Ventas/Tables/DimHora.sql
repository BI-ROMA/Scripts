CREATE TABLE [Ventas].[DimHora] (
    [IdHora]              INT       NOT NULL,
    [Tiempo]              DATETIME  NOT NULL,
    [Hora]                TINYINT   NOT NULL,
    [Minuto]              TINYINT   NOT NULL,
    [Segundo]             TINYINT   NOT NULL,
    [AM]                  CHAR (2)  NOT NULL,
    [NombreHora]          CHAR (2)  NOT NULL,
    [NombreHoraAM]        CHAR (5)  NOT NULL,
    [NombreMinuto]        CHAR (2)  NOT NULL,
    [NombreSegundo]       CHAR (2)  NOT NULL,
    [HoraMinuto]          CHAR (5)  NOT NULL,
    [HoraMinutoAM]        CHAR (8)  NOT NULL,
    [HoraMinutoSegundo]   CHAR (8)  NOT NULL,
    [HoraMinutoSegundoAM] CHAR (11) NOT NULL,
    CONSTRAINT [PK_Hora] PRIMARY KEY CLUSTERED ([IdHora] ASC)
);


GO

