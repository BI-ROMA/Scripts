CREATE TABLE [Temp].[FactorCob] (
    [CodSede]      VARCHAR (10)    NULL,
    [CodCartera]   VARCHAR (15)    NOT NULL,
    [CodPrv]       VARCHAR (15)    NULL,
    [CodCan]       NVARCHAR (8)    COLLATE SQL_Latin1_General_CP850_CI_AS NOT NULL,
    [CodCat]       CHAR (3)        NULL,
    [TotalIGV_AVG] DECIMAL (38, 6) NULL,
    [Orden]        BIGINT          NULL,
    [TotalIGV_TOT] DECIMAL (38, 6) NULL,
    [Peso]         DECIMAL (18, 2) NULL
);


GO

