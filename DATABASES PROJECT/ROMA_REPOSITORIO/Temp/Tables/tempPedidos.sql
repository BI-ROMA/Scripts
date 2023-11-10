CREATE TABLE [Temp].[tempPedidos] (
    [Id]          SMALLINT IDENTITY (1, 1) NOT NULL,
    [HoMi]        INT      NULL,
    [IdPedidoMin] INT      NULL,
    [IdPedidoMax] INT      NULL,
    [Qtd]         INT      NULL,
    [Status]      BIT      NULL,
    [IdSede]      SMALLINT NULL,
    [feregistro]  DATETIME NULL,
    [idvendedor]  SMALLINT NULL,
    [IdPedido]    INT      NULL
);


GO

