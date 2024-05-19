
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

go
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
GO
--
SELECT  top 10 * from Lettera
--
SELECT  * from TipoLettera

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
GO

--

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

GO
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
GO

--

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
GO

