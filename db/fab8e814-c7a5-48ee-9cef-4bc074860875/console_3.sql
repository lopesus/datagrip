CREATE PROCEDURE [dbo].[US_PostalizzazioneLettera_04](@Anno INT)
AS
    SET NOCOUNT ON

SELECT pos.IdPostalizzazioneLettera,
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
         OUTER APPLY (SELECT TOP 1 IdIndirizzo
                      FROM Indirizzo (NOLOCK)
                      WHERE IdTipoProvenienza = 3
                        AND IdAnagraficaAssicurato = L.IdAnagraficaAssicurato -- Use IdAnagraficaAssicurato from Lettera table
                        AND DataCancellazione IS NULL
                      ORDER BY 1 DESC) AS IndArca
         OUTER APPLY (SELECT TOP 1 IdIndirizzo
                      FROM Indirizzo (NOLOCK)
                      WHERE IdTipoProvenienza = 1
                        AND IdAnagraficaAssicurato = L.IdAnagraficaAssicurato -- Use IdAnagraficaAssicurato from Lettera table
                        AND DataCancellazione IS NULL
                      ORDER BY 1 DESC) AS IndSede
         INNER JOIN dbo.Indirizzo I (NOLOCK) ON L.IdAnagraficaAssicurato = I.IdAnagraficaAssicurato AND
                                                I.IdIndirizzo = COALESCE(IndArca.IdIndirizzo, IndSede.IdIndirizzo)
         INNER JOIN dbo.AnagraficaAssicurato A (NOLOCK) ON L.IdAnagraficaAssicurato = A.IdAnagraficaAssicurato
         INNER JOIN dbo.StatoSpedizione S (NOLOCK) ON pos.IdStatoSpedizione = S.IdStatoSpedizione
WHERE pos.XmlLettera IS NULL
  AND pos.FlagInviato = 0
GO
