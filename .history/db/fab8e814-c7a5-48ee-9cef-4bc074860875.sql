UPDATE PostalizzazioneLettera
SET FlagInviato = 0
WHERE FlagInviato IS NULL
;-- -. . -..- - / . -. - .-. -.--
select * from PostalizzazioneLettera
;-- -. . -..- - / . -. - .-. -.--
CREATE PROCEDURE [dbo].[US_PostalizzazioneLettera_04](
    @Anno INT
)
AS

    SET NOCOUNT ON

SELECT pos.IdPostalizzazioneLettera
     , pos.CodeLine
     , pos.XmlPagoPA
     , pos.XmlLettera
     , pos.NumeroAvviso
     , S.CodiceStatoSpedizione
     , S.DescrizioneStatoSpedizione
     , A.IdAnagraficaAssicurato
     , A.CodiceFiscale
     , A.Nome
     , A.Cognome
     , I.Indirizzo
     , I.CAP
     , I.Comune
     , I.Provincia
     , pos.NumeroProtocollo
FROM dbo.PostalizzazioneLettera pos (NOLOCK)
         OUTER APPLY (SELECT TOP 1 IdIndirizzo
                      FROM Indirizzo (NOLOCK)
                      WHERE IdTipoProvenienza = 3
                        AND IdAnagraficaAssicurato = pos.IdAnagraficaAssicurato
                        AND DataCancellazione IS NULL
                      ORDER BY 1 DESC) AS IndArca
         OUTER APPLY (SELECT TOP 1 IdIndirizzo
                      FROM Indirizzo (NOLOCK)
                      WHERE IdTipoProvenienza = 1
                        AND IdAnagraficaAssicurato = pos.IdAnagraficaAssicurato
                        AND DataCancellazione IS NULL
                      ORDER BY 1 DESC) AS IndSede
         INNER JOIN dbo.Indirizzo I (NOLOCK) ON pos.IdAnagraficaAssicurato = I.IdAnagraficaAssicurato AND I.IdIndirizzo = COALESCE(IndArca.IdIndirizzo, IndSede.IdIndirizzo)
         INNER JOIN dbo.AnagraficaAssicurato A (NOLOCK) ON pos.IdAnagraficaAssicurato = A.IdAnagraficaAssicurato
         INNER JOIN dbo.StatoSpedizione S (NOLOCK) ON pos.IdStatoSpedizione = S.IdStatoSpedizione
WHERE pos.XmlLettera IS NULL
  AND FlagInviato = 0
;-- -. . -..- - / . -. - .-. -.--
CREATE PROCEDURE [dbo].[US_PostalizzazioneLettera_04](@Anno INT)
AS
SET NOCOUNT ON

SELECT
    pos.IdPostalizzazioneLettera,
    pos.CodeLine,
    pos.XmlPagoPA,
    pos.XmlLettera,
    pos.NumeroAvviso,
    S.CodiceStatoSpedizione,
    S.DescrizioneStatoSpedizione,
    A.IdAnagraficaAssicurato,
    A.CodiceFiscale,
    A.Nome,
    A.Cognome,
    I.Indirizzo,
    I.CAP,
    I.Comune,
    I.Provincia,
    pos.NumeroProtocollo,
    L.IdAnagraficaAssicurato -- Get IdAnagraficaAssicurato from Lettera table
FROM dbo.PostalizzazioneLettera pos (NOLOCK)
JOIN dbo.Lettera L ON pos.idLettera = L.idLettera -- Join with Lettera table to get IdAnagraficaAssicurato
OUTER APPLY (
    SELECT TOP 1 IdIndirizzo
    FROM Indirizzo (NOLOCK)
    WHERE IdTipoProvenienza = 3
      AND IdAnagraficaAssicurato = L.IdAnagraficaAssicurato -- Use IdAnagraficaAssicurato from Lettera table
      AND DataCancellazione IS NULL
    ORDER BY 1 DESC
) AS IndArca
OUTER APPLY (
    SELECT TOP 1 IdIndirizzo
    FROM Indirizzo (NOLOCK)
    WHERE IdTipoProvenienza = 1
      AND IdAnagraficaAssicurato = L.IdAnagraficaAssicurato -- Use IdAnagraficaAssicurato from Lettera table
      AND DataCancellazione IS NULL
    ORDER BY 1 DESC
) AS IndSede
INNER JOIN dbo.Indirizzo I (NOLOCK) ON L.IdAnagraficaAssicurato = I.IdAnagraficaAssicurato AND I.IdIndirizzo = COALESCE(IndArca.IdIndirizzo, IndSede.IdIndirizzo)
INNER JOIN dbo.AnagraficaAssicurato A (NOLOCK) ON L.IdAnagraficaAssicurato = A.IdAnagraficaAssicurato
INNER JOIN dbo.StatoSpedizione S (NOLOCK) ON pos.IdStatoSpedizione = S.IdStatoSpedizione
WHERE pos.XmlLettera IS NULL AND pos.FlagInviato = 0
;-- -. . -..- - / . -. - .-. -.--
CREATE PROCEDURE [dbo].[UU_PostalizzazioneLettera_XmlLettera_02]
(
	@IdLettera INT,
	--@AnnoRiferimento SMALLINT,
	@CodeLine VARCHAR(20),
	@XmlLettera XML
	--@NumeroProtocollo VARCHAR(50)
)
AS

SET NOCOUNT ON

UPDATE dbo.PostalizzazioneLettera SET XmlLettera = @XmlLettera
                                      --NumeroProtocollo = @NumeroProtocollo
WHERE IdLettera = @IdLettera
AND CodeLine = @CodeLine
;-- -. . -..- - / . -. - .-. -.--
--
CREATE PROCEDURE [dbo].[UU_PostalizzazioneLettera_04]
(
	@IdLettera INT,
	@CodeLine VARCHAR(20),
	@TaskID varchar(36)
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION
SET XACT_ABORT ON

	UPDATE dbo.PostalizzazioneLettera
	SET FlagInviato = 1,
		CodiceStampa = CAST(@TaskID as uniqueidentifier)
	WHERE IdLettera = @IdLettera
	AND CodeLine = @CodeLine

	UPDATE dbo.MAV_IUV
	SET IdStatoMAV = 2
	WHERE CodeLine = @CodeLine

IF XACT_STATE() = 1
	COMMIT

IF XACT_STATE() = -1
	ROLLBACK
;-- -. . -..- - / . -. - .-. -.--
SELECT  top 10 * from Lettera
;-- -. . -..- - / . -. - .-. -.--
SELECT  * from TipoLettera
;-- -. . -..- - / . -. - .-. -.--
--
CREATE PROCEDURE US_Lettera_CodiceTipoLettera
    @IdLettera INT
AS
BEGIN
    SELECT tl.CodiceTipoLettera
    FROM lettera AS l
    INNER JOIN TipoLettera AS tl ON l.IdTipoLettera = tl.idTipoLettera
    WHERE l.idlettera = @IdLettera;
END;
;-- -. . -..- - / . -. - .-. -.--
CREATE PROCEDURE [dbo].[US_AccodaRichiestaStampa_05]
@Anno INT
AS

SET NOCOUNT ON

SELECT DISTINCT
	Ars.IDAccodaRichiestaStampa,
	Ars.Risposta,
	Ars.Esito,
	Ars.Task_Id,
	La.NumeroProtocollo,
	--La.CausaleRidotta,
	La.IdPostalizzazioneLettera
FROM dbo.AccodaRichiestaStampa Ars (nolock)
INNER JOIN dbo.PostalizzazioneLettera La (nolock) ON Ars.TASK_ID = CAST(La.CodiceStampa as varchar(50))

WHERE La.CodiceSpedizione IS NULL
AND La.IdStatoSpedizione IN (1, 3, 11, 12, 13, 14, 15, 17)
AND La.DocumentId IS NULL
;-- -. . -..- - / . -. - .-. -.--
CREATE PROCEDURE [dbo].[US_AccodaRichiestaStampa_07]
@Anno INT
AS

SET NOCOUNT ON

SELECT DISTINCT
	Ars.IDAccodaRichiestaStampa,
	Ars.Risposta,
	Ars.Esito,
	Ars.Task_Id,
	La.NumeroProtocollo,
	--La.CausaleRidotta,
	La.IdPostalizzazioneLettera
FROM dbo.AccodaRichiestaStampa Ars (nolock)
INNER JOIN dbo.PostalizzazioneLettera La (nolock) ON Ars.TASK_ID = CAST(La.CodiceStampa as varchar(50))

WHERE La.CodiceSpedizione IS NULL
AND La.IdStatoSpedizione IN (1, 3, 11, 12, 13, 14, 15, 17)
AND La.DocumentId IS NULL
;-- -. . -..- - / . -. - .-. -.--
--
CREATE PROCEDURE US_PagamentiRichiestiLettera_CausaleRidotta
    @IdLettera INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT m.CausaleRidotta
    FROM PagamentiRichiestiLettera pr
    JOIN MAV_IUV m ON pr.IdMAV_IUV = m.IdMAV_IUV
    WHERE pr.IdLettera = @IdLettera;
END;
;-- -. . -..- - / . -. - .-. -.--
CREATE PROCEDURE US_PagamentiRichiestiLettera_Dettagli
    @IdLettera INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT m.CausaleRidotta,m.ImportoDovuto,m.ImportoMora,m.ImportoPagato
    FROM PagamentiRichiestiLettera pr
    JOIN MAV_IUV m ON pr.IdMAV_IUV = m.IdMAV_IUV
    WHERE pr.IdLettera = @IdLettera;
END;
;-- -. . -..- - / . -. - .-. -.--
EXEC  US_Lettera_IdLettera_02 @IdLettera = 0
;-- -. . -..- - / . -. - .-. -.--
--
CREATE PROCEDURE [dbo].[US_PostalizzazioneLettera_DocumentId] @IdLettera INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT PRL.DocumentId
    FROM dbo.PostalizzazioneLettera PRL
    WHERE PRL.IdLettera = @IdLettera;
END;
;-- -. . -..- - / . -. - .-. -.--
--
CREATE PROCEDURE [dbo].[UU_PostalizzazioneLettera_DocumentId](
    @IdPostalizzazioneLettera INTEGER,
	@DocumentId VARCHAR(50)
)
AS

SET NOCOUNT ON


UPDATE dbo.PostalizzazioneLettera
SET DocumentId = @DocumentId
WHERE IdPostalizzazioneLettera = @IdPostalizzazioneLettera
;-- -. . -..- - / . -. - .-. -.--
ALTER TABLE PostalizzazioneLettera
ADD FlagInviato BIT NOT NULL DEFAULT 0
;-- -. . -..- - / . -. - .-. -.--
ALTER TABLE PostalizzazioneLettera
ADD CONSTRAINT DF_PostalizzazioneLettera_FlagInviato DEFAULT 0 FOR FlagInviato
;-- -. . -..- - / . -. - .-. -.--
SELECT * from Lettera WHERE  IdLettera=11908
;-- -. . -..- - / . -. - .-. -.--
SELECT  *  from ActionKeys
WHERE Action LIKE 'Amministrazione'
;-- -. . -..- - / . -. - .-. -.--
SELECT  *  from ActionKeys
WHERE Action LIKE '%Amministrazione'
;-- -. . -..- - / . -. - .-. -.--
BEGIN
    DECLARE @LastCode int

-- Find the last value of Code
SELECT @LastCode = MAX(Code) FROM dbo.ActionKeys

-- Insert a row with CodeParent as the last value + 1
INSERT INTO dbo.ActionKeys (Code, CodeParent, Type, Text,  IdProcess, [Order], Action,  Visible)
VALUES (@LastCode + 1, 206, 'ACTION', 'Dilazioni pagamenti', 3, 0, 'Amministrazione/Dilazionipagamenti',  1)

END
;-- -. . -..- - / . -. - .-. -.--
SELECT  *  from ActionKeys
WHERE Action LIKE '%DetailsAssicurato%'
;-- -. . -..- - / . -. - .-. -.--
SELECT  *  from ActionKeys
WHERE Action LIKE '%Amministrazione%'
;-- -. . -..- - / . -. - .-. -.--
CREATE TABLE dbo.DilazioneLetteraAccertamento
(
    IdDilazioneLetteraAccertamento INT IDENTITY(1,1) PRIMARY KEY,
    FlagSollecito BIT NOT NULL DEFAULT 0,
    IdLetteraAccertamento INT NULL,
    IdSollecitoLetteraAccertamento INT NULL,
    ImportoTotale SMALLMONEY NOT NULL,
    NumeroRate SMALLINT NOT NULL,
    DataEmissionePiano DATE NOT NULL,
    ImportoPrimaRata SMALLMONEY NOT NULL,
    ImportoRataCostante SMALLMONEY NOT NULL,
    CONSTRAINT FK_Dilazione_LetteraAccertamento FOREIGN KEY (IdLetteraAccertamento)
        REFERENCES dbo.LetteraAccertamento (IdLetteraAccertamento),
    CONSTRAINT FK_Dilazione_SollecitoLetteraAccertamento FOREIGN KEY (IdSollecitoLetteraAccertamento)
        REFERENCES dbo.SollecitoLetteraAccertamento (IdSollecitoLetteraAccertamento)
)
;-- -. . -..- - / . -. - .-. -.--
CREATE TABLE dbo.DettaglioDilazioneLetteraAccertamento
(
    IdDettaglioDilazioneLetteraAccertamento INT IDENTITY(1,1) PRIMARY KEY,
    IdDilazioneLetteraAccertamento INT NOT NULL,
    NumeroRata SMALLINT NOT NULL,
    ImportoRata SMALLMONEY NOT NULL,
    DataScadenza DATE NOT NULL,
    ImportoCapitale SMALLMONEY NOT NULL,
    ImportoInteressi SMALLMONEY NOT NULL,
    Codeline VARCHAR(255) NULL,
    CONSTRAINT FK_Dettaglio_DilazioneLetteraAccertamento FOREIGN KEY (IdDilazioneLetteraAccertamento)
        REFERENCES dbo.DilazioneLetteraAccertamento (IdDilazioneLetteraAccertamento)
)
;-- -. . -..- - / . -. - .-. -.--
SELECT  *  from ActionKeys
WHERE Action LIKE '%Mnager%'
;-- -. . -..- - / . -. - .-. -.--
SELECT  *  from ActionKeys
WHERE Action LIKE '%Manager%'
;-- -. . -..- - / . -. - .-. -.--
--
    CREATE PROCEDURE US_LetteraAccertamento_DatiDilazione_01
    @IdAnagraficaAssicurato INT
AS
BEGIN
    SELECT ImportoDovuto
    FROM dbo.LetteraAccertamento
    WHERE IdAnagraficaAssicurato = @IdAnagraficaAssicurato;
END;
;-- -. . -..- - / . -. - .-. -.--
BEGIN
    DECLARE @LastCode int

-- Find the last value of Code
SELECT @LastCode = MAX(Code) FROM dbo.ActionKeys

-- Insert a row with CodeParent as the last value + 1
INSERT INTO dbo.ActionKeys (Code, CodeParent, Type, Text,  IdProcess, [Order], Action,  Visible)
VALUES (@LastCode + 1, 206, 'ACTION', 'GetDatiDilazione', 3, 0, 'Amministrazione/GetDatiDilazione',  1)

END
;-- -. . -..- - / . -. - .-. -.--
BEGIN
    DECLARE @LastCode int

-- Find the last value of Code
SELECT @LastCode = MAX(Code) FROM dbo.ActionKeys

-- Insert a row with CodeParent as the last value + 1
INSERT INTO dbo.ActionKeys (Code, CodeParent, Type, Text,  IdProcess, [Order], Action,  Visible)
VALUES (@LastCode + 1, 206, 'ACTION', 'CreatePagoPaDilazione', 3, 0, 'Amministrazione/CreatePagoPaDilazione',  1)

END
;-- -. . -..- - / . -. - .-. -.--
CREATE TYPE dbo.RataDilazioneType AS TABLE
(
    NumeroRata INT,
    ImportoRata DECIMAL,
    DataScadenza DATETIME,
    ImportoCapitale DECIMAL,
    ImportoInteressi DECIMAL
)
;-- -. . -..- - / . -. - .-. -.--
CREATE PROCEDURE [dbo].[UI_LetteraAccertamento_Dilazioni]
    @FlagSollecito BIT,
    @IdLetteraAccertamento INT = NULL,
    @IdSollecitoLetteraAccertamento INT = NULL,
    @ImportoTotale SMALLMONEY,
    @NumeroRate SMALLINT,
    @DataEmissionePiano DATE,
    @ImportoPrimaRata SMALLMONEY,
    @ImportoRataCostante SMALLMONEY,
    @Rate dbo.RataDilazioneType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DilazioneLetteraAccertamentoID INT;

    BEGIN TRANSACTION;
    SET XACT_ABORT ON;

    -- Insert into DilazioneLetteraAccertamento table
    INSERT INTO dbo.DilazioneLetteraAccertamento
        (FlagSollecito, IdLetteraAccertamento, IdSollecitoLetteraAccertamento, ImportoTotale, NumeroRate,
         DataEmissionePiano, ImportoPrimaRata, ImportoRataCostante)
    VALUES
        (@FlagSollecito, @IdLetteraAccertamento, @IdSollecitoLetteraAccertamento, @ImportoTotale, @NumeroRate,
         @DataEmissionePiano, @ImportoPrimaRata, @ImportoRataCostante);

    SET @DilazioneLetteraAccertamentoID = SCOPE_IDENTITY();

    -- Insert into DettaglioDilazioneLetteraAccertamento table
    INSERT INTO dbo.DettaglioDilazioneLetteraAccertamento
        (IdDilazioneLetteraAccertamento, NumeroRata, ImportoRata, DataScadenza, ImportoCapitale, ImportoInteressi)
    SELECT
        @DilazioneLetteraAccertamentoID, NumeroRata, ImportoRata, DataScadenza, ImportoCapitale, ImportoInteressi
    FROM @Rate;

    -- Error handling and transaction commit/rollback
    IF XACT_STATE() = 1
    BEGIN
        COMMIT TRANSACTION;
    END
    ELSE IF XACT_STATE() = -1
    BEGIN
        ROLLBACK TRANSACTION;
    END
END;
;-- -. . -..- - / . -. - .-. -.--
CREATE TYPE dbo.DT_UI_RataDilazione AS TABLE
(
    NumeroRata INT,
    ImportoRata DECIMAL,
    DataScadenza DATETIME,
    ImportoCapitale DECIMAL,
    ImportoInteressi DECIMAL
)
;-- -. . -..- - / . -. - .-. -.--
SELECT * from DilazioneLetteraAccertamento
;-- -. . -..- - / . -. - .-. -.--
SELECT  * FROM  DettaglioLetteraAccertamento
WHERE IdLetteraAccertamento =82968
;-- -. . -..- - / . -. - .-. -.--
SELECT * from DettaglioDilazioneLetteraAccertamento