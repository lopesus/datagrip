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
GO