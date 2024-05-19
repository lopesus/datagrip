create table dbo.TipoCausale
(
    IdTipoCausale          int identity
        constraint PK_TipoCausale
            primary key,
    CodiceTipoCausale      varchar(4)   not null,
    DescrizioneTipoCausale varchar(300) not null,
    Ordine                 int          not null
)
go

create unique index IUX_TipoCausale_CodiceTipoCausale
    on dbo.TipoCausale (CodiceTipoCausale) include (DescrizioneTipoCausale, Ordine)
    with (fillfactor = 80)
    on IndexData
go

