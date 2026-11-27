# Handoff: BMP-38 new tests (BI Worldwide), state on 2026-11-26

Story: Jira **BMP-38** "Web Admins can search, filter, and sort the user list" (epic BMP-34). Flow: `/tda-agents:new-test`
(plugin README, `config/agents.yaml` `newTests`). This file says where everything is and how to continue. It holds no
secrets: credentials live only in git-ignored `.env` files (see "Secrets").

## Where it stands

| Step of /new-test | State |
| --- | --- |
| 1-2 Access, analysis | Done. `work/stories/BMP-38/` (git-ignored): `story.md`, `srs.txt`, `fsd.txt`, `aio-cases.tsv`, `analysis.md` |
| 3 Keys and requirements | Done and **approved** (rounds 1 and 2). 59 requirements, readiness 198/199 READY |
| 4 Scripts | Done: 59 tests written (55 runnable, 4 `test.fixme`), type-check clean (baseline 1 error) |
| 5 Sources | Done: sources filled from the scan, `check-hardcoded` "no hardcoded test data" |
| 6 Approval | Done |
| 7 Run | **BLOCKED**: 0 of 59 passed. TC-63 skips with `PREFERRED_NOT_QUALIFIED` (see "Blocker") |
| 8 Finish | Not done: nothing committed in this repo or the fork |

### Resume 2026-11-27 (latest)
Query + vocabulary approved; TC-63 PASSED as user 102. Full run of the other 58: 26 passed, 25 failed, 7 skipped,
teardown deleted 163 / failed 0. Causes and per-test list: `docs/memory.md`, last session-log entry. Next: with the
user's go-ahead, fix the fork's test code (find a test's own user across the 20-per-page grid or search it first;
make `waitForList` wait for the list to refresh; fix paging in `countRowsAcrossPages`; createdDate parsing;
Deactivate dialog and click-timeout locators), then rerun only the failed tests. TC-93/110: the API refuses
special-character / HTML names (HTTP 400 / 500) - decide whether to change the test data.

### Update 2026-11-26 evening
The tests sign in as qa user 102 only (user decision; already in `tests/.env`). 102 is a back-office Admin + Super
Admin on all stores, ZnodeUser inactive, no BNJM link, yet it signs in to the storefront. `USER_WEBSTORE_EXISTING_WITH_ROLE`
(query + vocabulary) was widened to also accept Admin/Super Admin on all stores (PortalId NULL) and re-verified on qa;
both are **pending_approval**. Approve them (`bin\tda.cmd approve ...`), then rerun TC-63 and the rest. The rules
below describe the old query and still hold for its Web Admin branch.

### Blocker (older)
The tests sign in as an existing BNJM storefront Admin the tester provides (created users cannot pass the storefront's
access check). `tests/.env` in the fork holds `BNJM_ADMIN_USERNAME` / `BNJM_ADMIN_PASSWORD`. The resolver validates that
account with query `USER_WEBSTORE_EXISTING_WITH_ROLE` (approved) and refuses it unless it is:
- an **active** `ZnodeUser`;
- linked to store **BNJM** (`ZnodeUserPortal` on portal 10, not "all stores");
- holding the Commerce Portal role **`Web Admin` on portal 10** (`AspNetUserRoles.PortalId = 10`);
- not locked (`LockoutEnd` NULL); user name equal to `AspNetZnodeUser.UserName` (not the email unless they are the same).

Both accounts tried so far were refused. The first was a global back-office admin (roles Admin + Super Admin on all
stores, user inactive). Check a candidate with the read-only diagnostic `work/stories/BMP-38/check-declared-admin.sql`
(git-ignored; copy below) before putting it in `tests/.env`. Three BNJM accounts qualify on qa (query-verify found them;
admin ZnodeUser 110 is one). With a qualifying account in `tests/.env`, rerun TC-63 and then the rest (commands below).

## Repositories and branches

| Repository | Path used here | Branch | State |
| --- | --- | --- | --- |
| Data repo (this one, TDA_HOME) | `D:\ideafest\znode-test-data-bi-worldwide` | `BMP-38` | 34 uncommitted files (repository entries, config, docs) |
| Playwright fork | `D:\ideafest\znode-biww-playwright-automation-fork` | `dev_bmp38` | 16 uncommitted files (spec, page objects, fixture wiring) |
| Test data agents (code) | `D:\ideafest\znode10-automation-testdata-generator` | `feat/multi-spec-collections` | see "Tool release" |

### Tool release (important)
- PR MRRSoft/znode10-automation-testdata-generator#17 is **merged** (multi-spec collections, spec names with spaces,
  teardown skipping a repeated delete, GET steps, 0.20.0 version bump).
- Two later commits on `feat/multi-spec-collections` are **not in master** and need a follow-up PR:
  `ef15bda` (declared accounts from the environment: scanner kind `env`, schemas) and `30b45da` (readiness checks a
  declared account through its @preferred query). BMP-38 needs both.
- No `v0.20.0` tag or release yet. Until it is released (with the two commits), run `bin/tda` and the fork against the
  local build: `TDA_CLI_JAR=<code repo>/core/target/tda-cli.jar` (build: `mvn -q install` in the code repo, JDK 17),
  and scan with `node <code repo>/adapters/playwright/dist/src/cli.js scan ...` (the installed adapter 0.19.0 lacks the
  env scanner). After the release: pin `tda.version` 0.20.0 in `pom.xml` / `package.json` here and the adapter in the fork.

## Environment on a new machine
- JDK 17 (`JAVA_HOME`); the default JDK 11 fails. Maven 3.9, Node 18.18+ (Node 24 used).
- GitHub token with `read:packages` for the MRRSoft packages (`~/.m2/settings.xml` server `github`; `NODE_AUTH_TOKEN`).
- `mvn -q initialize` here (jar to `.tda/`); `npm install` in the fork.
- Data repo `.env` (never commit): DB settings, `TDA_ENV_NAME=qa`, `TDA_API_BASE_URL` (BNJM qa gateway),
  `TDA_API_CLIENT_ID` / `TDA_API_CLIENT_SECRET` (the dedicated client made with `docs/ops/create-tda-api-client.sql`),
  `TDA_API_CLIENT_DEDICATED=true`, `TDA_CREATED_USER_PASSWORD`.
- Fork `.env` (root) or `tests/.env` (never commit): `BNJM_ADMIN_USERNAME`, `BNJM_ADMIN_PASSWORD` (template
  `.env.example`, values must stay empty there). The fork runs with `ENV=qa` (`config/qa.json`, webstore-bnjm-dv).

## Commands (Git Bash; set these first)
```bash
export JAVA_HOME=/c/tools/jdk-17.0.21.1+2
export TDA_CLI_JAR=D:/ideafest/znode10-automation-testdata-generator/core/target/tda-cli.jar
export TDA_HOME=D:/ideafest/znode-test-data-bi-worldwide
```
- Data repo: `bin/tda validate`, `bin/tda readiness tests/webstore/UserManagementPage`, `bin/tda check-hardcoded`.
- Approvals (people only, at a terminal; PowerShell: `bin\tda.cmd`): `bin/tda approve tests/webstore/UserManagementPage`
  then `--round 2`.
- Run one test (from the fork):
  `ENV=qa npx playwright test tests/webstore/UserManagementPage/UserListSearchFilterSortTest.spec.ts -g "BMP-TC-63 " --project=chromium --retries=0 --workers=1`
  then each test the same way. After each run check `work/runs/<runId>/teardown.json` here: `failed` must be 0.
- Rescan after spec changes (from the fork):
  `node D:/ideafest/znode10-automation-testdata-generator/adapters/playwright/dist/src/cli.js scan --force tests/webstore/UserManagementPage/UserListSearchFilterSortTest.spec.ts`

## What was built (data repo, all approved unless noted)
- Keys: `USER_WEBSTORE_WITH_ROLE` (creates BIWW users per run: `/User/CreateCustomerAccount`, then
  `/BIWWCustomer/CreateSingleCustomerWithAdditionalField` with `cpRoles` = Commerce Portal role, which scopes it to the
  portal; teardown deletes the user and the BIWW row via the Custom Table API), `USER_WEBSTORE_EXISTING_WITH_ROLE`
  (the declared admin), `MARKET_AVAILABLE`, `ADMIN_CATEGORY_AVAILABLE` (attribute `BenjaminMooreCategory`),
  `USER_COUNT_OF_STORE`; `MARKET_WITHOUT_USERS` pending (data gap). Entity maps `user_management`,
  `user_global_attributes`, `market`, `asm`, `pim_attribute_options`, `custom_table`; `user_access` pending (diagnostic).
- Requirements: `repository/requirements/playwright/tests/webstore/UserManagementPage/UserListSearchFilterSortTest/`.
- Config: `config/agents.yaml` (`newTests`, `apiChoices` with BIWW findings), `config/scanners.yaml` (`keysRequired`).

## Fork (Playwright) changes
`tests/webstore/UserManagementPage/UserListSearchFilterSortTest.spec.ts`, `page_objects/webstore/UserManagementPageObjects.ts`,
`page_objects/webstore/SignInPageObjects.ts`, `page_actions/webstore/UserManagementPage/UserManagementPage.ts`,
`page_actions/webstore/LoginPage/SignInPage.ts`, `utils/userListData.utils.ts`, `utils/recordedContext.ts`,
`page_action_manager/PageActionManager.ts`, `fixtures/base.fixture.ts` (testData + tdaSwap), `playwright.config.ts`
(TDA global setup/teardown when `TDA_HOME` is set; loads `.env` or `tests/.env`), `.gitignore` (`.env`), `.env.example`,
`.npmrc`, `package.json` (adapter 0.19.0). Sign-in: open `/` -> `/login` (`txtEmail`, `txtPassword`, `btnSignIn`);
Admin lands on `/admin`; Users page `/admin/users`.

## Known test status and open items
- `test.fixme`: TC-76, 77, 125 (need a Super Admin sign-in), TC-106 (need Sales Rep and Market Coordinator sign-ins).
- TC-84 skips: no market without users on qa (add an empty market to `cso.TblCustom_Market`, or drop the test).
- Not asserted because the qa grid has no Role/Status/ASM column or tags: parts of TC-61, 64, 67, 68, 69, 70, 79, 127
  (requirements say so in "Review:" evidence).
- First-run unknowns: Deactivate dialog (TC-102, 114, 132), stubbed requests (TC-101, 104, 108, 111), createdDate
  format, two sessions of one account (TC-116, 117). Count tests need `--workers=1`.
- qa cleanup: orphan BIWW rows 289, 290, 291 in `cso.TblCustom_UserManagement` (made before the teardown fix).
- Security: the fork's committed `config/stage.json` / `config/qa.json` hold plaintext credentials; a back-office
  account's password was briefly in `.env.example` - change it and keep `.env.example` blank.
- Review: `config/api.yaml` entityTerms additions; proposed `cso.*` masks for `config/column-mask.yaml`; ASM masking;
  ShipperID readable; `USER_WEBSTORE_WITH_ROLE` `portalRole` description outdated ("sent as RoleName" -> cpRoles).
- Scanner gap (code repo, separate change): helpers declared at the top level of a spec file are not followed, so the
  admin declaration must stay inline in each test.

## check-declared-admin.sql (read-only; run on BNJM qa, share only the flags)
```sql
DECLARE @UserName nvarchar(256) = N'<user name>';
SELECT
    CASE WHEN az.AspNetZnodeUserId IS NOT NULL THEN 'yes' ELSE 'NO' END AS found_in_AspNetZnodeUser,
    az.PortalId AS aspnetznodeuser_portal,
    CASE WHEN a.Id IS NOT NULL THEN 'yes' ELSE 'NO' END AS linked_AspNetUsers,
    CASE WHEN u.UserId IS NOT NULL THEN 'yes' ELSE 'NO' END AS linked_ZnodeUser,
    CASE WHEN u.IsActive = 1 THEN 'yes' ELSE 'NO' END AS znodeuser_active,
    CASE WHEN a.LockoutEnd IS NULL THEN 'yes (null)' WHEN a.LockoutEnd < SYSUTCDATETIME() THEN 'NO (past date set)' ELSE 'NO (locked now)' END AS lockoutend_null,
    (SELECT COUNT(*) FROM dbo.ZnodeUserPortal up JOIN dbo.ZnodePortal po ON po.PortalId = up.PortalId WHERE up.UserId = u.UserId AND po.StoreCode = N'BNJM') AS userportal_rows_on_BNJM,
    (SELECT COUNT(*) FROM dbo.ZnodeUserPortal up WHERE up.UserId = u.UserId AND up.PortalId IS NULL) AS userportal_rows_all_stores,
    (SELECT STRING_AGG(CONCAT(r.Name, ' @portal ', COALESCE(CAST(ur.PortalId AS varchar(10)), 'NULL'), CASE WHEN r.IsActive = 1 THEN '' ELSE ' (role inactive)' END), '; ')
       FROM dbo.AspNetUserRoles ur JOIN dbo.AspNetRoles r ON r.Id = ur.RoleId WHERE ur.UserId = a.Id) AS roles
FROM dbo.AspNetZnodeUser az
LEFT JOIN dbo.AspNetUsers a ON a.UserName = az.AspNetZnodeUserId
LEFT JOIN dbo.ZnodeUser u ON u.AspNetUserId = a.Id
WHERE az.UserName = @UserName;
```
A qualifying account shows: znodeuser_active yes, userportal_rows_on_BNJM 1, roles containing `Web Admin @portal 10`.

More history: `docs/memory.md`, session log entry "2026-11-26 BI WORLDWIDE".
