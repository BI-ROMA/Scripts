CREATE TABLE [Upload].[Tmp_mov_cuotas] (
    [periodo]         INT             NOT NULL,
    [sede]            VARCHAR (2)     NOT NULL,
    [codven]          SMALLINT        NULL,
    [nomven]          NVARCHAR (32)   COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [codprv]          VARCHAR (15)    NULL,
    [nomprv]          NVARCHAR (100)  COLLATE SQL_Latin1_General_CP850_CI_AS NULL,
    [cuota]           DECIMAL (37, 4) NOT NULL,
    [codgrupo]        VARCHAR (3)     NULL,
    [cuotamay]        INT             NOT NULL,
    [FactorCuota]     DECIMAL (18, 2) NULL,
    [CuotaTot]        DECIMAL (18, 2) NULL,
    [FactorCobertura] DECIMAL (18, 5) NULL,
    [grupovnd]        CHAR (2)        NULL,
    [codmesa]         CHAR (3)        NULL,
    [CodSup]          CHAR (4)        NULL,
    [CodCar]          VARCHAR (6)     NULL
);


GO

