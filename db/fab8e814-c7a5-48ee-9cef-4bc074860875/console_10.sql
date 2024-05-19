create table dbo.SollecitoLetteraAccertamento
(
    IdSollecitoLetteraAccertamento int identity
        constraint PK_SollecitoLetteraAccertamento
            primary key,
    IdAnagraficaAssicurato         int                                                  not null
        constraint FK_SollecitoLetteraAccertamento_AnagraficaAssicurato_IdAnagraficaAssicurato
            references dbo.AnagraficaAssicurato,
    AnnoRiferimento                smallint                                             not null,
    CodeLine                       varchar(20),
    ImportoDovuto                  smallmoney,
    DataEmissione                  date,
    CausaleRidotta                 varchar(30),
    AnnoIniziale                   smallint,
    NumeroBimestreIniziale         smallint,
    AnnoFinale                     smallint,
    NumeroBimestreFinale           smallint,
    XmlPagoPA                      xml,
    XmlLettera                     xml,
    CodiceStampa                   uniqueidentifier,
    DataStampa                     datetime,
    CodiceSpedizione               uniqueidentifier,
    DataSpedizione                 datetime,
    IdStatoSpedizione              int                                                  not null
        constraint FK_SollecitoLetteraAccertamento_StatoSpedizione_IdStatoSpedizione
            references dbo.StatoSpedizione,
    FlagInviato                    bit                                                  not null,
    DocumentId                     varchar(50),
    DataInserimento                datetime
        constraint DF_SollecitoLetteraAccertamento_DataInserimento default getdate()    not null,
    DataUltimaModifica             datetime
        constraint DF_SollecitoLetteraAccertamento_DataUltimaModifica default getdate() not null,
    DataScadenza                   date,
    NumeroAvviso                   varchar(35),
    NumeroProtocollo               varchar(50),
    FlagDeceduto                   bit
        constraint DF_SollecitoLetteraAccertamento_FlagDeceduto default 0               not null
)
go

