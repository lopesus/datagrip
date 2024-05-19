SELECT  *  from ActionKeys
WHERE Action LIKE '%Amministrazione%'

--
SELECT  *  from ActionKeys
WHERE Action LIKE '%DetailsAssicurato%'
--

BEGIN
    DECLARE @LastCode int

-- Find the last value of Code
SELECT @LastCode = MAX(Code) FROM dbo.ActionKeys

-- Insert a row with CodeParent as the last value + 1
INSERT INTO dbo.ActionKeys (Code, CodeParent, Type, Text,  IdProcess, [Order], Action,  Visible)
VALUES (@LastCode + 1, 206, 'ACTION', 'CreatePagoPaDilazione', 3, 0, 'Amministrazione/CreatePagoPaDilazione',  1)

END

--
    CREATE PROCEDURE US_LetteraAccertamento_DatiDilazione_01
    @IdAnagraficaAssicurato INT
AS
BEGIN
    SELECT ImportoDovuto
    FROM dbo.LetteraAccertamento
    WHERE IdAnagraficaAssicurato = @IdAnagraficaAssicurato;
END;
GO
--

--
-- Create the DilazioneLetteraAccertamento Table
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
);

-- Create the DettaglioDilazioneLetteraAccertamento Table
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
);

-- Create a new index on DettaglioDilazioneLetteraAccertamento for quick lookups on multiple columns
CREATE INDEX IDX_DettaglioDilazione ON dbo.DettaglioDilazioneLetteraAccertamento (IdDilazioneLetteraAccertamento, DataScadenza);

-- Optionally, if not already included, create additional supporting indexes for the LetteraAccertamento table as necessary
-- Note: Adjust index fields and included columns as necessary based on your query patterns and performance analysis

--
CREATE TYPE dbo.DT_UI_RataDilazione AS TABLE
(
    NumeroRata INT,
    ImportoRata DECIMAL,
    DataScadenza DATETIME,
    ImportoCapitale DECIMAL,
    ImportoInteressi DECIMAL
);
--

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
GO

--
SELECT * from DilazioneLetteraAccertamento

--
SELECT * from DettaglioDilazioneLetteraAccertamento
