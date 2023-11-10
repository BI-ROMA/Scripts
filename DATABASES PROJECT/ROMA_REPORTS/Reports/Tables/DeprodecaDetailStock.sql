CREATE TABLE [Reports].[DeprodecaDetailStock] (
    [DateKey]     INT             NOT NULL,
    [ProductCode] VARCHAR (20)    NULL,
    [ProductName] VARCHAR (100)   NULL,
    [Piece]       VARCHAR (3)     NOT NULL,
    [Ayacucho]    DECIMAL (38, 2) NOT NULL,
    [Chincha]     DECIMAL (38, 2) NOT NULL,
    [Ica]         DECIMAL (38, 2) NOT NULL,
    [Total]       DECIMAL (38, 2) NULL
);


GO

