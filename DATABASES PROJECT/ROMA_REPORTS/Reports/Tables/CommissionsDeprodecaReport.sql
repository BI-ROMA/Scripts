CREATE TABLE [Reports].[CommissionsDeprodecaReport] (
    [periodo]                  VARCHAR (6)      NULL,
    [CodSede]                  VARCHAR (10)     NULL,
    [NomSede]                  VARCHAR (100)    NULL,
    [CodMesa]                  NVARCHAR (8)     NOT NULL,
    [NomMesa]                  NVARCHAR (30)    NOT NULL,
    [grupo]                    VARCHAR (20)     NULL,
    [CodCartera]               VARCHAR (15)     NOT NULL,
    [NomCartera]               VARCHAR (50)     NOT NULL,
    [CodPrv]                   VARCHAR (20)     NULL,
    [NomPrvAbr]                VARCHAR (100)    NULL,
    [CodCat]                   CHAR (3)         NULL,
    [NomCat]                   VARCHAR (100)    NULL,
    [catprv]                   VARCHAR (20)     NULL,
    [CodCan]                   VARCHAR (2)      NULL,
    [NomCan]                   VARCHAR (100)    NULL,
    [CodVen]                   SMALLINT         NULL,
    [NomVen]                   NVARCHAR (120)   NULL,
    [CodSup]                   NVARCHAR (8)     NULL,
    [NomSup]                   NVARCHAR (120)   NULL,
    [CodJV]                    NVARCHAR (8)     NULL,
    [NomJV]                    NVARCHAR (120)   NULL,
    [vtamesant]                DECIMAL (38, 2)  NOT NULL,
    [cuota]                    DECIMAL (38, 2)  NULL,
    [SumCuota]                 DECIMAL (38, 2)  NULL,
    [vta]                      DECIMAL (38, 2)  NOT NULL,
    [SumVta]                   DECIMAL (38, 2)  NULL,
    [vtaPry]                   NUMERIC (38, 6)  NULL,
    [SumVtaPry]                NUMERIC (38, 6)  NULL,
    [VtaPryPrc]                NUMERIC (38, 6)  NULL,
    [SumVtaPryPrc]             DECIMAL (10, 2)  NULL,
    [FlagVta]                  INT              NOT NULL,
    [FlagVtaMax]               INT              NOT NULL,
    [cartera]                  INT              NULL,
    [FactorCob]                DECIMAL (18, 5)  NOT NULL,
    [cobertura]                INT              NOT NULL,
    [MaxCobertura]             INT              NULL,
    [cobmeta]                  DECIMAL (18, 2)  NOT NULL,
    [MaxCobmeta]               DECIMAL (18, 2)  NULL,
    [cobPry]                   NUMERIC (36, 13) NULL,
    [MaxCobPry]                NUMERIC (36, 13) NULL,
    [cobPryPrc]                NUMERIC (38, 13) NOT NULL,
    [MaxCobPryPrc]             DECIMAL (10, 2)  NULL,
    [FlagCob]                  INT              NOT NULL,
    [FlagCobMax]               INT              NOT NULL,
    [devolucion]               DECIMAL (38, 2)  NOT NULL,
    [devPry]                   NUMERIC (38, 6)  NULL,
    [devPryPrc]                NUMERIC (38, 6)  NOT NULL,
    [DiasValidosMes]           INT              NULL,
    [DiasValidosTranscurridos] INT              NULL,
    [DiasFaltantes]            INT              NULL,
    [numcat]                   VARCHAR (1)      NOT NULL,
    [peso]                     INT              NULL,
    [escala]                   NUMERIC (18, 2)  NULL,
    [excedente]                DECIMAL (18, 2)  NULL,
    [BaseVtaCom]               NUMERIC (37, 4)  NULL,
    [BaseCobCom]               NUMERIC (37, 4)  NULL,
    [ComVta]                   VARCHAR (1)      NOT NULL,
    [SumComVta]                INT              NOT NULL,
    [ComCob]                   VARCHAR (1)      NOT NULL,
    [SumComCob]                INT              NOT NULL,
    [ComTotal]                 INT              NOT NULL,
    [Sueldo]                   INT              NOT NULL
);


GO
