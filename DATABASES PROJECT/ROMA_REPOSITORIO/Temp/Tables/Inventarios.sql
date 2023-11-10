CREATE TABLE [Temp].[Inventarios] (
    [CodAlmacen]           VARCHAR (8)     NULL,
    [CodPrv]               VARCHAR (15)    NULL,
    [CodPro]               VARCHAR (20)    NOT NULL,
    [CoUnidadMedidaCompra] CHAR (5)        NULL,
    [QtdPiezas]            DECIMAL (18, 2) NULL,
    [Stock]                DECIMAL (18, 2) NULL,
    [PrecioCompra]         DECIMAL (18, 2) NULL,
    [Stock_Piezas]         DECIMAL (18, 2) NULL
);


GO

