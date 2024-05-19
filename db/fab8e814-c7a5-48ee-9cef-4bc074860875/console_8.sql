create table dbo.LetteraAccertamento
(
    IdLetteraAccertamento  int identity
        constraint PK_LetteraAccertamento
            primary key,
    IdAnagraficaAssicurato int                                                 not null
        constraint FK_LetteraAccertamento_AnagraficaAssicurato_IdAnagraficaAssicurato
            references dbo.AnagraficaAssicurato,
    AnnoRiferimento        smallint                                            not null,
    CodeLine               varchar(20),
    ImportoDovuto          smallmoney,
    DataEmissione          date,
    CausaleRidotta         varchar(30),
    AnnoIniziale           smallint,
    NumeroBimestreIniziale smallint,
    AnnoFinale             smallint,
    NumeroBimestreFinale   smallint,
    XmlPagoPA              xml,
    XmlLettera             xml,
    CodiceStampa           uniqueidentifier,
    DataStampa             datetime,
    CodiceSpedizione       uniqueidentifier,
    DataSpedizione         datetime,
    IdStatoSpedizione      int                                                 not null
        constraint FK_LetteraAccertamento_StatoSpedizione_IdStatoSpedizione
            references dbo.StatoSpedizione,
    FlagInviato            bit                                                 not null,
    DocumentId             varchar(50),
    DataInserimento        datetime
        constraint DF_LetteraAccertamento_DataInserimento default getdate()    not null,
    DataUltimaModifica     datetime
        constraint DF_LetteraAccertamento_DataUltimaModifica default getdate() not null,
    DataScadenza           date,
    NumeroAvviso           varchar(35),
    NumeroProtocollo       varchar(50),
    FlagDeceduto           bit
        constraint DF_LetteraAccertamento_FlagDeceduto default 0               not null
)
go

create index IX_LetteraAccertamento_AnnoRif_IdStatoSped_DocId_CodSped
    on dbo.LetteraAccertamento (AnnoRiferimento, IdStatoSpedizione, DocumentId) include (NumeroProtocollo,
                                                                                         CausaleRidotta,
                                                                                         IdLetteraAccertamento,
                                                                                         IdAnagraficaAssicurato)
    where [CodiceSpedizione] IS NULL
    on IndexData
go

create index IX_LetteraAccertamento_AnnoRiferimento_IdAnagraficaAssicurato_IdStatoSpedizione
    on dbo.LetteraAccertamento (AnnoRiferimento, IdAnagraficaAssicurato, IdStatoSpedizione) include (ImportoDovuto,
                                                                                                     DataEmissione,
                                                                                                     CodeLine,
                                                                                                     IdLetteraAccertamento,
                                                                                                     DocumentId,
                                                                                                     NumeroProtocollo,
                                                                                                     CausaleRidotta,
                                                                                                     DataScadenza,
                                                                                                     AnnoIniziale,
                                                                                                     NumeroBimestreIniziale,
                                                                                                     AnnoFinale,
                                                                                                     NumeroBimestreFinale,
                                                                                                     CodiceStampa,
                                                                                                     CodiceSpedizione)
    on IndexData
go

create index IX_LetteraAccertamento_IdStatoSpedizione
    on dbo.LetteraAccertamento (IdStatoSpedizione) include (FlagDeceduto, AnnoRiferimento, IdAnagraficaAssicurato,
                                                            ImportoDovuto, DataEmissione, CodeLine,
                                                            IdLetteraAccertamento, DocumentId, NumeroProtocollo,
                                                            CausaleRidotta, DataScadenza, DataSpedizione)
    on IndexData
go

create index IX_LetteraAccertamento_AnnoRiferimento_FlagInviato
    on dbo.LetteraAccertamento (AnnoRiferimento, FlagInviato) include (IdStatoSpedizione, IdAnagraficaAssicurato,
                                                                       IdLetteraAccertamento, CodeLine, ImportoDovuto,
                                                                       DataEmissione, CausaleRidotta, NumeroAvviso,
                                                                       XmlPagoPA, XmlLettera)
    on IndexData
go

create index IX_LetteraAccertamento_AnnoRiferimento
    on dbo.LetteraAccertamento (AnnoRiferimento) include (CodiceStampa, FlagDeceduto, IdAnagraficaAssicurato,
                                                          ImportoDovuto, IdLetteraAccertamento, CodeLine)
    on IndexData
go

create index IX_LetteraAccertamento_IdAnagraficaAssicurato_AnnoRiferimento_CodeLine
    on dbo.LetteraAccertamento (IdAnagraficaAssicurato, AnnoRiferimento, CodeLine) include (XmlLettera,
                                                                                            NumeroProtocollo,
                                                                                            CodiceSpedizione,
                                                                                            CodiceStampa, FlagInviato)
    on IndexData
go

create index IX_LetteraAccertamento_AnnoRiferimento_IdAnagraficaAssicurato_IdStatoSpedizione_FlgDec
    on dbo.LetteraAccertamento (AnnoRiferimento, IdAnagraficaAssicurato, IdStatoSpedizione,
                                FlagDeceduto) include (DataSpedizione, ImportoDovuto, DataEmissione, CodeLine,
                                                       IdLetteraAccertamento, DocumentId, NumeroProtocollo,
                                                       CausaleRidotta, DataScadenza, AnnoIniziale,
                                                       NumeroBimestreIniziale, AnnoFinale, NumeroBimestreFinale,
                                                       CodiceStampa, CodiceSpedizione)
    on IndexData
go

create index IX_LetteraAccertamento_AnnoRif_FlgDec
    on dbo.LetteraAccertamento (AnnoRiferimento, FlagDeceduto) include (IdLetteraAccertamento, CodeLine, XmlPagoPA)
    on IndexData
go

create index IX_LetteraAccertamento_AnnoRiferimento_FlagInviato_FlgDec
    on dbo.LetteraAccertamento (AnnoRiferimento, FlagInviato, FlagDeceduto) include (IdStatoSpedizione,
                                                                                     IdAnagraficaAssicurato,
                                                                                     IdLetteraAccertamento, CodeLine,
                                                                                     ImportoDovuto, DataEmissione,
                                                                                     CausaleRidotta, NumeroAvviso,
                                                                                     XmlPagoPA, XmlLettera)
    on IndexData
go

create index IX_LetteraAccertamento_FlgDec
    on dbo.LetteraAccertamento (FlagDeceduto) include (IdStatoSpedizione, CodiceSpedizione, CodiceStampa,
                                                       AnnoRiferimento, IdAnagraficaAssicurato, ImportoDovuto,
                                                       DataEmissione, CodeLine, IdLetteraAccertamento, DocumentId,
                                                       NumeroProtocollo, CausaleRidotta, DataScadenza, DataSpedizione)
    on IndexData
go

