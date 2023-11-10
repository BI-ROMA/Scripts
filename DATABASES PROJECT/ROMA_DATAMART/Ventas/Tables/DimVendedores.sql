CREATE TABLE [Ventas].[DimVendedores] (
    [IdVen]        SMALLINT      IDENTITY (1, 1) NOT NULL,
    [CodVen]       SMALLINT      NULL,
    [NomVen]       VARCHAR (100) NOT NULL,
    [DiaVisita]    VARCHAR (50)  NULL,
    [U_Login]      VARCHAR (100) NULL,
    [CodCar]       VARCHAR (10)  NULL,
    [FeNacimiento] DATE          NULL,
    [Sexo]         CHAR (1)      NULL,
    [FeIngreso]    DATE          NULL,
    [CodMesa]      CHAR (3)      NULL,
    [CodSede]      CHAR (2)      NULL,
    [CodSup]       CHAR (4)      NULL,
    [CodCan]       CHAR (2)      NULL,
    [Estado]       CHAR (1)      NULL,
    [Email]        VARCHAR (150) NULL,
    [Documento]    VARCHAR (20)  NULL,
    CONSTRAINT [PK_DimVendedores] PRIMARY KEY CLUSTERED ([IdVen] ASC)
);


GO

