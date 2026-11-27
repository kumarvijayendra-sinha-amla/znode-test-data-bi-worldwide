# Handoff: BMP-38 new tests (BI Worldwide), state on 2026-11-27

Story: Jira **BMP-38** "Web Admins can search, filter, and sort the user list" (epic BMP-34). Flow: `/tda-agents:new-test`
(plugin README, `config/agents.yaml` `newTests`). This file says where everything is and how to continue. It holds no
secrets: credentials live only in git-ignored `.env` files (see "Secrets").

## Resume here (2026-11-27)

### Update 2026-11-27 afternoon (read first; supersedes the counts below)
- **Full run** (local build, 1 worker, 39 min, run `tda-playwright-1795759653848`, log `work/bmp38-full-20261127.log`):
  46 pass, 6 fail, 7 skip (the expected seven); teardown 163 deleted, 0 failed.
- Failures resolved:
  - **TC-74 = app defect, cause corrected:** Created Date sorts by day only; users created the same day are always
    newest first, also in ascending order (search is not the cause; it only selects one day's users). Evidence (read-only
    API + `ZnodeUser.CreatedDate`): unfiltered asc lists 290 (11-18 09:48) before 289 (11-18 09:27). Last Name and Email
    ties behave the same. Added to `config/known-failures.yaml`. Jira bug drafted, **not logged yet**.
  - **TC-62 (and TC-122):** `refreshList` compared the page with the *first* list response; a search after a filter sends
    two requests. Fix in the fork: `UserManagementPage.refreshList` collects all list responses and uses the one sent last.
  - **TC-90:** tie users ("Tie…") fell beyond row 100 with ~150 users; it now searches the run's users first (`runTag`).
  - **TC-98, TC-130:** count tests; pass alone (counts drift while other tests create users). Run them alone/last.
- Reruns after the fixes: TC-61, 62, 67, 90, 122, 127 all pass (`work/bmp38-fixes-20261127.log`); TC-98 and TC-130 pass
  alone. Rescan + `check-hardcoded` clean.
- **Code-repo PR opened:** MRRSoft/znode10-automation-testdata-generator#19 (env-account commits + ReadinessTest fix,
  version 0.21.1, branch `feat/env-declared-accounts` from the `D:\ideafest\tda-0.21-env` worktree). After merge: tag
  `v0.21.1`, pin it here and in the fork, drop `TDA_CLI_JAR`.
- Still open: log TC-74 in Jira; items 3-6 below; a full rerun with the two fixes (optional); commits.

### Where it stands

| Step of /new-test | State |
| --- | --- |
| 1-2 Access, analysis | Done. `work/stories/BMP-38/` (git-ignored): `story.md`, `srs.txt`, `fsd.txt`, `aio-cases.tsv`, `analysis.md` |
| 3 Keys and requirements | Done. 59 requirements |
| 4 Scripts | Done: 59 tests (55 runnable, 4 `test.fixme`); type-check clean apart from the baseline error in `utils/sendExecutionEmail.ts` |
| 5 Sources | Done: `check-hardcoded` "no hardcoded test data" |
| 6 Approval | Not needed any more: tool release 0.21.0 removed the approval step (see "Tool") |
| 7 Run | **51 of 59 pass, 1 fails (TC-74), 7 skip** on qa, counted over several partial runs. No full run since the last fixes |
| 8 Finish | Not done: nothing committed in this repo, the fork or the code repo |

### Tool (read before running anything)
- Release **0.21.0** (MRRSoft/znode10-automation-testdata-generator PR #18, tag `v0.21.0`) removed the human approval
  step: `pending_approval`, `approved` and `active` entries are all used; `tda approve` no longer exists.
- 0.21.0 does **not** contain `ef15bda` / `30b45da` (declared accounts from the environment; BMP-38 needs them). A local
  build has both: worktree `D:\ideafest\tda-0.21-env`, branch `local/0.21-env` = `origin/master` + those two commits
  cherry-picked + `ReadinessTest` expecting `READY` instead of `PENDING_APPROVAL`. Built with `mvn -q install`, tests
  green. Not committed beyond the cherry-picks, not pushed. Follow-up: a PR with these commits on top of 0.21.0, then a
  release, then pin it in `pom.xml` / `package.json` here and the adapter in the fork.
- Until then every command and run needs, in the same shell:
  - Git Bash: `export JAVA_HOME=/c/tools/jdk-17.0.21.1+2 TDA_CLI_JAR=D:/ideafest/tda-0.21-env/core/target/tda-cli.jar TDA_HOME=D:/ideafest/znode-test-data-bi-worldwide`
  - PowerShell: `$env:JAVA_HOME='C:\tools\jdk-17.0.21.1+2'; $env:TDA_CLI_JAR='D:\ideafest\tda-0.21-env\core\target\tda-cli.jar'`
  - Without `TDA_CLI_JAR`, `bin\tda.cmd` uses the released 0.19.0 jar in `.tda\`: it has no env sources, rejects the newer
    entries (`validate` shows ~63 errors) and still enforces approval.
- The fork keeps adapter 0.19.0 from npm: it filters tests on requirement approval only, and all requirements are
  approved, so it works. Rescans use the code repo's adapter build (`node <code repo>/adapters/playwright/dist/src/cli.js scan ...`).
- VPN must be on: prewarm stops with "test database unreachable" (172.21.44.4:1433) otherwise.

### Sign-in
The tests sign in as **qa user 102** (user decision), from the fork's `tests/.env` (`BNJM_ADMIN_USERNAME`,
`BNJM_ADMIN_PASSWORD`; never commit). 102 is a back-office Admin + Super Admin on all stores (ZnodeUser inactive, no BNJM
link) and signs in to the storefront. `USER_WEBSTORE_EXISTING_WITH_ROLE` accepts either a `Web Admin` on the store's
portal or an Admin/Super Admin on all stores. The tests therefore run as a Super Admin, not a Web Admin.

### Test results (qa, 2026-11-27)
- **Pass (51):** TC-63, 60, 64, 66, 67, 68, 69, 70, 71, 72, 73, 75, 78, 79, 80, 81, 83, 85, 86, 87, 89, 90, 91, 92, 94,
  96, 97, 98, 99, 100, 101, 102, 104, 105, 107, 108, 109, 111, 114, 116, 117, 122, 127, 128, 130 (alone), 131, 132, 134,
  59, 61, 62.
- **Fail (1): TC-74** "Created Date ascending": with a search applied, the storefront returns the identical response for
  `sortOrder=asc` and `sortOrder=desc` (`GET /api/admin/users?search=...&sortField=createdDate`); the BIWW rows'
  `CreatedDate` values differ by seconds. Likely an **app defect**: confirm manually and log in Jira (BMP project).
- **TC-130** passes alone but fails in a group: its `activeCount` is read at prewarm, before the users of later tests
  exist. Run it on its own (or last, alone).
- **Skip (7):** `test.fixme` TC-76, 77, 125 (need a Super Admin sign-in of their own), TC-106 (Sales Rep and Market
  Coordinator sign-ins); TC-84 (no market without users on qa: add one to `cso.TblCustom_Market` or drop the test);
  TC-93 and TC-110 (`CREATE_FAILED`: the API rejects a user name with special characters, HTTP 400, and with HTML,
  HTTP 500; decide whether to change their test data or drop them).

### Open items (in order)
1. Full-suite rerun with the local build (about 40 min, `--workers=1`), then TC-130 alone. Check
   `work/runs/<runId>/teardown.json` (`failed` must be 0).
2. TC-74: confirm the sort defect by hand on qa and log it; mark the test as a known failure meanwhile if wanted.
3. **BIWW row teardown does not work (qa hygiene, pre-existing):** the undo
   `DELETE /v1/custom-table-data/UserManagement/UserName/{user}/bulk` returns success but leaves the
   `cso.TblCustom_UserManagement` row (reproduced: run `tda-playwright-1795758873475`, row 450). BNJM has ~232 BIWW rows
   but only 69 are listed; the rest are orphans of deleted test users. The grid and the count query ignore them, so tests
   are not affected. Needs the right delete call from the qa API owner, then a one-off cleanup by someone with DB write
   rights (this system has read-only DB access).
4. TC-93 / TC-110 data decision; TC-84 market; the 4 `test.fixme` sign-ins.
5. Review items: `config/api.yaml` entityTerms additions; proposed `cso.*` masks in `config/column-mask.yaml`;
   `USER_WEBSTORE_WITH_ROLE` `portalRole` description still says "sent as RoleName" (it is `cpRoles`).
6. Commit: data repo branch `BMP-38`, fork branch `dev_bmp38`; code-repo PR (point "Tool").

### What changed on 2026-11-27
- **Fork (test code):** `page_actions/webstore/UserManagementPage/UserManagementPage.ts`: every list action waits for
  `GET /api/admin/users` and for the summary and rows to match its `data.totalResults` / `data.rows`; "is listed" /
  "is not listed" / row checks / Deactivate page through the 20-per-page grid; order checks read every page without
  changing the page size (choosing a page size resets the sort on qa); rows read in one pass; Clear Filters is not
  clicked while disabled; the Deactivate/Reactivate dialog is confirmed (button label "Reactivate"); the phone Filters
  bottom sheet is closed (Escape, Filters button, tap on the backdrop) before search, sort and paging.
  `page_objects/webstore/UserManagementPageObjects.ts`: paging buttons, confirmation dialog. Spec: per-test timeout
  180 s; TC-127 opens rep's page before its column checks.
- **Data repo:** `USER_WEBSTORE_WITH_ROLE` collection: new step `setStatus` `PUT /v2/users/{userId}/account-status`
  `{"Enabled": "{isActive:true}"}` (Engine V2 spec added; makes an inactive user show Deactivated) and a generated
  `createdAt` (run clock) as the `createdDate` output (the create response's date was 0001-01-01).
  `USER_COUNT_OF_STORE` query: counts only BIWW rows whose Znode user exists (= the grid); Active = account not locked
  (`AspNetUsers.LockoutEnd` or `ZnodeUserStatus.LockoutEnd` for the portal); vocabulary uses `isActive`.
  Findings: the grid's status is not `ZnodeUser.IsActive`; Deactivate sends
  `PUT /api/admin/users/{id}/status {"status":"Terminated"|"Active"}` (storefront back end).

### Commands (Git Bash; set the variables from "Tool" first)
- Data repo: `bin/tda validate`, `bin/tda readiness tests/webstore/UserManagementPage`, `bin/tda check-hardcoded`.
- Run from the fork, one test or a set:
  `ENV=qa npx playwright test tests/webstore/UserManagementPage/UserListSearchFilterSortTest.spec.ts -g "BMP-TC-63 " --project=chromium --retries=0 --workers=1`
  (several: `-g "BMP-TC-(61|67|127) "`; whole spec: drop `-g`).
- Rescan after spec changes (from the fork):
  `node D:/ideafest/znode10-automation-testdata-generator/adapters/playwright/dist/src/cli.js scan --force tests/webstore/UserManagementPage/UserListSearchFilterSortTest.spec.ts`,
  then `bin/tda check-hardcoded` here.

## History (older notes; superseded by "Resume here")

### Resume 2026-11-27 morning
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
