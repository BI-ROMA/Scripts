CREATE TABLE [Ventas].[DimDocumentos] (
    [IdDoc]           INT          IDENTITY (1, 1) NOT NULL,
    [Serie]           VARCHAR (10) NULL,
    [Numero]          VARCHAR (20) NULL,
    [DocEntry]        INT          NOT NULL,
    [TiDocumento]     CHAR (2)     NULL,
    [FeCreate]        INT          NULL,
    [FlAlDiaAnterior] CHAR (1)     NULL,
    [FeRegistro]      DATETIME     DEFAULT (getdate()) NULL,
    [TaxDate]         VARCHAR (11) NULL,
    [Activo]          VARCHAR (2)  DEFAULT ('Si') NULL,
    CONSTRAINT [PK_DimDocumentos] PRIMARY KEY CLUSTERED ([IdDoc] ASC)
);


GO

CREATE NONCLUSTERED INDEX [idx_DimDocumentos_TiDocDocEntry]
    ON [Ventas].[DimDocumentos]([TiDocumento] ASC, [DocEntry] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_Documento_DocEntry]
    ON [Ventas].[DimDocumentos]([DocEntry] ASC);


GO

