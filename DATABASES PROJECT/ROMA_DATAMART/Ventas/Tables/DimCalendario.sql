CREATE TABLE [Ventas].[DimCalendario] (
    [IdCalendario] INT  IDENTITY (1, 1) NOT NULL,
    [Fecha]        DATE NULL,
    [FlFeriado]    BIT  DEFAULT ((0)) NOT NULL,
    [Dia]          AS   (datepart(day,[Fecha])),
    CONSTRAINT [PK_DimCalendario] PRIMARY KEY CLUSTERED ([IdCalendario] ASC)
);


GO

