/*
  Dedicated Znode API client for the test data agents on the BI Worldwide qa environment (bnjm-dv), story BMP-36.
  Same as create-tda-api-client.sql (written for `at`), with the template client chosen per environment.

  Run by a human with an admin login on the bnjm-dv (qa) database ONLY. Never on production.
  The agents' own DB user is read-only and cannot run this.

  Step 1: find the environment's working API client (the one the qa API gateway already accepts) and put its
          ClientId in @TemplateClientId. This query shows no secrets:
              SELECT ClientId, ClientName, ApplicationType, Issuer, Audience, AllowedApiScopes, IsActive, CreatedDate
              FROM dbo.ZnodeClient ORDER BY ClientId;
          Pick the row with ApplicationType 'API' whose Issuer is the qa (bnjm-dv) API gateway.
  Step 2: run this script. It inserts one row named @ClientName, copying Issuer, Audience, AllowedApiScopes,
          ApplicationType and CreatedBy from the template, with a random 64-character secret generated in SQL Server.
  Step 3: copy the printed name and secret straight into the data repository's git-ignored .env:
              TDA_API_CLIENT_ID=<ClientName, not the numeric ClientId>
              TDA_API_CLIENT_SECRET=<ClientSecret>
              TDA_API_CLIENT_DEDICATED=true
  Step 4: the gateway caches its client list: restart the qa API gateway (or wait for its cache to expire) before the
          first token request.

  If a client with @ClientName already exists, nothing changes (re-running is safe); rotate its secret instead if lost.
  To revoke later, delete the row or change its secret: the gateway does not check IsActive.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @ClientName nvarchar(200) = N'tda-test-data-agents-qa';
DECLARE @TemplateClientId int = NULL;   -- set from Step 1

IF @TemplateClientId IS NULL
BEGIN
    RAISERROR('Set @TemplateClientId to the qa API client first (Step 1).', 16, 1);
    RETURN;
END;

IF EXISTS (SELECT 1 FROM dbo.ZnodeClient WHERE ClientName = @ClientName)
BEGIN
    PRINT 'Client ' + @ClientName + ' already exists; nothing changed. Rotate its secret instead if it was lost.';
    RETURN;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.ZnodeClient WHERE ClientId = @TemplateClientId)
BEGIN
    RAISERROR('Template client %d not found.', 16, 1, @TemplateClientId);
    RETURN;
END;

DECLARE @Secret nvarchar(64) = CONVERT(nvarchar(64), CRYPT_GEN_RANDOM(32), 2);

BEGIN TRANSACTION;

INSERT INTO dbo.ZnodeClient (ClientName, ClientSecret, ApplicationType, Issuer, Audience, AllowedApiScopes, IsActive,
                             CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
SELECT @ClientName, @Secret, t.ApplicationType, t.Issuer, t.Audience, t.AllowedApiScopes, 1,
       t.CreatedBy, GETDATE(), t.CreatedBy, GETDATE()
FROM dbo.ZnodeClient t
WHERE t.ClientId = @TemplateClientId;

COMMIT TRANSACTION;

-- Shown once. Put both values in .env, then clear this result from your screen.
SELECT c.ClientId, c.ClientName, @Secret AS ClientSecret, c.Issuer, c.Audience, c.ApplicationType
FROM dbo.ZnodeClient c
WHERE c.ClientName = @ClientName;
