CREATE TABLE [Ventas].[DimBonificaciones] (
    [FlBonificacion] CHAR (1) NOT NULL,
    [EsBonificacion] CHAR (2) NULL,
    CONSTRAINT [PK_Dim_Bonificacion] PRIMARY KEY CLUSTERED ([FlBonificacion] ASC)
);


GO

