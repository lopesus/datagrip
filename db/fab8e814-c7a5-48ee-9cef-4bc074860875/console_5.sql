-- Creating a stored procedure to fetch 'Anno' and 'Bimestre' based on 'IdLettera'
CREATE PROCEDURE [dbo].[GetAnnoBimestreByIdLettera] @IdLettera INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT P.Anno,
           P.Bimestre
    FROM dbo.PagamentiRichiestiLettera PRL
             JOIN
         dbo.Pagamenti P ON PRL.IdPagamenti = P.IdPagamenti
    WHERE PRL.IdLettera = @IdLettera;
END;
GO
--

-- Updating the stored procedure to fetch 'Anno', 'Bimestre', and 'CausaleRidotta' based on 'IdLettera'
CREATE OR ALTER PROCEDURE [dbo].[GetAnnoBimestreCausaleByIdLettera] @IdLettera INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT P.Anno,
           P.Bimestre,
           MI.CausaleRidotta,
           MI.ImportoDovuto,
           MI.ImportoPagato,
           MI.DataScadenza,
           MI.CausaleRidotta,
           MI.ImportoMora
    FROM dbo.PagamentiRichiestiLettera PRL
             JOIN
         dbo.Pagamenti P ON PRL.IdPagamenti = P.IdPagamenti
             JOIN
         dbo.MAV_IUV MI ON PRL.IdMAV_IUV = MI.IdMAV_IUV
    WHERE PRL.IdLettera = @IdLettera;
END;
GO
--
EXEC  US_Lettera_IdLettera_02 @IdLettera = 0

--
CREATE PROCEDURE [dbo].[US_PostalizzazioneLettera_DocumentId] @IdLettera INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT PRL.DocumentId
    FROM dbo.PostalizzazioneLettera PRL
    WHERE PRL.IdLettera = @IdLettera;
END;
GO

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
GO

--
ALTER TABLE PostalizzazioneLettera
ADD CONSTRAINT DF_PostalizzazioneLettera_FlagInviato DEFAULT 0 FOR FlagInviato;


---
SELECT  * FROM  DettaglioLetteraAccertamento
WHERE IdLetteraAccertamento =82968