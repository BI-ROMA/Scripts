CREATE TABLE [Ventas].[DimTiposUsuarios] (
    [IdTipoUser] INT          IDENTITY (1, 1) NOT NULL,
    [TipoUser]   VARCHAR (50) NULL,
    [CodUser]    CHAR (2)     NULL,
    CONSTRAINT [PK_DimTipoUsuario] PRIMARY KEY CLUSTERED ([IdTipoUser] ASC)
);


GO

