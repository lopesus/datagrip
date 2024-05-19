UPDATE PostalizzazioneLettera
SET FlagInviato = 0
WHERE FlagInviato IS NULL;

--
ALTER TABLE PostalizzazioneLettera
ALTER COLUMN FlagInviato BIT NOT NULL;

--
select * from PostalizzazioneLettera