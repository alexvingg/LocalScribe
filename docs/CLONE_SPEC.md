# CLONE_SPEC — independent writing-assistant reconstruction

## 1. Scope, identity, and evidence rules

This specification describes the installed Grammarly Desktop **1.203.0 / build 1.203.0.0**, its packaged alternate-mode surfaces, and the small set of black-box interactions actually observed on 2026-10-23. The native executable is a universal macOS image (arm64 and x86_64); its SHA-256 is `d882a5217ae0bfd9d56605646c95ec1047684b3ea49b8b733539329492edb6cb`. The observed settings also identify WebUI 2.43.0. Evidence: E-IDENT, E-MACHO, O-NATIVE-BLOCK.

**Global feature, screen, state-machine, file-format, and protocol completeness: UNKNOWN.** No finite study of this signed-in installation establishes every server-controlled, account-tier, organization, country, experiment, language, historical or Go-specific variant. This document inventories the examined evidence and explicitly leaves unconfirmed behavior UNKNOWN. It is not a claim of full functional equivalence.

No proprietary implementation code, decompiled algorithms, graphics, icons, fonts, nib bytes, localization catalog, model weights, credentials, personal text, database records or cookie values are delivered in this specification. Short labels, symbols, paths, schema fields and literal URLs are evidence locators, not implementation material. UI copy and visual design should be independently authored. Backend algorithms, thresholds and model behavior are UNKNOWN. [U-REQUEST]

### Evidence status vocabulary

| Status | Meaning for the implementer |
|---|---|
| OBSERVED | The specific output/control/transition was captured in a running instance. Reproduce only the exercised case; this does not prove general behavior. |
| RESOURCE-CONFIRMED | A shipped UI label, declaration, function symbol or schema exists. Feature reachability, transition semantics, eligibility and actual enforcement remain UNKNOWN unless separately observed. |
| METADATA-OBSERVED | A file/key/type/schema/literal was inspected. Its runtime authority and semantics remain UNKNOWN where stated. |
| UNKNOWN | Evidence does not establish the requested fact. Candidate states/arrows are a test inventory, not an invented original contract. |

Resource rows use phrases such as “provide” or “represent” to identify a **candidate parity requirement**, conditional on confirming the applicable product branch. They do not upgrade a label into demonstrated behavior. The same affordance can appear in several error/context variants without representing several independent features.

### Evidence register

Aliases are citations: every requirement below cites an alias plus a short string, field, symbol, observation, or another requirement that carries that locator. Aliases resolve here to immutable REA evidence IDs or identified black-box captures. File offsets below are not virtual addresses. No captured service request is available; request-level protocol claims are UNKNOWN.

| Alias | Evidence and locator |
|---|---|
| U-REQUEST | User's clean-room constraints: specification only; no copied implementation or assets; unconfirmed details marked UNKNOWN. |
| E-IDENT | REA `ev_8b129f2388c6887b517012be4cc4f535a654c204a31cb6fb2ee50d8811f4c5e3`, main `Contents/Info.plist`: version, bundle declarations, URL schemes, permission descriptions. |
| E-SIGN | REA `ev_cce9cbcf2a4af4cde9a5615a7c1cae1cb976ff74a52688f6777c57ecb21ca8be`, signing entitlements; signature trust/notarization not verified. |
| E-MACHO | REA `ev_f77c7d64f632ca01c45e0ca3f933cc2667e4c2dfe79512d49c7fbc7ae8a72756`, executable architecture and dependencies. |
| E-INVENTORY | REA `ev_a3a261538c7ed50e89b55a8cdd719a3c022d6b64d2055bc1a76f3b8c12ef13e6`, packaged file inventory; `ev_02511de206fbbb2965645181811197676ec765bd3b1435999be545a277f48a31`, Apple bundle projection. |
| E-AX | REA `ev_6e5ea4070363a9497fe8ca79fc0c581f281fccb8b4bd2f8720d0dec45cb599e3`, GRAccessibilityKit imports/exports: `AXUIElementCopyAttributeValue`, `AXUIElementSetAttributeValue`, `AXObserverAddNotification`, `CGEventPost`, selected-text/focus symbols. Static capability only. |
| E-NET | REA `ev_ac41a53ddc8a4492576944a6a8f6ded87dc815e025b31eef5880f9fdc1fa3077`, GRNetwork symbols/dependencies. |
| E-DEMANGLE | REA `ev_c36c55bdf07f0b560edc828e0821f8952070de02776b312782ba3f803ef8145d`, `focusedUIElement`, `selectedTextChanged`, `NWProtocolTLS.Options.setVerifier` demangling. |
| E-BRIDGE | Exact public string locators in `Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Resources/GOSJavaScriptCoreMessageTransport.js`, SHA-256 `c540bc6c58b0b46b15a58741d03fc1a3f52b560e9ce6ab72506215fae003b3cc`: bridge-call name at line 6 / file offset `0x6e`, origin literal at line 31 / `0x2e6`, aliases at lines 37–38 / `0x33c`, `0x37f`. Source content is not copied. |
| E-IB | REA `ev_60beef46bfb625889bfa4f4bf4b1bf63ef30788c4fddc3faca7bcc88fd7fab96`, recognized compiled UI connections. App menu selectors include `showPreferencesFromMenu:` and `quitApplicationFromMenu:`; updater selectors include `installUpdate:`, `remindMeLater:`, `skipThisVersion:`. A selector is not proof of implementation or reachability. |
| E-SQLITE | REA `ev_48039e9070682745366b13da3d1f91e91d5a5acea146f60a67a5142428b89db9`, schema-only LocalStorage snapshot; rows = null. DB SHA-256 `84773f0f549b76da347e9e4fd26fb3156b0f5a8c133f73a2326e8ecefd865a64`; no sibling WAL observed. Acquisition does not prove an atomic snapshot of a running app. |
| R-WR / R-MAIN | REA `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984`, `ProjectLlamaContent.framework/Versions/A/Resources/en-US.lproj/Localizable.strings`, 1,056 entries. |
| R-VOICE | REA `ev_7d7df9cfe1d8b64333deb4348691723b2666f44b6d294a912ba54607d614f511`, `Contents/Resources/AVIFeatures_Dictation.bundle/Contents/Resources/en-US.lproj/Localizable.strings`, 26 entries. |
| R-MEETING | REA `ev_8cd034bcbc2ccb6a85e6c596742ea0cd99f9a466702eef0342548595c0edb70b`, `Contents/Resources/AVIDesign_AVIUI.bundle/Contents/Resources/en-US.lproj/Localizable.strings`, 182 entries. |
| R-LLAMAUI | REA `ev_fe2ef7f8230f2aa37ff195db8cbc7959e6cc7acf7e8ab880586dd4ac2c7d3c7c`, GRLlamaUI framework English resource, 6 entries. |
| R-ONBOARD | REA `ev_e00727132d7491945f75eea3f96d38e9a97871ff7b38072a500870da0857799a`, GRLlamaOnboarding XPC English resource, 9 entries. |
| R-WEB | REA `ev_31b710bea4a8edf953296e9d9493e62834e48a1ceb088116c592b3c837706821`, Desktop Web Content XPC English resource, 9 entries. |
| R-CORE | REA `ev_4d3cc1ae49df1892c4de151bf0c7275aa7fd4e5eb4aab13723cfdf77b6225bf6`, GRLlamaCore English resource, 93 entries: spoken punctuation/whitespace and restart guidance. |
| R-AVI | REA `ev_c399c4efb3dfb4033ec53a3ca6679d55a58383fa293ee6de1268ac558565a622`, AviNotetaker framework English resource, 5 entries. |
| R-NOTEFEATURE | REA `ev_db46257d17d88ed0f755951ada617767c8e9da132cf628d6407db60a70484161`, AVIFeatures_Notetaker English resource, 4 entries. |
| R-MODELS | REA `ev_698f2d7c8f25c19b8a215c70550cacee550349dbd3c30a47e102e0a632c579c8`, AVIModels English resource: `Multilingual`. |
| R-ALERT | REA `ev_74b785626f4fae4ddcbdf1672a696e1c6e0df4b4f5d02a3ab78f1372383e719f`, GRAlertModels English resource, 34 entries including `outcome.title.engagement`, originality and inclusivity labels. |
| O-NATIVE-WELCOME | REA `ev_9d1a8bf8038da0dfc100feecdd99a62448f50f7bc4b945e61ecdf2ac7c61d407`, observed native process/window, labels `Got it`, `New Document`, `Settings`, edge-tab instruction. No screenshots/assets copied. |
| O-NATIVE-BLOCK | REA `ev_7a5f0ecf952ecd7a9884e5fd64f057fc872266659a92f5a3ca69280517ed19e2`, observed Settings / Block List tab, exclusion table, per-row `Remove`. Actual application identities excluded. |
| O-NATIVE-ACTION | REA `ev_5863fb2ab434aaee0aed2398e0fa3271ccd9b1f68c5577953d595cd206925767`, attempted Customization-tab AXPress failed with AXError -25205; no after-state. This is an observer limitation, not an application requirement or successful transition. |
| O-TEXTEDIT | Earlier Computer Use TextEdit observations and observer `timeoutReached` errors in this chat; no Grammarly correction was confirmed. The automatically saved synthetic RTF was produced by TextEdit, not proof of a Grammarly file format. |
| O-SETTINGS | Earlier Computer Use Settings observations in this chat: Customization, `I write in`, tone, startup, Authorship, suggestion bundles, selection/email-reply generation, Go switch. These are current-user observations, not defaults or REA captures; exact chosen values described below. |
| O-CHROME | Computer Use observations in the supplied iLoveNote Chrome editor: five suggestion cards, forward navigation and visible Previous controls, `Accept`, text mutation, count 5 → 4. Screenshot SHA-256 `7f145bff282e397051f484a8ca4870344e691b7157e5f7a94bbcb1447bc71e67`; final page-text snapshot SHA-256 `c6e4be4b3521c29cf1ce41a5146732ce57bbc272d8ae721a15560c0c9b2dc2dc`. The snapshot alone lacks the suggestion overlay; card details rely on AX observations and screenshot. Extension-versus-Desktop attribution UNKNOWN. |
| M-STORE / OBS-* | Sanitized read-only app-owned metadata observations; collection-manifest SHA-256 `84d288f9834b676e850c2b6f1d9e772c222641466a57fb6a67d9b3e4dc50dfa3`. Exact observation IDs, source methods and hashes are listed in the evidence appendix. No preference values or database rows retained. |

Resource paths are relative to `/Applications/Grammarly Desktop.app` unless absolute. R-WR's framework itself is under `Contents/Frameworks`. Registry aliases and requirement IDs are sufficient to interpret this document without copying the original resources. The older REA JavaScript analysis is not an implementation dependency and no JavaScript source is reproduced here.

## 2. Demonstrated behavior and input/output boundary

| Requirement | Status | Input/event → visible output; edge boundary | Evidence |
|---|---|---|---|
| BB-001 | OBSERVED | A synthetic English paragraph in a Chrome textarea receives visible issue markings and a review entry. The tested field used the user-supplied iLoveNote page. Host support outside this field is UNKNOWN. | O-CHROME, `Open Grammarly`, `Review suggestions` |
| BB-002 | OBSERVED | Opening review produced five suggestion cards covering initial capitalization, two subject–verb cases, word form and noun/verb confusion. This is a finite fixture, not a grammar-rule inventory. | O-CHROME, `Correctness` and table below |
| BB-003 | OBSERVED | Navigating forward changed the active issue while leaving text unmodified. The first card disabled Previous; the last disabled Next. Behavior under concurrent edits is UNKNOWN. | O-CHROME, `Previous suggestion`, `Next suggestion` |
| BB-004 | OBSERVED | Accepting `I has` → `I have` changed only that tested occurrence in the editor; visible count decreased 5 → 4 and another card appeared. Undo, overlapping replacements and asynchronous races UNKNOWN. | O-CHROME, `Accept and open next suggestion` |
| BB-005 | OBSERVED control; UNKNOWN action effect | Cards expose a category, before/after text, explanation entry, accept, dismiss, more actions and previous/next controls. Dismissal persistence, dictionary actions and explanation navigation were not systematically exercised. | O-CHROME, `Learn more`, `Dismiss` |
| BB-006 | OBSERVED | Native welcome screen offers acknowledgement, new-document link, settings and an integration-control link, with instructions for an edge-of-screen entry point. Destinations and acknowledgement persistence UNKNOWN. | O-NATIVE-WELCOME, `Got it`, `New Document`, `Settings` |
| BB-007 | OBSERVED | Settings has Customization / Account / Block List tabs. Block List shows user exclusions and per-row Remove controls. Removal effect, add flow and restart persistence UNKNOWN; no exclusions were changed. | O-NATIVE-BLOCK, `Blocked by you:`, `Remove` |
| BB-008 | OBSERVED current configuration | Earlier settings showed British English, tone detection, startup, Authorship, bundles and generation on selection/email replies enabled. Go was unchecked. These are this user's state, not factory defaults or proof of service eligibility. | O-SETTINGS, matching R-WR labels |
| BB-009 | UNKNOWN attribution | Chrome results demonstrate the Grammarly integration available in that browser. They do not isolate Desktop, browser extension or cooperation between them; native and browser parity must be tested separately. | O-CHROME; E-AX is static capability only |
| BB-010 | UNKNOWN cause | TextEdit test showed no suggestion UI during the observation and later automation timed out. This does not specify an unsupported-editor rule or an app failure. | O-TEXTEDIT, observer `timeoutReached`; no successful correction capture there |

### Finite correction fixture

| Input context | Observed proposed output | Card classification | Applied? | Citation |
|---|---|---|---|---|
| Sentence-initial `he` | `He` | Capitalization | No | O-CHROME / `Capitalize the word` |
| `She go to school` | `She goes to school` | Subject–verb agreement | No | O-CHROME / `Correct subject-verb agreement` |
| `every days` | `every day` | Wording | No | O-CHROME / `Check wording` |
| `I has an important meeting` | `I have an important meeting` | Subject–verb agreement | Yes | O-CHROME / `Accept` |
| `your advise about my presentation` | `your advice about my presentation` | Word replacement | No | O-CHROME / `Replace the word` |

The tested output is semantic before/after text, not a recovered request or patch format. Character-offset unit, Unicode normalization, grapheme handling, replacement conflict rules, document identifiers, rich-text preservation, paragraph segmentation, debounce, analysis batching and results ordering are all UNKNOWN. [BB-001–005; E-AX; no captured request]

## 3. Screen inventory

Every entry identifies a discovered surface; RESOURCE-only screens have UNKNOWN reachability/layout. Controls and states are candidate requirements, not copied visual compositions. Repeated system-template controls in login-helper nibs are **not** evidence that the product is a full document editor. [E-IB]

| ID | Screen/surface and input | Visible output/states and edges | Status / citation |
|---|---|---|---|
| UI-001 | Native ready/welcome | Ready instruction, acknowledgement, document/settings/integration links; close/reopen persistence UNKNOWN | OBSERVED, O-NATIVE-WELCOME |
| UI-002 | Edge tab / floating writing widget | Entry to assistant; drag/hide/snooze candidates; screen-edge, multi-monitor and collision rules UNKNOWN | RESOURCE-CONFIRMED, R-WR `Drag and drop the`, `Hide for 1 hour` |
| UI-003 | Host text field / marked issue | Issue markings and review count in tested Chrome field; offsets and other-host placement UNKNOWN | OBSERVED fixture, O-CHROME |
| UI-004 | Suggestion card / review panel | Category, replacement preview, actions and navigation; first/last boundaries observed | OBSERVED fixture, O-CHROME |
| UI-005 | Combined review / document pages | Category sections, page-range states and no unresolved issues; paging behavior UNKNOWN | RESOURCE-CONFIRMED, WR-012–016 / R-WR |
| UI-006 | Score/performance | Numeric/perfect/undetermined/insufficient-text states | RESOURCE-CONFIRMED, WR-021–026 / R-WR |
| UI-007 | Tone / brand tone | Tone insights, feedback and on/off-brand variants; taxonomy/confidence UNKNOWN | RESOURCE-CONFIRMED, WR-027–029, WR-080 / R-WR |
| UI-008 | Paragraph rewrite | Option chooser, result, acceptance/insertion/regeneration/undo, missing result/error/quota states | RESOURCE-CONFIRMED, WR-030–047 / R-WR |
| UI-009 | Personal writing style | Sample input, analysis, named result, select/manage/delete confirmation | RESOURCE-CONFIRMED, WR-048–055 / R-WR |
| UI-010 | Generative prompt/result | Prompt entry/examples, submit, result insertion/copy and quota/error variants | RESOURCE-CONFIRMED, AI-001–008 / R-WR |
| UI-011 | Chat/launcher/context | Conversation, selected-text/window/file context, errors and history; classic/Go branch UNKNOWN | RESOURCE-CONFIRMED, AI-009–026 / R-WR |
| UI-012 | Conversation history | Date sections, rename/delete, unavailable encrypted storage states | RESOURCE-CONFIRMED, AI-011–016 / R-WR |
| UI-013 | Originality/results/citation | Loading, matches, AI-pattern estimate, no-match, source/reference/citation actions | RESOURCE-CONFIRMED, WR-056–063; R-ALERT `plagiarism.card.headerTitle` |
| UI-014 | Translation picker | Target-language selection; complete languages and result lifecycle UNKNOWN | RESOURCE-CONFIRMED, WR-064 / R-WR |
| UI-015 | Snippet picker/library/form | Empty/search/list/new/name/text/placeholders/validation/save failure/shortcut tips | RESOURCE-CONFIRMED, WR-065–078 / R-WR |
| UI-016 | Team terminology | Organization term/context, style/tone notices and editing affordances | RESOURCE-CONFIRMED, WR-004, WR-079–080 and WR-082–087 / R-WR |
| UI-017 | Settings customization | Dialect, tone, startup, shortcuts, Authorship, bundles, generation and Go option | OBSERVED earlier, O-SETTINGS; current native tab labels O-NATIVE-BLOCK |
| UI-018 | Settings account | Name/email/plan, management and sign-out; identity values excluded; action effects UNKNOWN | RESOURCE-CONFIRMED, SC-002–007 / R-WR |
| UI-019 | Settings exclusions | User-excluded application rows; optional sites/admin sections; only user table observed | OBSERVED table O-NATIVE-BLOCK; other variants SC-018–021 |
| UI-020 | Shortcut editor / keyboard mode | Capture/change/save/cancel and keyboard tips; conflicts/system-reserved keys UNKNOWN | RESOURCE-CONFIRMED, SC-013–014 / R-WR |
| UI-021 | Onboarding / accessibility access | Permission instructions, continue/try/replay and failure/support routes; exact sequence UNKNOWN | RESOURCE-CONFIRMED, R-WR `Accessibility Access`; R-ONBOARD |
| UI-022 | Auth/sign-in/session | Guest, authenticating, organization account, expired/expiring, plan loss and sign-in failure | RESOURCE-CONFIRMED, SC-004–007, SC-024, SC-046–055; ER-057, ER-070–075 |
| UI-023 | Upsell / entitlement | Locked suggestions/rewrites, trials and quota exhaustion; pricing/current plan catalog UNKNOWN | RESOURCE-CONFIRMED, WR-046–047, SC-007; ER-076–077 |
| UI-024 | Authorship permission/reminder | Tracking start/skip, document/clipboard access, unsupported document and page-limit notices | RESOURCE-CONFIRMED, AU-001–026 / R-MAIN |
| UI-025 | Writing activity/report | Recording/paused/report/source classification/share/delete/incomplete deletion variants | RESOURCE-CONFIRMED, AU-001–026; ER-088 / R-MAIN |
| UI-026 | Voice entry/capture/settings | Record/stop/finish/cancel/restart/device/processing/done/error; reachability UNKNOWN | RESOURCE-CONFIRMED, VO-001–014 and ER-001–018 / R-VOICE |
| UI-027 | Meeting setup/list/detail | Permissions/calendar/language/mic/history/title/recording controls and tabs | RESOURCE-CONFIRMED, NT-001–035, NT-064–070 / R-MEETING |
| UI-028 | Meeting artifacts/chat/share | Summary/transcript/notes/metadata, questions/actions, regeneration, conversation, share controls | RESOURCE-CONFIRMED, NT-030–063 / R-MEETING |
| UI-029 | Notetaker migration | Legacy/full-feature labels coexist with standalone migration notices; active branch UNKNOWN | RESOURCE-CONFIRMED, NT-071–072 / R-MAIN, R-MEETING |
| UI-030 | Go switch/coexistence | Switch prompt, connected-agent proposition and conflicting-installed-variant notices; switching not performed | RESOURCE-CONFIRMED, AI-027–028, SC-070–072 / R-WR |
| UI-031 | Feedback / diagnostics | Rating/reasons/text notice, issue description, diagnostic recording/logs, send/cancel/thanks/failure | RESOURCE-CONFIRMED, SC-028, SC-056–064; ER-089–095 / R-WR |
| UI-032 | Update / restart / quit | Optional/required update, install/later/skip/retry/manual recovery, quit/reopen confirmation | RESOURCE-CONFIRMED, ER-096–101; R-CORE `Quit %@?`; E-IB selectors |
| UI-033 | Regional/admin/connectivity blockers | Whole-feature/partial unavailable, blocked connection/country/policy/browser and support/retry | RESOURCE-CONFIRMED, SC-020–025; ER-037–050 / R-WR |

## 4. State-machine specification

The machine names/states below are independent descriptive notation. Only OBSERVED transition rows are confirmed edges. For all other machines, arrows, guards, error precedence, state retention and timing are UNKNOWN. A label pair does not establish its transition order. Inputs/outputs are conceptual user-visible events, not recovered wire messages. Each row links to the detailed requirements/evidence below.

| ID | Machine / states | Inputs and outputs; confirmed edge or candidate sequence | Status / evidence |
|---|---|---|---|
| SM-001 | Welcome: hidden, ready | Ready screen exists with entry controls; launch/acknowledge/reopen edges UNKNOWN | O-NATIVE-WELCOME `Got it`; E-IDENT `LSUIElement` |
| SM-002 | Host integration: unsupported, blocked, idle, analyzing, issues, clear, unavailable | Text/focus/selection and host context are candidate inputs; marks/cards are observed outputs in one textarea. Block-list precedence and private-field exclusion UNKNOWN | BB-001; IN-01–05; ER-042–050 |
| SM-003 | Review: closed, card(i,n), applying, card(j,n-1), no-issues | Open → card; Next → neighboring card without text change; Accept on tested `I has` → changed text and 5→4 count. Last/first disabled navigation controls observed; Previous action, no-issues arrival, Dismiss/Undo and races UNKNOWN | OBSERVED finite edges only, BB-002–005 / O-CHROME |
| SM-004 | Combined review: loading, category/page-list, no-unresolved-range, error | Page selection/category/scroll → candidate result range; all transitions and order UNKNOWN | WR-012–019 / R-WR |
| SM-005 | Score: insufficient, pending, numeric, perfect, undetermined | Document text → candidate score state. Labels describe 30-word minimum, not verified boundary behavior | WR-021–026 / R-WR |
| SM-006 | Tone: off, analyzing, insights, brand-aligned, off-brand, feedback | Text/locale/setting → candidate tone result; feedback changes and taxonomy UNKNOWN | WR-027–029, WR-080 / R-WR |
| SM-007 | Rewrite: selection, choice, generating, result, no-result, quota, error | Improve/rephrase/shorten/tone/custom instruction → candidate variant; accept/insert/copy/undo/regenerate edges UNKNOWN | WR-030–047 / R-WR |
| SM-008 | Personal style: sample, invalid, analyzing, result, named/saved, managing, deleting | Sample/name and analyze/select/delete actions → candidate saved style/default; counting, cancellation, duplicates UNKNOWN | WR-048–055 / R-WR |
| SM-009 | Generation: empty, composing, invalid, requesting, response, quota, error | Prompt/selection/email context → candidate output; submit/cancel/regenerate/insertion semantics UNKNOWN | AI-001–008, AI-029–038 / R-WR |
| SM-010 | Chat/context/history: new, contextualized, sending, response, failed, history-unsaved | Text/windows/files and send/edit/remove/new/rename/delete → candidate answer/history; mode ownership, streaming, edit branches and atomicity UNKNOWN | AI-009–026 / R-WR |
| SM-011 | Attachments: absent, selecting, attaching, unreadable, oversized, ready, removed | File/window/selection → candidate context; exact MIME/size/permissions and lifetime UNKNOWN | AI-017–025; ER-050–056 |
| SM-012 | Originality: idle, checking, matches, possible-AI, no-match, citation | Document → candidate sources/percentage/citation; mixed-match combinations and thresholds UNKNOWN | WR-056–063; R-ALERT `aiDetector.card.title` |
| SM-013 | Translation: language-choice, requesting, result, failure | Input text/source/target language → candidate translation; full language set, limits and transitions UNKNOWN | WR-064 / R-WR |
| SM-014 | Snippets: empty, searching, list, editing, invalid, saving, saved, failure, inserting | Name/body/search/placeholder and save/insert/refresh actions → candidate reusable text; conflicting limits unresolved | WR-065–078; ER-083–087 |
| SM-015 | Authentication: guest, auth-pending, signed-in, expiring, expired, restricted, failed | Sign-in/out/reconfirm/account-type → candidate session state; OAuth exchange, token renewal, defaults and timeout enforcement UNKNOWN | SC-004–007, SC-024, SC-046–055; ER-070–075 |
| SM-016 | Settings: customization, account, exclusions, shortcut-edit, language-relaunch | Tabs/controls are observed or resource-backed. Earlier Computer Use moved between customization and exclusions; this pass's REA AXPress failed. Setting-write, Save/Cancel and relaunch effects UNKNOWN | O-SETTINGS; O-NATIVE-BLOCK; O-NATIVE-ACTION; SC-008–019 |
| SM-017 | Authorship: off, reminder, tracking, paused, near-limit, limit, unavailable, report, delete-partial | Typing/pasting/deleting/source references are declared inputs; activity report is declared output. Consent, prior data, rollback, sharing and all transitions UNKNOWN | AU-001–026; ER-088 / R-MAIN |
| SM-018 | Dictation: idle, device-loading, recording, processing, done, copied, cancelled, failure | Microphone/start/finish/stop/cancel/restart → candidate transcript; silence, double-start, stop-idle and interrupted streams UNKNOWN | VO-001–014; ER-001–018 / R-VOICE |
| SM-019 | Meeting capture: disconnected, setup, ready, scheduled, detected, recording, stopped, resuming | Calendar/device/language/permissions and manual/auto controls → candidate recording/session; opening alone is described as non-recording, not runtime verified | NT-001–029 / R-MEETING |
| SM-020 | Meeting artifacts: absent, pending, generating, available, regenerating, failed | Captured meeting and regeneration/tab requests → candidate summary/transcript/metadata; partial availability and old-result retention UNKNOWN | NT-030–046; ER-025–036; R-NOTEFEATURE |
| SM-021 | Meeting sharing/chat: off, configured, deferred, posting, shared, failed | User choices/calendar event/meeting end/chat request → candidate link/message/answer; recipients, idempotency and automatic dispatch UNKNOWN | NT-047–063 / R-MEETING |
| SM-022 | Meeting history: empty, selected, renaming, deleting, migrated | New/rename/delete/view-web → candidate history/detail; deletion confirmation text exists but reversibility/current standalone branch UNKNOWN | NT-064–072 / R-MEETING, R-MAIN |
| SM-023 | Go/variant selection: classic, switch-offer, Go, coexistence-conflict | Switch/keep/remove variant choices → candidate mode; migration/back-switch, account preservation and agent provisioning UNKNOWN | AI-027–028; SC-070–072 / R-WR |
| SM-024 | Feedback/report: drafting, invalid, consent, collecting, recording, submitting, thanks, failure, abandon | Rating/reasons/description/test text/log/screen recording → candidate report; consent notices exist, no submission performed | SC-028, SC-056–064; ER-089–095 |
| SM-025 | Update/lifecycle: idle, checking, available, downloaded, installing, later, skipped, required, failed | Check/install/later/skip/reopen/quit → candidate version change; signed payload format, rollback and crash recovery UNKNOWN | E-IB `installUpdate:`, `skipThisVersion:`; ER-096–100; PS-10–11 |
| SM-026 | Connectivity/policy: online, disconnected, blocked, region-unavailable, partial-pause, reauth | Service/organization/host failures → candidate notices/retry/support; offline fallback, backoff, timeouts and error mapping UNKNOWN | ER-037–075; NP-08 |

## 5. Detailed feature and settings requirements


### Requirement inventory

| ID | Surface / candidate requirement | State | Inputs, outputs, edge cases and limits | Exact short evidence | Resource / ev_id |
|---|---|---|---|---|---|
| WR-001 | Correction categories | RESOURCE-CONFIRMED | Provide a correction review category for spelling, grammar and punctuation; specific rule coverage UNKNOWN. | `Correctness` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-002 | Clarity review | RESOURCE-CONFIRMED | Provide a separate clarity category; scoring rules and delivered suggestions UNKNOWN. | `Clarity` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-003 | Delivery review | RESOURCE-CONFIRMED | Provide delivery/perception feedback; affected text units and scoring UNKNOWN. | `Delivery` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-004 | Team style review | RESOURCE-CONFIRMED | Provide an organization style category; configured rules and eligibility UNKNOWN. | `Style guide` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-005 | Suggestion review | RESOURCE-CONFIRMED | Text context and suggestions are inputs; acceptance control exists; actual mutation and cursor behavior UNKNOWN. | `Accept suggestion` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-006 | Suggestion dismissal | RESOURCE-CONFIRMED | Expose dismissal; persistence and restoration UNKNOWN. | `Dismiss suggestion` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-007 | Explanation | RESOURCE-CONFIRMED | Provide an explanation surface; depth and navigation UNKNOWN. | `Learn more` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-008 | Dictionary insertion | RESOURCE-CONFIRMED | Provide a personal vocabulary action; synchronization, removal and case sensitivity UNKNOWN. | `Add to dictionary` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-009 | Dictionary settings | RESOURCE-CONFIRMED | Provide personal dictionary access; full editor behavior UNKNOWN. | `Personal dictionary` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-010 | Suggestion bundles | RESOURCE-CONFIRMED | Expose grouping of corrections; grouping rules and partial acceptance UNKNOWN. | `Suggestion bundles` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-011 | Sequential review | RESOURCE-CONFIRMED | Provide sequential review mode; order and focus transitions UNKNOWN. | `Review suggestions one by one` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-012 | Combined review | RESOURCE-CONFIRMED | Provide all-suggestions review mode; app support and layout UNKNOWN. | `Review suggestions at once` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-013 | Review navigation | RESOURCE-CONFIRMED | Provide next/previous suggestion controls; boundary behavior UNKNOWN. | `Next suggestion` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-014 | Suggestion quantity | RESOURCE-CONFIRMED | Represent a state showing all suggestions; conditions UNKNOWN. | `Showing all suggestions` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-015 | Paged document feedback | RESOURCE-CONFIRMED | Display active page range; actual page count, pagination and scrolling transitions UNKNOWN. | `Showing suggestions for pages %1$@-%2$@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-016 | Empty page-range results | RESOURCE-CONFIRMED | Represent no remaining issues in a page range; refresh trigger UNKNOWN. | `No unresolved suggestions for pages %1$@-%2$@.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-017 | Loading | RESOURCE-CONFIRMED | Represent pending analysis; timing, cancellation and retry semantics UNKNOWN. | `Loading suggestions` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-018 | Analysis failure | RESOURCE-CONFIRMED | Represent failed writing analysis; retry control exists, recovery transition UNKNOWN. | `Something went wrong` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-019 | Success feedback | RESOURCE-CONFIRMED | Represent successful/no-issue feedback; exact triggering conditions UNKNOWN. | `All clear!` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-020 | Minimum text | RESOURCE-CONFIRMED | Resource describes a three-word minimum; enforcement and word segmentation UNKNOWN. | `To give you suggestions, we need 3 words or more.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-021 | Score panel | RESOURCE-CONFIRMED | Provide performance panel with text-quality score; algorithm UNKNOWN. | `Performance` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-022 | Score output | RESOURCE-CONFIRMED | Expose numeric quality score on 0–100 scale; score computation UNKNOWN. | `Overall score: %d out of 100` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-023 | Score insufficient input | RESOURCE-CONFIRMED | Resource describes a 30-word scoring minimum; validation and counting UNKNOWN. | `Grammarly needs at least 30 words to calculate a score.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-024 | Undetermined score | RESOURCE-CONFIRMED | Represent unavailable score; triggering conditions UNKNOWN. | `Overall score: Not determined` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-025 | Perfect score | RESOURCE-CONFIRMED | Represent maximum/perfect score; exact conditions UNKNOWN. | `Overall score: Perfect` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-026 | Score toolbar option | RESOURCE-CONFIRMED | Expose persistent toolbar-score setting; persistence and rendering UNKNOWN. | `Always show the overall score in the toolbar` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-027 | Tone analysis | RESOURCE-CONFIRMED | Expose tone analysis setting; runtime earlier Computer Use observed enabled, see O-SETTINGS. | `Detect tone in my writing` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-028 | Tone insights | RESOURCE-CONFIRMED | Provide tone results surface; taxonomy and confidence UNKNOWN. | `Tone Insights` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-029 | Tone disagreement | RESOURCE-CONFIRMED | Provide tone feedback reason; submission effects UNKNOWN. | `Tone detected incorrectly` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-030 | Rewrite improvement | RESOURCE-CONFIRMED | Offer general improvement option; generation and replacement UNKNOWN. | `Improve` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-031 | Rewrite rephrase | RESOURCE-CONFIRMED | Offer alternate phrasing; model behavior UNKNOWN. | `Rephrase` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-032 | Rewrite shorten | RESOURCE-CONFIRMED | Offer shortening; target length and preservation behavior UNKNOWN. | `Shorten` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-033 | Rewrite friendly | RESOURCE-CONFIRMED | Offer friendlier variant; tone transformation UNKNOWN. | `Friendly` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-034 | Rewrite formal | RESOURCE-CONFIRMED | Offer more formal variant; tone transformation UNKNOWN. | `Formal` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-035 | More rewrite choices | RESOURCE-CONFIRMED | Expose additional options; full option set UNKNOWN. | `More` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-036 | Rewrite custom instruction | RESOURCE-CONFIRMED | Accept freeform refinement; chained context and execution UNKNOWN. | `Ask for a change` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-037 | Rewrite acceptance | RESOURCE-CONFIRMED | Expose rewrite acceptance; replacement granularity and output formatting UNKNOWN. | `Accept this rewrite` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-038 | Rewrite insertion | RESOURCE-CONFIRMED | Expose insertion; placement, existing selection and formatting UNKNOWN. | `Insert this rewrite` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-039 | Rewrite next paragraph | RESOURCE-CONFIRMED | Provide combined accept/advance action; actual transition UNKNOWN. | `Accept and next` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-040 | Rewrite dismissal | RESOURCE-CONFIRMED | Expose dismiss; availability of later undo UNKNOWN. | `Dismiss` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-041 | Rewrite regeneration | RESOURCE-CONFIRMED | Expose generation retry; preservation and variant ordering UNKNOWN. | `Regenerate this rewrite` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-042 | Rewrite copy | RESOURCE-CONFIRMED | Expose copy output; copied formats UNKNOWN. | `Copy` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-043 | Rewrite undo | RESOURCE-CONFIRMED | Expose undo; exact undo scope and history semantics UNKNOWN. | `Undo change` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-044 | Rewrite missing result | RESOURCE-CONFIRMED | Represent unavailable paragraph rewrite; cause and recovery UNKNOWN. | `There isn't a suggestion available for this paragraph.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-045 | Rewrite error | RESOURCE-CONFIRMED | Represent rewrite failure; retry label exists, recovery UNKNOWN. | `Something went wrong` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-046 | Rewrite daily quota | RESOURCE-CONFIRMED | Represent exhausted free quota; quota size, reset timezone and enforcement UNKNOWN. | `You’re out of free paragraph rewrites for today` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-047 | Rewrite paid access | RESOURCE-CONFIRMED | Expose paid access offer; current plans and entitlement UNKNOWN. | `Upgrade for unlimited paragraph rewrites` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-048 | Personal writing style setup | RESOURCE-CONFIRMED | Provide style-creation entry point; runtime availability UNKNOWN. | `Add your Writing Style` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-049 | Style sample input | RESOURCE-CONFIRMED | Resource describes minimum 200-word sample; enforcement/counting UNKNOWN. | `Paste 200 words or more` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-050 | Style analysis | RESOURCE-CONFIRMED | Provide analysis action and analyzing state; extraction mechanism UNKNOWN. | `Analyze` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-051 | Style naming | RESOURCE-CONFIRMED | Accept style name; validation and uniqueness UNKNOWN. | `Writing style` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-052 | Style selection | RESOURCE-CONFIRMED | Provide selectable saved style; persistence and scope UNKNOWN. | `Choose writing style` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-053 | Style regeneration | RESOURCE-CONFIRMED | Expose style-conditioned rewrite; actual transformation UNKNOWN. | `Regenerate using your writing style` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-054 | Style management | RESOURCE-CONFIRMED | Provide management entry point; editable properties UNKNOWN. | `Manage writing style` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-055 | Style deletion | RESOURCE-CONFIRMED | Represent deletion confirmation; actual deletion and recovery UNKNOWN. | `Delete "%@" writing style?` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-056 | Originality entry | RESOURCE-CONFIRMED | Provide combined originality-analysis entry; entitlement and runtime support UNKNOWN. | `Plagiarism & AI text check` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-057 | Originality loading | RESOURCE-CONFIRMED | Represent pending analysis; source corpus and latency UNKNOWN. | `Checking for plagiarism and AI text...` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-058 | Plagiarism results | RESOURCE-CONFIRMED | Provide source-match results; matching algorithm and thresholds UNKNOWN. | `Detect plagiarism` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-059 | AI-pattern results | RESOURCE-CONFIRMED | Represent possible AI-pattern finding; detection reliability UNKNOWN. | `Possible AI text detected` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-060 | AI-pattern percentage | RESOURCE-CONFIRMED | Display percentage claim; calibration and mathematical meaning UNKNOWN; do not treat as proof of authorship. | `%@%% of your document contains patterns often found in AI text.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-061 | Originality no matches | RESOURCE-CONFIRMED | Represent no detected matches/patterns; actual coverage UNKNOWN. | `No plagiarism or AI text detected` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-062 | Citation generation | RESOURCE-CONFIRMED | Expose citation action; supported formats, accuracy and insertion UNKNOWN. | `Generate citation` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-063 | Reference copying | RESOURCE-CONFIRMED | Expose copying of source reference; format UNKNOWN. | `Copy reference` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-064 | Translation | RESOURCE-CONFIRMED | Expose language selection; exact supported language list UNKNOWN; packaged marketing says more than 15. | `Change translation language` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-065 | Snippets empty | RESOURCE-CONFIRMED | Provide empty snippet-library state; initial condition UNKNOWN. | `No Snippets Created Yet` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-066 | Snippet creation | RESOURCE-CONFIRMED | Provide name/text input and save/cancel actions; transitions UNKNOWN. | `New Snippet` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-067 | Snippet insertion | RESOURCE-CONFIRMED | Expose insertion from snippet list; cursor/selection effects UNKNOWN. | `Insert` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-068 | Snippet library management | RESOURCE-CONFIRMED | Provide library-management entry; collections and sharing UNKNOWN. | `Manage library` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-069 | Snippet search empty | RESOURCE-CONFIRMED | Represent no matching snippets; search/tokenization UNKNOWN. | `No Snippets Found` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-070 | Snippet refresh | RESOURCE-CONFIRMED | Expose refresh; source and synchronization UNKNOWN. | `Refresh snippets list` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-071 | Snippet shortcut | RESOURCE-CONFIRMED | Expose shortcut edit; conflict validation and persistence UNKNOWN. | `Edit shortcut` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-072 | Snippet placeholders | RESOURCE-CONFIRMED | Expose placeholder selection/insertion flow; placeholder schema and transition UNKNOWN. | `Insert` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-073 | Snippet required name | RESOURCE-CONFIRMED | Represent missing-name validation; validation timing UNKNOWN. | `Snippet needs a name` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-074 | Snippet required text | RESOURCE-CONFIRMED | Represent missing-text validation; validation timing UNKNOWN. | `Snippet text is missing` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-075 | Snippet duplicate | RESOURCE-CONFIRMED | Represent duplicate snippet condition; equality rules UNKNOWN. | `This snippet already exists.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-076 | Snippet name variants | RESOURCE-CONFIRMED | Resources also contain a 400-character variant; current effective maximum UNKNOWN. | `Snippet name exceeds 30 characters` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-077 | Snippet text variants | RESOURCE-CONFIRMED | Resources also contain a 5,000-character variant; current effective maximum UNKNOWN. | `Snippet exceeds 1,000 characters` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-078 | Snippet save failure | RESOURCE-CONFIRMED | Represent create/save failure; transaction and recovery UNKNOWN. | `Unknown Error` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-079 | Team vocabulary | RESOURCE-CONFIRMED | Expose organizational term explanations; matching rules and runtime eligibility UNKNOWN. | `Knowledge Share detects and highlights key terms in your team’s w…` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-080 | Brand tone state | RESOURCE-CONFIRMED | Represent aligned/off-brand tone states; configuration and thresholds UNKNOWN. | `ON-BRAND` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-081 | Weekly statistics | RESOURCE-CONFIRMED | Expose statistics subscription entry; channels, metrics and cadence implementation UNKNOWN. | `Get weekly writing statistics and tips` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-001 | Classic generation entry | RESOURCE-CONFIRMED | Provide generative writing entry; current classic mode observed in O-SETTINGS, precise rendering UNKNOWN. | `Ask Grammarly AI` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-002 | Prompt input | RESOURCE-CONFIRMED | Accept freeform instructions; max length is parametrized elsewhere, effective value UNKNOWN. | `Enter your prompt` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-003 | Generation onboarding | RESOURCE-CONFIRMED | Fragment identifies prompt onboarding; suggested/custom choices exist as labels, actual walkthrough transition UNKNOWN. | `Start with a prompt` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-004 | Prompt examples | RESOURCE-CONFIRMED | Provide formatting/refinement examples; successful execution UNKNOWN. | `“format as bullets”` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-005 | Generation send | RESOURCE-CONFIRMED | Expose submit action; loading, delivery and cancellation UNKNOWN. | `Submit prompt` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-006 | Generation quota | RESOURCE-CONFIRMED | Fragment identifies a monthly quota notice; actual quantity, reset rules and current plan UNKNOWN. | `You'll get` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-007 | Assistant response copy | RESOURCE-CONFIRMED | Expose response copying; response availability and serialization UNKNOWN. | `Copy` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-008 | Assistant response insertion | RESOURCE-CONFIRMED | Expose insertion into originating context; focus, placement and formatting UNKNOWN. | `Insert` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-009 | AI chat placeholder | RESOURCE-CONFIRMED | Packaged chat UI exists; classic-versus-Go ownership UNKNOWN; do not require enabled chat based only on this label. | `Ask AI` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-010 | Assistant launcher | RESOURCE-CONFIRMED | Packaged launcher control exists; relation to current classic UI UNKNOWN. | `Open Launcher` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-011 | New conversation | RESOURCE-CONFIRMED | Expose new-conversation affordance in packaged UI; clearing/creating transition UNKNOWN. | `New conversation` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-012 | Conversation rename | RESOURCE-CONFIRMED | Expose rename affordance; persistence and uniqueness UNKNOWN. | `Rename` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-013 | Conversation delete | RESOURCE-CONFIRMED | Expose delete affordance; confirmation/retention semantics UNKNOWN. | `Delete` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-014 | History sections | RESOURCE-CONFIRMED | Packaged history includes today, 7-day and 30-day groups; retention window UNKNOWN. | `Last 7 days` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-015 | History unavailable | RESOURCE-CONFIRMED | Represent inability to save history; triggering conditions UNKNOWN. | `Chat history can't be saved right now` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-016 | History encryption unsupported | RESOURCE-CONFIRMED | Resource ties some history failure to unavailable encrypted storage; detection and fallback UNKNOWN. | `History won't be saved on this Mac` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-017 | Context selection | RESOURCE-CONFIRMED | Packaged context-selection affordance exists; Go ownership/current availability UNKNOWN. | `Ask about selected text` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-018 | Window attachment | RESOURCE-CONFIRMED | Packaged window context attachment exists; read scope, supported apps and Go ownership UNKNOWN. | `Work with window` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-019 | File attachment | RESOURCE-CONFIRMED | Packaged file-context attachment exists; supported formats and Go ownership UNKNOWN. | `Attach new file…` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-020 | Attachment removal | RESOURCE-CONFIRMED | Packaged context removal control exists; detach effect and data retention UNKNOWN. | `Remove window` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-021 | Attachment failure | RESOURCE-CONFIRMED | Represent attachment failure; cause and recovery UNKNOWN. | `Couldn't attach the file. Please try again.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-022 | Attachment size | RESOURCE-CONFIRMED | Represent file size ceiling; actual limit UNKNOWN. | `Select a file smaller than %@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-023 | Summarization | RESOURCE-CONFIRMED | Packaged summarization affordance exists for text/page/thread/window/document; current mode and output UNKNOWN. | `Summarize` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-024 | Sent message editing | RESOURCE-CONFIRMED | Packaged edit/send and cancel controls exist; regeneration/version behavior UNKNOWN. | `Send` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-025 | Context overflow | RESOURCE-CONFIRMED | Represent excessive context; resource suggests reducing attachment/context, actual enforced ceiling UNKNOWN. | `Too much text` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-026 | Chat retry | RESOURCE-CONFIRMED | Packaged retry affordance exists; retry lifecycle UNKNOWN. | `Retry` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-027 | Go switch | RESOURCE-CONFIRMED | Expose mode-switch setting; earlier Computer Use observed unchecked; switching, migration and agent availability UNKNOWN. | `Use Superhuman Go` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-028 | Connected agents | RESOURCE-CONFIRMED | Fragment indicates a Go-specific integration proposition; connectors, permissions and actions UNKNOWN and outside verified classic feature set. | `Connect Go to email` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-001 | Settings tabs | OBSERVED (visibility only) | Settings displays three tabs; tab-switch transitions and persistence UNKNOWN. | `Customization`, `Account`, `Block List` | O-NATIVE-BLOCK / `ev_7a5f0ecf952ecd7a9884e5fd64f057fc872266659a92f5a3ca69280517ed19e2`; R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-002 | Account identity | RESOURCE-CONFIRMED | Provide name/email/subscription rows; actual values are private and excluded. | `Name` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-003 | Subscription management | RESOURCE-CONFIRMED | Provide subscription-management entry; destination and billing transition UNKNOWN. | `Manage subscription` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-004 | Sign out | RESOURCE-CONFIRMED | Expose sign-out; session/token effects and resulting state UNKNOWN. | `Sign Out` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-005 | Guest access | RESOURCE-CONFIRMED | Provide sign-in/sign-up affordances; authentication transitions UNKNOWN. | `Sign in` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-006 | Signed-out state | RESOURCE-CONFIRMED | Represent signed-out assistant; exact allowed guest feature set UNKNOWN. | `You’re signed out of %@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-007 | Plan variants | RESOURCE-CONFIRMED | Packaged labels also include Free/Plus/Premium/Business/Enterprise/EDU; current purchasable catalog and entitlements UNKNOWN. | `Pro` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-008 | Appearance | RESOURCE-CONFIRMED | Offer system/light/dark choices; persistence and live repaint UNKNOWN. | `Appearance` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-009 | Display language | RESOURCE-CONFIRMED | Expose UI-language choice; available language list UNKNOWN. | `Display Language` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-010 | Relaunch language | RESOURCE-CONFIRMED | Represent language-change relaunch prompt with immediate/later labels; transition UNKNOWN. | `Relaunch to change the display language?` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-011 | English dialect | RESOURCE-CONFIRMED | Packaged five English variants: British/American/Canadian/Australian/Indian; earlier Computer Use observed British selected, see O-SETTINGS. | `British English` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-012 | Startup | RESOURCE-CONFIRMED | Expose startup preference; helper registration and persistence UNKNOWN. | `Launch at startup` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-013 | Keyboard shortcuts | RESOURCE-CONFIRMED | Provide keyboard shortcut editing/save/cancel; collision behavior UNKNOWN. | `Shortcuts` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-014 | Keyboard mode | RESOURCE-CONFIRMED | Represent keyboard-accessibility mode; invocation and navigation rules UNKNOWN. | `Grammarly keyboard mode has been enabled.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-015 | Selection visibility | RESOURCE-CONFIRMED | Expose selection-triggered generative UI setting; observed enabled in O-SETTINGS, timing/scope UNKNOWN. | `Show on text selection` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-016 | Reading selection | RESOURCE-CONFIRMED | Expose reading-context assistant visibility; mode ownership UNKNOWN. | `Show for selected text while reading` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-017 | Email reply visibility | RESOURCE-CONFIRMED | Fragment identifies email-reply visibility option; earlier Computer Use observed enabled, supported clients and triggers UNKNOWN. | `Show for email replies` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-018 | User exclusions table | OBSERVED (visibility only) | Settings displays user exclusions and per-row Remove controls; no exclusion identities are retained. Removing, creating and timing exclusions remain UNKNOWN. | `Blocked by you:`, `Remove` | O-NATIVE-BLOCK / `ev_7a5f0ecf952ecd7a9884e5fd64f057fc872266659a92f5a3ca69280517ed19e2`; R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-019 | Blocked sites | RESOURCE-CONFIRMED | Provide app/site control proposition; exact hostname/subdomain semantics UNKNOWN. | `You choose where %@ checks your text.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-020 | Organization allow/block | RESOURCE-CONFIRMED | Represent organization allow/block and user blocks; precedence/enforcement UNKNOWN. | `Allowed by admin:` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-021 | Organization restriction | RESOURCE-CONFIRMED | Represent analysis unavailable by organization policy; recovery UNKNOWN. | `Can't check your text` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-022 | Service geography | RESOURCE-CONFIRMED | Represent country unavailability; supported regions and detection UNKNOWN. | `%@ is unavailable in your country` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-023 | Service connection | RESOURCE-CONFIRMED | Represent connectivity failure; retry/backoff and offline behavior UNKNOWN. | `Can’t connect to %@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-024 | Session expiry | RESOURCE-CONFIRMED | Represent expiry countdown; timeout and renewal flow UNKNOWN. | `Confirm session before it expires %@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-025 | Feature unavailability | RESOURCE-CONFIRMED | Represent feature unavailable state; cause and fallback UNKNOWN. | `%@ is temporarily unavailable` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-026 | Help/legal | RESOURCE-CONFIRMED | Provide support/privacy/terms destinations; navigation and exact target URLs UNKNOWN. | `Support` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-027 | Personalization data choice | RESOURCE-CONFIRMED | Expose personalized-insights proposition and account control; actual data processing UNKNOWN. | `Try out personalized insights` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-028 | Writing feedback | RESOURCE-CONFIRMED | Provide suggestion-rating flow; text submission notice exists, storage behavior UNKNOWN. | `Overall, how useful is this suggestion in improving your writing?` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-029 | Google Docs extension gate | RESOURCE-CONFIRMED | Represent extension requirement; supported browsers and activation transition UNKNOWN. | `Enable Extension` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-030 | Word tables | RESOURCE-CONFIRMED | Resource describes table-cell context; actual support and cell navigation UNKNOWN. | `In Word, click a cell to see writing suggestions.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-031 | Word/Pages review | RESOURCE-CONFIRMED | Fragment describes combined review in Word/Pages; runtime integration UNKNOWN. | `You can now view all your suggestions at once` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-032 | Sidebar visibility | RESOURCE-CONFIRMED | Expose show/hide sidebar controls; layout and restored state UNKNOWN. | `Show sidebar` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-033 | Assistant closing | RESOURCE-CONFIRMED | Expose close action; lifecycle and reappearance triggers UNKNOWN. | `Close assistant` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-034 | Onboarding tour | RESOURCE-CONFIRMED | Provide assistant tutorial affordance with next/try labels; order and transitions UNKNOWN. | `Try it` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-035 | Welcome document entry | RESOURCE-CONFIRMED | Provide document creation entry; destination/editor functionality UNKNOWN. | `New Document` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-082 | Advance preference | RESOURCE-CONFIRMED | Expose automatic advance preference; default and actual accept/advance transition UNKNOWN. | `Go to next paragraph after accept` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-083 | Team term editing | RESOURCE-CONFIRMED | Resource describes editing shared term information; permission model, fields, review and synchronization UNKNOWN. | `Keep information accurate and up-to-date by directly making edits…` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-084 | Team context scope | RESOURCE-CONFIRMED | Resource describes glossary context linking terms/documents/team; actual data model and access boundaries UNKNOWN. | `Quickly access information about important terms, related documen…` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-085 | Snippet shortcut hints | RESOURCE-CONFIRMED | Expose show/hide shortcut help; persistence and discoverability UNKNOWN. | `Show shortcuts tips` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-086 | Read-only source excerpt | RESOURCE-CONFIRMED | Expose source-quotation copying; quote origin, retention and formats UNKNOWN. | `Copy` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| WR-087 | Change inspection | RESOURCE-CONFIRMED | Expose inspecting an individual change; highlighting and before/after semantics UNKNOWN. | `Show this change ›` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-029 | Prompt length bound | RESOURCE-CONFIRMED | Resource describes parametrized prompt maximum; exact bound, counting, validation and truncation UNKNOWN. | `%1$@ works with prompts that are %2$@ characters or fewer.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-030 | Audience ideation failure | RESOURCE-CONFIRMED | Represent audience-oriented generation failure; audience input structure and successful output UNKNOWN. | `We were unable to generate ideas for your audience` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-031 | Email reply task | RESOURCE-CONFIRMED | Expose reply-oriented generation entry; trigger, sender/context use and output delivery UNKNOWN. | `Reply quickly` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-032 | Transformation chooser | RESOURCE-CONFIRMED | Expose transformation-choice control; choices beyond already mapped rewrites and resulting action UNKNOWN. | `Select text transformation` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-033 | Insert without text target | RESOURCE-CONFIRMED | Represent missing editable target; supported target discovery and recovery transition UNKNOWN. | `To insert, select a text field` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-034 | Attachment context identity | RESOURCE-CONFIRMED | Display file-context identity; metadata read/sent and retention UNKNOWN; may belong to Go mode. | `File: %@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-035 | Unreadable context | RESOURCE-CONFIRMED | Fragment represents unreadable context; cause, permission request and fallback UNKNOWN; may belong to Go mode. | `(Can't read content)` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-036 | Context privacy information | RESOURCE-CONFIRMED | Expose assistant privacy help; actual attached content data flow, consent boundary and policy destination UNKNOWN. | `Learn more` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-037 | Approval proposition | RESOURCE-CONFIRMED | Fragment is a packaged user-approval proposition; action types, approval UI and enforced boundary UNKNOWN; do not claim implemented guarantees. | `It won't take action without your approval.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| AI-038 | Alternative response choice | RESOURCE-CONFIRMED | Expose selecting between generated responses; number, order and evaluation semantics UNKNOWN. | `Choose a response` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-036 | Widget repositioning | RESOURCE-CONFIRMED | Fragment describes moving a floating widget; placement constraints, monitor handling and saved coordinates UNKNOWN. | `Drag and drop the` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-037 | Screen-edge tab repositioning | RESOURCE-CONFIRMED | Fragment describes repositionable screen-edge activation tab; drag/hover activation transitions UNKNOWN. | `Drag the tab to where you like it` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-038 | Temporary widget hiding | RESOURCE-CONFIRMED | Expose one-hour hide choice; timer, wake and restart behavior UNKNOWN. | `Hide for 1 Hour` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-039 | Per-app widget hiding | RESOURCE-CONFIRMED | Expose app-specific widget hiding; relation to disabling analysis and persistence UNKNOWN. | `Hide in %@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-040 | Reduced sidebar frequency | RESOURCE-CONFIRMED | Expose reduced-frequency preference; display scheduling and exact meaning UNKNOWN. | `Show less often in %@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-041 | Writing-triggered visibility | RESOURCE-CONFIRMED | Expose show-while-writing action in menu bar; trigger detection and persistence UNKNOWN. | `Show while writing` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-042 | Context exclusion duration | RESOURCE-CONFIRMED | Expose parametrized timed app exclusion; supported durations and timer behavior UNKNOWN. | `Turn off %1$@ in %2$@ for %3$@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-043 | Block-list empty state | RESOURCE-CONFIRMED | Represent empty user exclusion list; creation/navigation transition UNKNOWN. | `You haven’t turned off %@ for any apps or websites.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-044 | Block-list target entry | RESOURCE-CONFIRMED | Accept target identification; matching, duplicate validation and website normalization UNKNOWN. | `Specify the name of an app/website` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-045 | Organization lock indicator | RESOURCE-CONFIRMED | Represent setting controlled by policy; editability, precedence and policy synchronization UNKNOWN. | `Locked by organization` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-046 | Organization policy service failure | RESOURCE-CONFIRMED | Fragment represents unavailable policy lookup; fail-open/fail-closed behavior and retry UNKNOWN. | `There is an issue connecting to your organization security settings.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-047 | Auth pending | RESOURCE-CONFIRMED | Represent authentication in progress; browser handoff, cancellation, callbacks and timeout UNKNOWN. | `Waiting for login...` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-048 | Institution identity restriction | RESOURCE-CONFIRMED | Fragment describes institution-specific email restriction; domain validation and allowed identity providers UNKNOWN. | `Sign in with your %1$@ email` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-049 | Auth failure | RESOURCE-CONFIRMED | Represent sign-in failure with recovery affordance; failure taxonomy and actual retry transition UNKNOWN. | `Something went wrong` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-050 | Company session policy | RESOURCE-CONFIRMED | Fragment describes example company expiry warning; actual active policy, timing and unsaved-state preservation UNKNOWN. | `Per company policy, your session expires in 1 hour.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-051 | Country service suspension | RESOURCE-CONFIRMED | Fragment identifies explicit suspended-country notice alongside Russia; actual geolocation/enforcement and applicability UNKNOWN; not a current legal-policy statement. | `Belarus` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-052 | Feedback form | RESOURCE-CONFIRMED | Provide app-rating/feedback form; required rating marker, reason input and submit labels exist; validation and transmission UNKNOWN. | `Grammarly Feedback Form` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-053 | Feedback content consent | RESOURCE-CONFIRMED | Expose text-sharing consent choice; default, scope, filtering and submission payload UNKNOWN. | `Share my text with %@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-054 | Feedback app metadata consent | RESOURCE-CONFIRMED | Expose app-information sharing choice; exact metadata, default and payload UNKNOWN. | `Share app information with %@` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-055 | Feedback sensitive text notice | RESOURCE-CONFIRMED | Fragment is a text-review notice; current processing/retention cannot be verified from copy. | `When you submit feedback, we store and review your text.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-056 | Feedback success | RESOURCE-CONFIRMED | Represent submission-success acknowledgement; actual delivery and deduplication UNKNOWN. | `Thanks for the feedback!` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-057 | Personal data report | RESOURCE-CONFIRMED | Expose personal-data-report request entry; destination, authentication and returned content UNKNOWN. | `Request a Personal Data Report.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-058 | General app menus | RESOURCE-CONFIRMED | Expose menu-bar/assistant-tab entries for open/settings/feedback/report/quit; actual quit lifecycle and menu synchronization UNKNOWN. | `Quit` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-059 | Report issue form | RESOURCE-CONFIRMED | Provide issue title/description/contact email fields and submit/cancel actions; required fields and transmission UNKNOWN; covered by the lifecycle and error requirements. | `Title` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-060 | Issue report auth gate | RESOURCE-CONFIRMED | Resource describes authenticated reporting restriction; guest handling and return-to-form behavior UNKNOWN. | `Looks like you're logged out! Please sign in to report your issue.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-061 | Support request cancellation | RESOURCE-CONFIRMED | Represent cancellation confirmation; discard and resume transitions UNKNOWN. | `Cancel support request?` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-062 | Support request restart | RESOURCE-CONFIRMED | Expose report restart; whether draft/logs are cleared is UNKNOWN until observed. | `Start over` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-063 | Onboarding failure | RESOURCE-CONFIRMED | Represent setup failure with retry/support labels; retry lifecycle UNKNOWN. | `Something went wrong` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-064 | Tutorial skipping | RESOURCE-CONFIRMED | Expose tutorial exit and replay affordances; saved completion and replay transition UNKNOWN. | `Skip tutorial` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-065 | Extension missing/unenabled states | RESOURCE-CONFIRMED | Resource distinguishes extension installation from allowed/enabled state; detection and remediation UNKNOWN. | `To get started, make sure the extension is installed.` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-066 | Unsupported browser | RESOURCE-CONFIRMED | Represent unsupported-browser condition; resource names alternative browsers but current compatibility UNKNOWN. | `Unsupported browser` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-067 | Required client update | RESOURCE-CONFIRMED | Represent mandatory-update gate; version check, blocking scope and installation transition UNKNOWN. | `Update Required` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-068 | Update failure recovery | RESOURCE-CONFIRMED | Represent update failure/reinstall guidance; actual updater lifecycle UNKNOWN; covered by the lifecycle and error requirements. | `Update Failed` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-069 | Unsupported OS feature gate | RESOURCE-CONFIRMED | Represent operating-system compatibility gate; version threshold and fallback UNKNOWN. | `Update your macOS to use %@ for Mac` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-070 | Current client coexistence | RESOURCE-CONFIRMED | Expose running-app variant conflict choices; mutual exclusion, data migration and application switching UNKNOWN. | `Continue with Grammarly` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-071 | Generative terms notice | RESOURCE-CONFIRMED | Fragment identifies generation-specific terms notice; acceptance tracking and blocking behavior UNKNOWN. | `additional terms` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |
| SC-072 | Shortcut edit conflict | RESOURCE-CONFIRMED | Shortcut edit cancellation exists; no explicit collision rule found in reviewed labels, so conflict detection/resolution and reserved keys UNKNOWN. | `Cancel editing %@ shortcut` | R-WR / `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` |

### Remaining resource-label coverage and unresolved mapping

This table categorizes every R-WR label not directly selected above. Remaining labels were reviewed for additional functional families; the added rows cover distinct families found in that review. Counts audit assignment within this single export, not global feature completeness or independent feature counts. Duplicated controls, grammar variants and accessibility names must not create new behavior. All categories remain behaviorally unconfirmed; no transitions inferred from labels have been observed. **Global feature/screen/transition coverage is UNKNOWN**: remote-delivered UI, disabled experiments, missing locales, entitlement paths and absent resource text may add capabilities.

| Category | Remaining keys | Candidate treatment / unknowns |
|---|---:|---|
| Authorship — owned by another section | 65 | Require cross-section Authorship mapping; no claims of actual tracking from strings. |
| Notetaker / voice — owned by another section | 15 | Require cross-section audio/meeting mapping; no recording performed. |
| Installation, operating-system permissions, updates and diagnostics — owned by another section | 99 | Separate lifecycle/platform evidence; do not silently make technical error strings user-facing requirements. |
| Go branding, app coexistence and rollout — unresolved mode scope | 25 | Treat as dormant/alternate-mode candidates until observed in enabled Go mode. |
| Account, authentication, entitlement and geographic policy variants | 78 | Consolidate wording variants; current plan/region/admin behavior UNKNOWN. |
| Writing review, scoring, style, tone, snippets and originality variants | 190 | Consolidate label variants with WR requirements; exact app eligibility and transitions UNKNOWN. |
| Chat, prompt, context and conversation variants — mode scope unresolved | 68 | Do not enable in classic implementation based only on labels; state/input/output flow UNKNOWN. |
| Navigation, accessibility, UI chrome and shared actions | 160 | Map to independently designed controls and accessibility requirements after observed flow study. |
| Unmapped examples, notices, content and generic labels | 159 | Some are demo text or support copy; retain as UNKNOWN and do not turn into behavioral requirements. |

Resource-assignment coverage only (global functional coverage UNKNOWN): 1056 R-WR keys; 197 selected evidence keys; 859 remaining keys categorized. Selected rows can share a key only when explicitly discussing distinct unknown behavior.

### Required follow-up observations (all UNKNOWN)

- Use a neutral test document to observe underline/card presentation, accepting/ignoring corrections, multi-suggestion navigation, undo and clipboard formats; see BB-001–005 for the finite Chrome fixture; the other actions remain UNKNOWN.
- Observe classic generative selection and email-reply entries before assigning chat/attachment/history capabilities to that mode. Observe Go separately only if mode switching is later authorized.
- Use synthetic text to test score thresholds, styles, snippet input validation, limits, serialization and quota-reset behavior; resource labels are not executable validation evidence.
- Establish actual languages, supported applications, current plan entitlement and administrator restrictions from visible UI with synthetic content; do not use private profile data.
- Reconcile contradictory snippet maxima rather than selecting one packaged variant. Quantities in placeholders stay UNKNOWN.
- Verify original text replacement preserves content and formatting appropriately; no generation quality or algorithmic equivalence is established by this study.

### Native-menu evidence boundary

Interface-resource decode evidence `ev_60beef46bfb625889bfa4f4bf4b1bf63ef30788c4fddc3faca7bcc88fd7fab96` containing product preferences/quit actions. This supports packaged affordance existence only; native selector names are evidence locators, not algorithms or implementation requirements. Generic helper nib template menus are excluded from product feature claims. Shortcut collision policy remains UNKNOWN: reviewed labels did not establish one.

## 6. Voice, meeting, Authorship and error requirements

For all rows: transition trigger, sequencing, persistence, cancellation semantics, retry policy, network transport, timing, and entitlement are UNKNOWN unless the row explicitly says the label itself specifies a value. Inputs and outputs are proposed externally observable contracts, not recovered implementation.

### Voice and dictation

| ID | Source and exact short evidence | Input → candidate output | Candidate states and edges |
|---|---|---|---|
| VO-001 | R-VOICE: `Start dictation` | User invokes voice entry → recording surface | idle / recording; activation path unobserved; transition UNKNOWN. |
| VO-002 | R-MAIN: `Voice Input` | User opens settings → voice configuration | settings visible / hidden; transition UNKNOWN. |
| VO-003 | R-VOICE: `Start recording` | User starts capture → recording indicator | idle / recording; microphone permission edge; transition UNKNOWN. |
| VO-004 | R-VOICE: `Stop recording` | User stops capture → completed capture | recording / stopped; transcription timing unknown; transition UNKNOWN. |
| VO-005 | R-VOICE: `Finish dictation` | User finishes utterance → text result | recording / processing / complete; transition UNKNOWN. |
| VO-006 | R-VOICE: `Cancel dictation` | User cancels → dismissed or idle surface | recording / cancelled; retained audio/text unknown; transition UNKNOWN. |
| VO-007 | R-VOICE: `Cancel recording` | User cancels recording → capture ends | recording / cancelled; distinct from dictation cancellation until tested; transition UNKNOWN. |
| VO-008 | R-VOICE: `Restart recording` | User restarts → new capture | recording / stopped / restarting; replacement semantics unknown; transition UNKNOWN. |
| VO-009 | R-VOICE: `Processing...` | Captured speech → progress feedback | processing; duration, timeout, and finalization unknown; transition UNKNOWN. |
| VO-010 | R-VOICE: `Done (dictation status)` | Successful processing → completion status | done; insertion target and autosubmit unknown; transition UNKNOWN. |
| VO-011 | R-VOICE: `Copied to clipboard` | Result copy action → clipboard acknowledgement | result ready / copied; automatic copy versus explicit copy unknown; transition UNKNOWN. |
| VO-012 | R-MAIN: `Use system default (microphone picker item)` | User picks default input → selected device indication | default / explicit device / device unavailable; transition UNKNOWN. |
| VO-013 | R-MAIN: `Hide Forever (dictation button context menu)` | User hides voice entry → hidden entry point | visible / permanently hidden; restoration path unknown; transition UNKNOWN. |
| VO-014 | R-MAIN: `Open Transcriber key` | User configures shortcut → assigned binding | unassigned / recording binding / assigned; actual keys unknown; transition UNKNOWN. |

### Notetaker and meetings

| ID | Source and exact short evidence | Input → candidate output | Candidate states and edges |
|---|---|---|---|
| NT-001 | R-MEETING: `Open Notetaker` | User opens feature → notes window | closed / open; separate label says opening alone does not record; transition UNKNOWN. |
| NT-002 | R-MEETING: `Opens Notetaker without starting a recording.` | User opens window → idle view | open idle / recording must be distinguishable; transition UNKNOWN. |
| NT-003 | R-MEETING: `Sign in (notetaker onboarding button)` | User authenticates → onboarding continuation | signed out / authenticating / ready; transition UNKNOWN. |
| NT-004 | R-MEETING: `Continue (notetaker onboarding button)` | User continues setup → next setup stage | onboarding / permissions / ready; order unknown; transition UNKNOWN. |
| NT-005 | R-MEETING: `Skip (notetaker onboarding button)` | User skips offered step → subsequent state | optional step / skipped; skip scope unknown; transition UNKNOWN. |
| NT-006 | R-MEETING: `Allow Notetaker to hear you` | User grants microphone access → self audio usable | permission absent / granted / denied; transition UNKNOWN. |
| NT-007 | R-MEETING: `Allow Notetaker to hear others` | User grants system audio access → other audio usable | permission absent / granted / denied; transition UNKNOWN. |
| NT-008 | R-MEETING: `Select microphone` | User chooses input → chosen microphone | loading devices / list / selected / missing device; transition UNKNOWN. |
| NT-009 | R-MEETING: `Select language` | User chooses transcription language → language setting | unset / selected; supported list unknown; transition UNKNOWN. |
| NT-010 | R-MEETING: `Start Notetaking` | User starts notes → active capture | idle / recording; equivalent Start notetaker / Start taking notes labels exist; transition UNKNOWN. |
| NT-011 | R-MEETING: `Stop Notetaker` | User stops → stopped capture | recording / stopped; equivalents Stop recording / Stop button exist; transition UNKNOWN. |
| NT-012 | R-MEETING: `Stopped by user` | User stop → explicit stop status | stopped-by-user; system-stop distinction unknown; transition UNKNOWN. |
| NT-013 | R-MEETING: `Resume Meeting` | User resumes → continued session | stopped / resumed; append versus new recording unknown; transition UNKNOWN. |
| NT-014 | R-MEETING: `Cannot start new note while recording` | User requests concurrent new note → rejection | recording blocks new-note operation; transition UNKNOWN. |
| NT-015 | R-MEETING: `New note (notetaker sidebar button)` | User requests note → new session surface | empty / draft / selected meeting; no recording side effect proven; transition UNKNOWN. |
| NT-016 | R-MEETING: `Join meeting and start notetaker` | User joins scheduled event → meeting plus capture requested | scheduled / joining / recording; atomicity unknown; transition UNKNOWN. |
| NT-017 | R-MEETING: `Auto-start Notetaker for meetings in my calendar` | User toggles automation → calendar-based auto-start preference | off / on / permission missing; scheduling policy unknown; transition UNKNOWN. |
| NT-018 | R-MEETING: `Auto-detected meetings` | Application identifies meeting → notification/start opportunity | undetected / detected / dismissed; matching algorithm unknown; transition UNKNOWN. |
| NT-019 | R-MEETING: `Your meeting appears to have ended.` | Detected end → end-of-meeting feedback | recording / end detected; actual auto-stop not established by this label; transition UNKNOWN. |
| NT-020 | R-MEETING: `Show upcoming meetings in menu bar` | User toggles visibility → upcoming-event menu | hidden / countdown / event list; transition UNKNOWN. |
| NT-021 | R-MEETING: `Display a countdown in the macOS menu bar` | Scheduled event approaches → countdown | scheduled / countdown; zero handling unknown; transition UNKNOWN. |
| NT-022 | R-MEETING: `Show notifications 30 seconds before meetings start based on your calendar` | Calendar event → 30-second-prior notification candidate | notifications off / scheduled / delivered; timezone and overlap unknown; transition UNKNOWN. |
| NT-023 | R-MEETING: `Mute until tomorrow` | User mutes → temporal suppression | unmuted / muted-until-tomorrow; day boundary unknown; transition UNKNOWN. |
| NT-024 | R-MEETING: `Mute for 1 week` | User mutes → suppression for offered period | unmuted / muted-one-week; exact interval unknown; transition UNKNOWN. |
| NT-025 | R-MEETING: `Play notification on meeting auto-start/stop` | User configures cue → start/stop sound | sound off / on; device and volume unknown; transition UNKNOWN. |
| NT-026 | R-MEETING: `On auto-start, open the Notetaker window` | User configures window policy → open on auto-start | collapsed / expanded; equivalent Open notes window label exists; transition UNKNOWN. |
| NT-027 | R-MEETING: `Sign in to your \nwork calendar` | User connects calendar → event access | disconnected / connecting / connected / failure; transition UNKNOWN. |
| NT-028 | R-MEETING: `Manage connection` | User manages integration → connection controls | connected / disconnected; provider inventory unknown; transition UNKNOWN. |
| NT-029 | R-MEETING: `Select calendar event` | User associates event → selected metadata | none / selected; None choice exists; transition UNKNOWN. |
| NT-030 | R-MEETING: `Summary (meeting tab)` | User chooses summary → generated summary view | not available / pending / ready / failed; transition UNKNOWN. |
| NT-031 | R-MEETING: `Regenerate Summary` | User requests replacement → progress and summary | ready / regenerating / ready or failure; transition UNKNOWN. |
| NT-032 | R-MEETING: `Regenerate as...` | User requests format variation → alternate summary candidate | format selection / regenerating; formats unknown; transition UNKNOWN. |
| NT-033 | R-MEETING: `Transcript (meeting tab)` | User selects transcript → transcript view | loading / absent / available; transition UNKNOWN. |
| NT-034 | R-MEETING: `Notes (meeting tab)` | User selects notes → notes view | empty / available; editability unknown; transition UNKNOWN. |
| NT-035 | R-MEETING: `Metadata (meeting tab)` | User selects metadata → meeting details | loading / available / failure; transition UNKNOWN. |
| NT-036 | R-MEETING: `Action Items` | Extraction completes → action-item section | empty / extracted; ownership and due dates unknown; transition UNKNOWN. |
| NT-037 | R-MEETING: `Open Questions` | Extraction completes → unresolved-question section | empty / extracted; transition UNKNOWN. |
| NT-038 | R-MEETING: `Decisions (meeting detail group)` | Extraction completes → decision section | empty / extracted; transition UNKNOWN. |
| NT-039 | R-MEETING: `Risks (meeting detail group)` | Extraction completes → risk section | empty / extracted; transition UNKNOWN. |
| NT-040 | R-MEETING: `People (meeting detail group)` | Metadata extraction → people section | empty / extracted; speaker identity proof absent; transition UNKNOWN. |
| NT-041 | R-MEETING: `Topics (meeting detail group)` | Metadata extraction → topic section | empty / extracted; transition UNKNOWN. |
| NT-042 | R-MEETING: `Files (meeting detail group)` | Metadata extraction → linked files section | empty / extracted; uploads not established; transition UNKNOWN. |
| NT-043 | R-MEETING: `Links (meeting detail group)` | Metadata extraction → links section | empty / extracted; transition UNKNOWN. |
| NT-044 | R-MEETING: `Projects (meeting detail group)` | Metadata extraction → project section | empty / extracted; transition UNKNOWN. |
| NT-045 | R-MEETING: `Series (meeting detail group)` | Metadata extraction → series field | empty / extracted; transition UNKNOWN. |
| NT-046 | R-MEETING: `Platform (meeting detail group)` | Metadata extraction → platform field | empty / extracted; platform support matrix unknown; transition UNKNOWN. |
| NT-047 | R-MEETING: `Ask anything about this note` | User submits question → note-scoped answer | new conversation / sending / response / failure; transition UNKNOWN. |
| NT-048 | R-MEETING: `Assign a task or ask anything` | User submits request → assistant response candidate | idle / working / response; actual external execution unknown; transition UNKNOWN. |
| NT-049 | R-MEETING: `New Conversation` | User starts chat → empty conversation | existing / new; history retention unknown; transition UNKNOWN. |
| NT-050 | R-MEETING: `Recent Conversations` | User opens recents → conversation list | empty / loaded; transition UNKNOWN. |
| NT-051 | R-MEETING: `Clear Recents` | User clears list → cleared recents candidate | populated / clear requested; deletion scope unknown; transition UNKNOWN. |
| NT-052 | R-MEETING: `Copy Summary` | User copies summary → clipboard content | ready / copied; formatting unknown; transition UNKNOWN. |
| NT-053 | R-MEETING: `Copy Transcript` | User copies transcript → clipboard content | ready / copied; speaker/timecode inclusion unknown; transition UNKNOWN. |
| NT-054 | R-MEETING: `Select All (transcript menu item)` | User selects transcript → selection | unselected / all selected; transition UNKNOWN. |
| NT-055 | R-MEETING: `Share (meeting button)` | User shares → share flow | unshared / share configuration / shared; access control unknown; transition UNKNOWN. |
| NT-056 | R-MEETING: `Share notes via email` | User configures email sharing → shared note/summary candidate | off / on / pending / sent; recipients and confirmation unknown; transition UNKNOWN. |
| NT-057 | R-MEETING: `Share notes in calendar event` | User configures calendar sharing → link attached to event | off / on / pending / updated; transition UNKNOWN. |
| NT-058 | R-MEETING: `Notes will be shared after the meeting ends.` | Meeting ends → deferred sharing candidate | recording / ended / share pending; actual dispatch unknown; transition UNKNOWN. |
| NT-059 | R-MEETING: `Auto-post in meeting chat` | User enables notification → meeting-chat message candidate | disabled / enabled / posted; supported apps unknown; transition UNKNOWN. |
| NT-060 | R-MEETING: `Add a heads-up to meeting invites` | User enables invite notice → invite message candidate | off / on; modifications and recipients unknown; transition UNKNOWN. |
| NT-061 | R-MEETING: `Message (notetaker settings field label)` | User supplies consent notice → configured message | empty / valid / too-short / too-long; transition UNKNOWN. |
| NT-062 | R-MEETING: `Always get consent before recording others` | User enters setup → consent education/acknowledgement | unacknowledged / acknowledged; mandatory gating unknown; transition UNKNOWN. |
| NT-063 | R-MEETING: `Notetaker uses the sound in your computer. No bots joining the meeting.` | Captured computer sound → notes/transcript candidate | system-audio permission needed; capture behavior not observed; transition UNKNOWN. |
| NT-064 | R-MEETING: `Meeting name` | User names/renames note → title | unnamed / named; default title not in this evidence set; transition UNKNOWN. |
| NT-065 | R-MEETING: `Rename Meeting` | User requests rename → rename sheet | viewing / editing / saved or cancelled; transition UNKNOWN. |
| NT-066 | R-MEETING: `Delete Meeting` | User requests deletion → confirmation | existing / confirming / deleted or cancelled; irreversibility label exists; transition UNKNOWN. |
| NT-067 | R-MEETING: `View on web` | User opens web destination → meeting in browser | native view / external view; URL and auth unknown; transition UNKNOWN. |
| NT-068 | R-MEETING: `No past meetings` | No stored history → empty state | empty history / populated history; transition UNKNOWN. |
| NT-069 | R-MEETING: `Your transcript will appear here` | Pending or absent transcript → placeholder | empty / pending; distinction unknown; transition UNKNOWN. |
| NT-070 | R-MEETING: `No tags or artifacts` | No extracted material → empty state | empty metadata / extracted metadata; transition UNKNOWN. |
| NT-071 | R-MEETING: `Get the new Notetaker` | User follows migration → standalone destination candidate | legacy / migration notice / standalone; activation unknown; transition UNKNOWN. |
| NT-072 | R-MAIN: `Notetaker has moved. Download the new one %1$@` | Migration configuration → replacement of feature settings candidate | legacy feature / migrated; coexisting labels do not prove current branch; transition UNKNOWN. |

### Authorship and writing activity

| ID | Source and exact short evidence | Input → candidate output | Candidate states and edges |
|---|---|---|---|
| AU-001 | R-MAIN: `Authorship (feature name)` | User opens authorship → activity panel | off / ready / tracking / paused / unavailable; transition UNKNOWN. |
| AU-002 | R-MAIN: `Start tracking (tracking reminder button)` | User starts activity recording → active tracking | ready / tracking; document scope; transition UNKNOWN. |
| AU-003 | R-MAIN: `Skip (tracking reminder button)` | User skips reminder → no start candidate | ready / skipped; future reminders unknown; transition UNKNOWN. |
| AU-004 | R-MAIN: `Track your writing (writing-activity panel row title)` | User selects document tracking → document tracking setting | off / on; exact gesture unknown; transition UNKNOWN. |
| AU-005 | R-MAIN: `Tracking is on` | Active tracking → visible status | tracking; equivalents Tracking is currently on / Authorship tracking is on; transition UNKNOWN. |
| AU-006 | R-MAIN: `Tracking is paused` | Tracking suspended → paused status | tracking / paused; resumption unknown; transition UNKNOWN. |
| AU-007 | R-MAIN: `Turn off Authorship` | User disables feature → tracking unavailable/off | on / off; effect on existing data unknown; transition UNKNOWN. |
| AU-008 | R-MAIN: `Turn on automatic tracking` | User enables automation → new-doc tracking preference | automatic off / on; transition UNKNOWN. |
| AU-009 | R-MAIN: `Turn off automatic tracking` | User disables automation → stop automatic tracking for new documents | automatic on / off; ongoing document effect unknown; transition UNKNOWN. |
| AU-010 | R-MAIN: `Authorship is now tracking all new docs` | New document under automation → activity capture candidate | new doc / tracking; supported app scope unknown; transition UNKNOWN. |
| AU-011 | R-MAIN: `See report (writing-activity panel button)` | User opens report → document activity report | tracking / report view; browser/native location unknown; transition UNKNOWN. |
| AU-012 | R-MAIN: `Allow clipboard access (writing-activity panel menu item)` | User grants clipboard source access → source attribution | denied / granted; tracking independent of grant per fallback label; transition UNKNOWN. |
| AU-013 | R-MAIN exact fragment: `Copied from unknown source` | Pasted content with no clipboard permission → unknown attribution | paste / unknown source; exact substring from longer fallback explanation; transition UNKNOWN. |
| AU-014 | R-MAIN: `Allow access (Authorship permission panel button)` | User grants Word/application access → richer document support | permission absent / granted / denied; transition UNKNOWN. |
| AU-015 | R-MAIN: `Track unsaved and OneDrive docs, and work with Canvas.` | Permission-enabled document → integration candidate | saved / unsaved / OneDrive / Canvas; supported versions unknown; transition UNKNOWN. |
| AU-016 | R-MAIN: `Tracking covers up to %d pages.` | Document approaches configured page ceiling → warning/limit feedback | tracking / near limit / paused; numeric limit UNKNOWN; transition UNKNOWN. |
| AU-017 | R-MAIN: `You're nearing the %d-page tracking limit.` | Near ceiling → pre-limit warning | near-limit; exact threshold unknown; transition UNKNOWN. |
| AU-018 | R-MAIN: `Tracking paused (page-limit bubble heading)` | Ceiling reached → tracking suspension and retained partial report | at-limit / paused; label says report covers prior activity; transition UNKNOWN. |
| AU-019 | R-MAIN: `Tracking unavailable. (page-limit banner)` | Unsupported tracking condition → unavailable banner | unavailable; attribution to page limit only from key context; transition UNKNOWN. |
| AU-020 | R-MAIN: `Delete data for this doc` | User requests document-data deletion → confirmation | data present / confirmation / deleting / deleted or failed; transition UNKNOWN. |
| AU-021 | R-MAIN: `Yes, delete data` | User confirms → delete report data and stop tracking candidate | deleting / deleted; other reports/docs explicitly unaffected; transition UNKNOWN. |
| AU-022 | R-MAIN: `Delete all %@ data for this doc?` | User deletion request → irreversible deletion warning | confirm / cancel; actual backend result unknown; transition UNKNOWN. |
| AU-023 | R-MAIN: `New! ✨ Authorship tracks your writing across devices. Work on a doc from anywhere using the same report.` | Same document on another device → shared report continuity candidate | local / cross-device; identity/conflict algorithm unknown; transition UNKNOWN. |
| AU-024 | R-MAIN: `How Authorship works?` | User requests explanation → help/education | panel / help; destination unknown; transition UNKNOWN. |
| AU-025 | R-MAIN: `Give feedback (writing-activity panel menu item)` | User gives authorship feedback → feedback flow | ready / submitted; fields unknown; transition UNKNOWN. |
| AU-026 | R-MAIN: `Report an issue (writing-activity panel menu item)` | User reports authorship issue → support flow | ready / issue report; transition UNKNOWN. |

### Failure, edge, validation, and recovery contracts

| ID | Source and exact short evidence | Input → candidate output | Candidate states and edges |
|---|---|---|---|
| ER-001 | R-VOICE: `Authorization failed. Please sign in again.` | Authentication unsuccessful → request renewed sign-in | unauthorized / sign-in-required; transition UNKNOWN. |
| ER-002 | R-VOICE: `Microphone permission was denied.` | Mic permission rejected → recording cannot proceed candidate | permission denied; transition UNKNOWN. |
| ER-003 | R-VOICE: `No microphone permission` | Missing microphone grant → permission feedback | permission missing; no automatic prompt proven; transition UNKNOWN. |
| ER-004 | R-VOICE: `Failed to start audio recording.` | Capture initiation fails → recording-start failure | idle / start failed; transition UNKNOWN. |
| ER-005 | R-VOICE: `Failed to encode an audio chunk for streaming.` | Audio chunk encoding fails → streaming error | recording / encoding failed; transition UNKNOWN. |
| ER-006 | R-VOICE: `Failed to reconfigure input device: %1$@. Rollback failed: %2$@` | Device switch fails and recovery also fails → two-part error | reconfiguring / failed rollback; two detail placeholders; transition UNKNOWN. |
| ER-007 | R-VOICE: `The selected input device is not available.` | Chosen microphone disappears/is absent → unavailable-device feedback | device selected / unavailable; transition UNKNOWN. |
| ER-008 | R-VOICE: `No active recording is in progress.` | Stop/finalize requested without capture → invalid-state error | idle / operation rejected; transition UNKNOWN. |
| ER-009 | R-VOICE: `Recording is already in progress.` | Start requested during capture → duplicate-start error | recording / operation rejected; transition UNKNOWN. |
| ER-010 | R-VOICE: `No transcription text was returned.` | Processing yields no text → empty-result failure | processing / no text; transition UNKNOWN. |
| ER-011 | R-VOICE: `The audio file is too large.` | Oversized audio → reject upload/process candidate | size exceeded; threshold UNKNOWN; transition UNKNOWN. |
| ER-012 | R-VOICE: `The request was rejected by the server.` | Service rejects request → request error | rejected; status mapping UNKNOWN; transition UNKNOWN. |
| ER-013 | R-VOICE: `The server encountered an error.` | Service fails internally → server failure | service error; status UNKNOWN; transition UNKNOWN. |
| ER-014 | R-VOICE: `The server returned a bad gateway response.` | Upstream gateway fails → gateway failure | gateway error; retry policy UNKNOWN; transition UNKNOWN. |
| ER-015 | R-VOICE: `The service is temporarily unavailable.` | Service unavailable → availability feedback | unavailable; duration UNKNOWN; transition UNKNOWN. |
| ER-016 | R-VOICE: `Unexpected server response (status %d).` | Other response → status-bearing fallback | unexpected response; numeric status displayed; transition UNKNOWN. |
| ER-017 | R-MEETING: `You must give Notetaker permission to hear everyone to proceed.` | Required audio grant missing → setup cannot continue | permissions incomplete / blocked; transition UNKNOWN. |
| ER-018 | R-MEETING: `Cannot start new note while recording` | Concurrent new-note action → blocked action | recording / rejected; transition UNKNOWN. |
| ER-019 | R-MEETING: `Failed to connect` | Connection attempt fails → connection failure | connecting / failed; associated provider UNKNOWN; transition UNKNOWN. |
| ER-020 | R-MEETING: `Failed to load meeting details` | Meeting details unavailable → load-failure state | loading / failed; transition UNKNOWN. |
| ER-021 | R-MEETING: `Couldn't load tags` | Metadata tag loading fails → tags failure | loading tags / failed; transition UNKNOWN. |
| ER-022 | R-MEETING: `Failed to send` | Assistant/message submission fails → unsent feedback | sending / failed; duplicate-send risk UNKNOWN; transition UNKNOWN. |
| ER-023 | R-MEETING: `Message is too long` | Message above allowed size → validation feedback | invalid-long; limit UNKNOWN; transition UNKNOWN. |
| ER-024 | R-MEETING: `Message is too short` | Message below allowed size → validation feedback | invalid-short; limit UNKNOWN; transition UNKNOWN. |
| ER-025 | R-MEETING: `Summary generation failed` | Initial summary cannot be produced → failure | generating / failed; transition UNKNOWN. |
| ER-026 | R-MEETING: `Summary regeneration failed` | Requested replacement cannot be produced → failure | regenerating / failed; prior summary retention UNKNOWN; transition UNKNOWN. |
| ER-027 | R-MEETING: `No summary available` | No summary returned → absent-summary state | absent / pending / failed ambiguity; transition UNKNOWN. |
| ER-028 | R-MEETING: `Summary not available` | Unavailable summary → availability state | absent / pending / failed ambiguity; duplicate wording; transition UNKNOWN. |
| ER-029 | R-MEETING: `No transcript available` | No transcript returned → absent-transcript state | absent / pending / failed ambiguity; transition UNKNOWN. |
| ER-030 | R-MEETING: `Nothing was extracted for this meeting yet.` | Extraction returns no content → empty extraction | empty / pending ambiguity; transition UNKNOWN. |
| ER-031 | R-MEETING: `That did not work` | Unspecified failure → generic feedback | generic failure; equivalent That didn't work also exists; transition UNKNOWN. |
| ER-032 | R-MEETING: `You're using an outdated version of Notetaker.` | Legacy version → migration/update notice | outdated / migration offered; transition UNKNOWN. |
| ER-033 | R-MEETING: `Retry (meeting chat button)` | User retries chat operation → another attempt candidate | failed / retrying; same input and idempotency UNKNOWN; transition UNKNOWN. |
| ER-034 | R-MEETING: `Reconnect (meeting chat button)` | User reconnects → connection attempt | disconnected / reconnecting; transition UNKNOWN. |
| ER-035 | R-MEETING: `Retry (meeting summary button)` | User retries summary → regeneration attempt candidate | failed / retrying; transition UNKNOWN. |
| ER-036 | R-MEETING: `Try Again (meeting tags button)` | User retries metadata tags → load attempt | failed / loading; transition UNKNOWN. |
| ER-037 | R-MAIN: `Can’t connect to %@` | Connection fails → product-specific error | offline or service failure; actual cause UNKNOWN; transition UNKNOWN. |
| ER-038 | R-MAIN: `Please check your internet connection and try again.` | Network disruption → reconnect/retry guidance | disconnected / retry offered; transition UNKNOWN. |
| ER-039 | R-MAIN: `Connection blocked` | Restricted network → blocked connection state | blocked; detection method UNKNOWN; transition UNKNOWN. |
| ER-040 | R-MAIN: `Your network settings are preventing Grammarly from opening.` | Network policy prevents launch → blocked launch | opening / blocked; transition UNKNOWN. |
| ER-041 | R-MAIN: `There is an issue connecting to your organization security settings. Please try again later or` | Organization-policy connection fails → retry/support guidance | policy-unavailable; feature blocking UNKNOWN; transition UNKNOWN. |
| ER-042 | R-MAIN: `Can't check your text (blocked by organization alert heading)` | Organization blocks context → checking unavailable | blocked-by-admin; transition UNKNOWN. |
| ER-043 | R-MAIN: `%@ and subdomains are blocked by your organization` | Blocked domain/subdomains → organization-policy feedback | domain blocked; subdomain coverage label explicit; transition UNKNOWN. |
| ER-044 | R-MAIN: `%@ is blocked by your organization` | Blocked app/domain → organization-policy feedback | context blocked; transition UNKNOWN. |
| ER-045 | R-MAIN: `%@ is unavailable in your country` | Geographic restriction → service unavailable notice | region unavailable; country list UNKNOWN; transition UNKNOWN. |
| ER-046 | R-MAIN: `%@ is temporarily unavailable` | Temporary product outage → unavailable state | temporary-unavailable; transition UNKNOWN. |
| ER-047 | R-MAIN: `%@’s features are temporarily unavailable` | Feature outage → unavailable state | features unavailable; duplicate product-level variant; transition UNKNOWN. |
| ER-048 | R-MAIN: `Some features are temporarily paused.` | Partial pause → limited-function status | partially paused; transition UNKNOWN. |
| ER-049 | R-MAIN: `Unsupported browser` | Unsupported host browser → compatibility state | unsupported; browser list UNKNOWN; transition UNKNOWN. |
| ER-050 | R-MAIN: `(Can't read content)` | Attached/window context inaccessible → unreadable-content placeholder | unreadable; reason UNKNOWN; transition UNKNOWN. |
| ER-051 | R-MAIN: `Message too large` | Chat input exceeds processing size → size error | invalid-size; transition UNKNOWN. |
| ER-052 | R-MAIN exact fragment: `Chat can only respond to messages that contain less information. To continue:` | Excess chat/window context → reduce input or begin new chat guidance | over-context; smaller selected window text suggested; numeric limit UNKNOWN; transition UNKNOWN. |
| ER-053 | R-MAIN: `Couldn't attach the file. Please try again.` | Attachment fails → retry guidance | attaching / failed; transition UNKNOWN. |
| ER-054 | R-MAIN: `Select a file smaller than %@` | File above formatted ceiling → size validation | oversized attachment; actual value UNKNOWN; transition UNKNOWN. |
| ER-055 | R-MAIN: `Chat history can't be saved right now` | Persistence fails → history-saving unavailable | save failed; unsaved content retention UNKNOWN; transition UNKNOWN. |
| ER-056 | R-MAIN: `Your Mac doesn't support the encrypted storage required to save chat history.` | Required encrypted storage unsupported → history unavailable | storage unsupported; fallback UNKNOWN; transition UNKNOWN. |
| ER-057 | R-MAIN: `Something went wrong (assistant sign-in problem panel heading)` | Assistant auth fails → generic auth failure | sign-in failed; transition UNKNOWN. |
| ER-058 | R-MAIN: `Something went wrong (chat error card heading)` | Chat request fails → generic chat error | chat failed; transition UNKNOWN. |
| ER-059 | R-MAIN: `Something went wrong (onboarding heading)` | Setup fails → generic setup error | onboarding failed; transition UNKNOWN. |
| ER-060 | R-MAIN: `Something went wrong (rewrite card error heading)` | Rewrite request fails → generic rewrite error | rewrite failed; transition UNKNOWN. |
| ER-061 | R-MAIN: `Something went wrong (writing suggestions error heading)` | Checking fails → generic suggestions error | checking failed; transition UNKNOWN. |
| ER-062 | R-MAIN: `Something went wrong. Learn more` | Unspecified failure → learn-more path | generic failure; feature UNKNOWN; transition UNKNOWN. |
| ER-063 | R-MAIN: `Retry (chat error card button)` | User retries failed chat → another attempt candidate | failed / retrying; transition UNKNOWN. |
| ER-064 | R-MAIN: `Retry (rewrite card tooltip)` | User retries rewrite → another attempt candidate | failed / retrying; transition UNKNOWN. |
| ER-065 | R-MAIN: `Try again (writing suggestions error button)` | User retries checking → another attempt candidate | failed / retrying; transition UNKNOWN. |
| ER-066 | R-MAIN: `Try again (onboarding button)` | User retries setup → another attempt candidate | failed / retrying; transition UNKNOWN. |
| ER-067 | R-MAIN: `Please wait a moment, then try again.` | Temporary failure → delayed retry guidance | transient error; wait duration UNKNOWN; transition UNKNOWN. |
| ER-068 | R-MAIN: `Please try again. If it doesn't work, please contact support.` | Repeated failure → retry then support guidance | failure / retry / support; threshold UNKNOWN; transition UNKNOWN. |
| ER-069 | R-MAIN: `Quit and reopen %@ to try again.` | Unspecified state requires restart → restart guidance | failure / restart requested; transition UNKNOWN. |
| ER-070 | R-MAIN: `Please sign in again. Still not working?` | Stale authentication → sign-in and support route | reauthentication required; transition UNKNOWN. |
| ER-071 | R-MAIN exact fragment: `Per company policy, your session expires in 1 hour.` | Enterprise expiry approaches → one-hour warning | authenticated / expiring; actual expiry enforcement UNKNOWN; transition UNKNOWN. |
| ER-072 | R-MAIN: `You won’t get any writing suggestions until you sign back in.` | Signed-out state → suggestions withheld | signed out / checking disabled; transition UNKNOWN. |
| ER-073 | R-MAIN: `Sign back in to access Enterprise features.` | Enterprise access lost → reauthentication prompt | Enterprise signed-out; Pro/Plus variants coexist; transition UNKNOWN. |
| ER-074 | R-MAIN: `Sign back in to access Plus features.` | Plus access lost → reauthentication prompt | Plus signed-out; plan availability UNKNOWN; transition UNKNOWN. |
| ER-075 | R-MAIN: `Sign back in to access Pro features.` | Pro access lost → reauthentication prompt | Pro signed-out; plan availability UNKNOWN; transition UNKNOWN. |
| ER-076 | R-MAIN: `Upgrade for unlimited access to suggestions.` | Suggestion allowance exhausted or restricted → upsell candidate | limited / upgrade offered; quota and reset UNKNOWN; transition UNKNOWN. |
| ER-077 | R-MAIN: `Upgrade for unlimited paragraph rewrites` | Rewrite allowance restricted → upsell candidate | limited / upgrade offered; quota and reset UNKNOWN; transition UNKNOWN. |
| ER-078 | R-MAIN: `To give you suggestions, we need 3 words or more.` | Fewer than three words → insufficient-text guidance | below 3 / eligible input candidate; exact tokenization UNKNOWN; transition UNKNOWN. |
| ER-079 | R-MAIN: `Grammarly needs at least 30 words to calculate a score.` | Fewer than thirty words → score unavailable | below 30 / scoring eligible candidate; transition UNKNOWN. |
| ER-080 | R-MAIN: `Paste 200 words or more` | Insufficient writing sample → minimum-length prompt | below 200 / sample eligible candidate; feature UNKNOWN; transition UNKNOWN. |
| ER-081 | R-MAIN: `Write a bit more` | Insufficient text → expanded-input guidance | insufficient input; threshold UNKNOWN; transition UNKNOWN. |
| ER-082 | R-MAIN: `We were unable to generate ideas for your audience` | Audience generation fails → generation failure | generating / failed; transition UNKNOWN. |
| ER-083 | R-MAIN: `Snippet exceeds 1,000 characters` | Snippet beyond stated ceiling → validation | over 1000; entitlement/context UNKNOWN; transition UNKNOWN. |
| ER-084 | R-MAIN: `Snippet exceeds 5,000 characters` | Snippet beyond alternate ceiling → validation | over 5000; conflicting branch until tested; transition UNKNOWN. |
| ER-085 | R-MAIN: `Snippet name exceeds 30 characters` | Name beyond stated ceiling → validation | over 30; entitlement/context UNKNOWN; transition UNKNOWN. |
| ER-086 | R-MAIN: `Snippet name exceeds 400 characters` | Name beyond alternate ceiling → validation | over 400; conflicting branch until tested; transition UNKNOWN. |
| ER-087 | R-MAIN: `Unknown Error (new snippet failure)` | New snippet operation fails → fallback error | create failed; detail UNKNOWN; transition UNKNOWN. |
| ER-088 | R-MAIN: `We couldn't completely delete this document's data. Please try again.` | Authorship deletion incomplete → retry guidance | deleting / partially failed; exact residual data UNKNOWN; transition UNKNOWN. |
| ER-089 | R-MAIN: `Failed to collect logs` | Diagnostics collection fails → log error | collecting / failed; transition UNKNOWN. |
| ER-090 | R-MAIN: `Failed to start recording` | Diagnostic screen capture fails → recording error | capture start failed; distinct from voice recording; transition UNKNOWN. |
| ER-091 | R-MAIN: `Looks like you're logged out! Please sign in to report your issue.` | Support submit while signed out → reauthentication | signed out / reporting blocked; transition UNKNOWN. |
| ER-092 | R-MAIN: `If you exit now, your report won't be saved.` | Exit incomplete diagnostic flow → unsaved-report warning | draft / abandon confirmation; transition UNKNOWN. |
| ER-093 | R-MAIN: `Stop reporting? (alert heading)` | User aborts diagnostic flow → confirmation | reporting / confirming stop / stopped or resumed; transition UNKNOWN. |
| ER-094 | R-MAIN: `Recording stopped after 10 minutes. If you wish to record a different video, click %@ and try again.` | Diagnostic screen capture reaches ten minutes → automatic stop/retry guidance | recording / stopped-at-10min; voice/notetaker limit NOT implied; transition UNKNOWN. |
| ER-095 | R-MAIN: `Add in some more description to help us help you debug faster.` | Diagnostic description insufficient → add-detail guidance | invalid description; minimum UNKNOWN; transition UNKNOWN. |
| ER-096 | R-MAIN: `Couldn't Update` | Application update fails → update-failure alert | updating / failed; transition UNKNOWN. |
| ER-097 | R-MAIN: `Update Failed (manual reinstall alert heading)` | Update recovery fails → reinstall/instructions path | update failed / manual recovery offered; transition UNKNOWN. |
| ER-098 | R-MAIN: `There was a problem installing the update.` | Installer fails → installation error | installing / failed; transition UNKNOWN. |
| ER-099 | R-MAIN: `Update Required` | Installed version too old → required-update state | outdated / update-required; transition UNKNOWN. |
| ER-100 | R-MAIN: `MacOS %1$@ doesn't support %2$@'s newest features. Here's what to do:` | Unsupported OS → OS-update guidance and extension alternative | OS unsupported; version placeholders UNKNOWN; transition UNKNOWN. |
| ER-101 | R-MAIN: `%@ will not work properly without access to your computer's Accessibility features.` | Missing accessibility grant → reduced-operation warning | permission missing / degraded; actual affected features UNKNOWN; transition UNKNOWN. |

## Cross-cutting edge cases and evidence limits

- **Section 6 resource-only machines:** every arrow in this voice/meeting/Authorship/error section is a candidate; the observed Chrome transitions remain separately confirmed in BB-003–004 and SM-003. Do not assert recording begins from opening, automatic dispatch occurs, permissions are already granted, or a retry preserves inputs. Exercise each transition with synthetic content before marking it observed.
- **Conflict: Notetaker migration.** Full embedded Notetaker workflows coexist with R-MEETING `Get the new Notetaker`, an exact longer notice instructing switching to standalone, and R-MAIN `Notetaker has moved. Download the new one %1$@`. Treat legacy versus migrated UX as mutually unresolved variants, not simultaneous requirements.
- **Conflict: snippet ceilings.** R-MAIN has 1,000 versus 5,000 content characters and 30 versus 400 name characters. Do not pick a default or assume plan mapping from these labels.
- **Conflict: Authorship storage.** R-MAIN contains one description of local encrypted storage followed by encrypted upload when the report is opened/shared, and another describing encrypted server storage. Both are product-copy claims; actual retention, synchronization, encryption, upload timing, and current branch are UNKNOWN.
- **Authorship evidence-covered input categories:** longer R-MAIN copy describes typed and deleted text, pasted website/app text, website source links, and prompts to generative-AI tools. This is a declared data model, not proof of monitoring in this installation. Recording can be document-scoped, while new-doc automation is separately described.
- **Authorship permissions:** longer R-MAIN copy says missing app access excludes unsaved/OneDrive documents and Canvas; missing clipboard access yields unknown paste source. Saving the document is offered as another route alongside granting Word access. Recovery after grants and retrospective attribution remain UNKNOWN.
- **Authorship limits:** all page limits are `%d`, including pre-limit, paused, report-truncation, and unavailable variants. Do not infer a fixed ceiling. Retaining earlier report coverage is stated in the copy; continuation after shrinking the document is UNKNOWN.
- **Duplicate vocabulary:** Start Notetaking / Start notetaker / Start taking notes; Stop Notetaker / Stop recording / Stop; Summary not available / No summary available; That did not work / That didn't work; Tracking is on / Tracking is currently on / Authorship tracking is on. Preserve as variants pending runtime surface identification; do not multiply distinct features solely from wording.
- **Independent empty versus failure states:** absent history, absent transcript, absent summary, no extracted tags, and load failure are separate candidates. No evidence establishes whether an empty result is pending, permanent, offline, permission-related, or due to server failure.
- **Destructive actions:** R-MEETING `This action cannot be undone.` accompanies meeting-deletion vocabulary; R-MAIN describes document-report deletion that stops tracking and affects only that document. Confirmation existence is evidenced, actual restoration/recovery is UNKNOWN.
- **Consent:** R-MEETING includes an agreement to ask attendees for permission and notice/auto-post settings. These are visible product requirements; they do not demonstrate compliance, automatic consent acquisition, message delivery, or that consent is recorded.
- **Timing:** only the labels support a 30-second calendar notification, one-week/tomorrow mute choices, one-hour enterprise-expiry warning, and ten-minute diagnostic video stop. Those values do not establish actual delivery timing or limits elsewhere.
- **Unverified voice implementation vocabulary (outside the four-record JSON):** previous static inspection found DictationHotkeyManager, DictationTextFieldEntrypointView, dictation.pushToTalkEnabled, dictionary/history settings types, and internal feature flags. They are intentionally excluded from normative requirements here because no REA ev_id in this evidence bundle establishes them. Additional independently cited evidence is required before promoting them to requirements.
- **Deferred test matrix:** no mic; mic denied; device unplugged; device changes during capture; start twice; stop idle; cancel during processing; silent speech; empty service result; long audio; network loss; auth expiry; duplicate retry; simultaneous meetings; overlapping calendar events; timezone/day boundary for mute; delete during recording; new note during recording; reconnect after send; regenerated summary failure; failed partial deletion; unsaved Word document; clipboard denied; page ceiling; same doc on two devices. All expected transitions UNKNOWN.

## 7. Persistence, formats and protocol requirements

| ID | Evidence-backed observation / clone consideration | Evidence | Unknown |
|---|---|---|---|
| PS-01 | Desktop preferences are a binary property list at `~/Library/Preferences/com.grammarly.ProjectLlama.plist`. The observed key/type inventory is below. | `OBS-PREF-01` | Defaults, valid enums, read/write timing, migrations, server precedence, and mapping from each UI control to keys are UNKNOWN. |
| PS-02 | The updater has a separate binary plist `~/Library/Preferences/com.grammarly.ProjectLlama.UpdateService.plist`, with `com.grammarly.ProjectLlama.UpdateService.agentID: string`. | `OBS-PREF-02` | Identifier semantics/lifecycle UNKNOWN. |
| PS-03 | App support root is `~/Library/Application Support/com.grammarly.ProjectLlama`. Its top-level entries include `Authorship`, `LocalStorage`, `Scripts`, `blockList.json`, `documentIDMap.json`, `integrationPreferences.json`, zero-byte `tokenRefreshFileLock`, updater and uninstaller bundles. | `OBS-SUPPORT-01` | JSON suffix is a filename observation; these files' contents, schema, encoding, authority, encryption, and update behavior are UNKNOWN because user data was not inspected. Lock semantics UNKNOWN. |
| PS-04 | An Authorship database exists at `Authorship/{scope}/store.db`. Schema has `entries(id INTEGER NOT NULL PRIMARY KEY, documentId TEXT NOT NULL, data BLOB NOT NULL, lastSyncedRevision INTEGER NULL)` plus `sqlite_sequence`. | `OBS-SQL-01` | BLOB encoding, document identity, sync algorithm, revision meaning, deletion/retention, and the numeric scope meaning are UNKNOWN. |
| PS-05 | General cache/storage DB exists at `LocalStorage/{scope}.db`. `entries` columns: `id INTEGER NOT NULL PRIMARY KEY`, `key TEXT NOT NULL UNIQUE`, `data TEXT NOT NULL`, `maxAgeSeconds INTEGER NOT NULL`, `maxAgeOrigin TEXT NOT NULL`, `creationDate TEXT NOT NULL`, `expirationDate TEXT NOT NULL`; plus `sqlite_sequence`. | `OBS-SQL-02`, E-SQLITE | Stored key vocabulary, date syntax, serialized value format, expiration behavior, timezone, date parsing and enforcement, other record semantics, and encryption UNKNOWN; E-SQLITE additionally confirms the key is UNIQUE and id is AUTOINCREMENT. Column names suggest expiry but do not prove execution. |
| PS-06 | `LocalStorage/{scope}_ChatAssistantHistory.db` has `entries(id INTEGER NOT NULL PRIMARY KEY, content BLOB NOT NULL)`. | `OBS-SQL-03` | History content encoding, pagination, record identity, retention, clearing, and sync UNKNOWN. |
| PS-07 | `LocalStorage/{scope}_WritingStyleData.db` has the same two-column `entries` shape. | `OBS-SQL-04` | Writing-style representation, aggregation, reset, and sync UNKNOWN. |
| PS-08 | App-related caches exist under `~/Library/Caches/` for `com.grammarly.ProjectLlama`, `.UpdateService`, `.Shepherd`, `com.grammarly.GRLlamaOnboarding`, and `com.grammarly.web-client`. WebKit roots exist for ProjectLlama, GRLlamaOnboarding, and web-client. | `OBS-PATH-02`, `OBS-PATH-04` | Cache contents, web document formats, quota, eviction and offline behavior UNKNOWN. |
| PS-09 | `~/Library/HTTPStorages/` contains ProjectLlama, updater and Shepherd stores, and ProjectLlama/onboarding `.binarycookies` filenames. | `OBS-PATH-03` | Cookies were not opened. Authentication persistence, cookie schema, session expiry and HTTP cache semantics UNKNOWN. Filename alone is insufficient to specify a cookie contract. |
| PS-10 | Local installation includes an updater and uninstaller inside app support. Packaged helpers are also evidenced in earlier REA records. | `OBS-SUPPORT-01`; REA `ev_ab0dc338cae9ea1e97ef094b22477db7e925ed728fd7e576e63d248b4130a6aa`, `ev_ea0099d887d85eacadb3ed72c5701aa46863dd41629ffd37d3454c08f9689626` | Launch scheduling, upgrade/rollback, cleanup completeness and uninstall deletion rules UNKNOWN. |

The inventory in PS-01 is factual metadata, not proof that every key remains active. Preference values were deliberately not retained. All rows cite `OBS-PREF-01`.

| Group | Exact observed keys and types |
|---|---|
| Language and account mode | `preferredVariant: string`; `userPreferences.Dialect: string`; `userPreferences.isDialectLocked: boolean`; `userPreferences.cheetahSettings: string`; `userPreferences.lastEffectiveAppMode: string`; `cachedGrammarlyModeEnabled: boolean`; `cachedSuperhumanGoHomeEnabled: boolean`; `authorizedUserType: string` |
| Launcher and writing feedback | `g2LauncherNormalizedVerticalPosition: real`; `g2ShowGlobalAssistantNotchWhileWriting: boolean`; `g2GlobalAssistantNotchOnboardingState: string`; `g2LockedSignalingVbarsSnoozed: boolean`; `g2UnlockedVbars: array`; `g2UnlockedVbarsLastResetTime: date`; `YellowUnderlinesDismissedAt: date`; `quickApplyNumberOfHotkeyUses: integer`; `touchTypistLastAcceptDate: date`; `isTouchTypistDisabledByDefault: boolean`; `didDisableSystemSpellChecking: boolean` |
| Authorship, meeting and insights | `authorship.isAvailable: boolean`; `aviNotetaker.isGoogleCalendarLinked: boolean`; `personalizedInsights.onboardingState: string` |
| Onboarding and upsell flags | `isFirstLaunch: boolean`; `wasOnboardingShown: boolean`; `wasGButtonOnboardingShown: boolean`; `wasSettingsMenuWithScoreShown: boolean`; `wasFreePremiumUpsellShown: boolean`; `enableBrowserExtensionPopupCounter: integer` |
| Authentication/session metadata | `authFlow: string`; `wasLoggedIn: boolean`; `wasLoginButtonClicked: boolean`; `recentlyLoggedInUserIds: array`; `user: string`; `lastAuthTokenRenewalDate: date`; `lastOAuth2TokenRefreshTime: date`; `lastSuccessfulAuthorizationRefreshDate: date`; `refreshAlreadyPerformedForSession: boolean`; `userDismissedTimeoutWarning: boolean`; `wasSessionTimeoutsAlertShown: boolean` |
| Experiment/config synchronization | `allExperimentGroups: array`; `treatments.cachedTreatments: array`; `treatments.lastUpdateDate: date`; `lastExperimentsFetchDate: date`; `lastCheetahSettingsCheckDate: date`; `lastDialectCheckDate: date`; `uphookconfiguration.fallback: string` |
| Updates and lifecycle | `SUAutomaticallyUpdate: boolean`; `SUEnableAutomaticChecks: boolean`; `SUFeedURL: string`; `SUHasLaunchedBefore: boolean`; `SULastCheckTime: date`; `SUScheduledCheckInterval: real`; `SUSendProfileInfo: boolean`; `SUUpdateGroupIdentifier: integer`; `SUUpdateRelaunchingMarker: boolean`; `updateInfo: string`; `installerInfo: string`; `restartLlamaAfterCrash: boolean`; `uninstallerShouldPerformCleanupTasks: boolean`; `lastSupportedOSVersion: string`; `NSApplicationCrashOnExceptions: boolean`; `heartbeatEnabled: boolean`; `gnar.nextPingDate: date` |
| Installation/UI metadata | `NSStatusItem Preferred Position Item-0: real`; `com.grammarly.containerId: string`; `referralContainerId: string`; `downloadedWithBundleIdentifier: string`; `downloadedWithBundleName: string` |

## File formats and OS entry contracts

| ID | Observation / requirement boundary | Evidence | UNKNOWN |
|---|---|---|---|
| FM-01 | Local settings use a binary Apple property list. Public bundle Info.plist parses as a property list; version is Desktop `1.203.0` / build `1.203.0.0`, bundle `com.grammarly.ProjectLlama`, minimum macOS `11.0`, `LSUIElement=true`. | `OBS-PREF-01`, `OBS-BUNDLE-01`; REA `ev_8b129f2388c6887b517012be4cc4f535a654c204a31cb6fb2ee50d8811f4c5e3` | This does not prove all features work on the minimum OS. |
| FM-02 | The four storage files in PS-04–07 open using SQLite in immutable read-only mode and expose the described schemas. | `OBS-SQL-01`–`04` | BLOB file formats, serialized application records, exports/imports, backup semantics, encryption UNKNOWN. Immutable schema observation can omit uncheckpointed WAL changes. |
| FM-03 | Packaged `GRLlamaCore.framework/Versions/A/Resources/IntegrationOptions.json` is a JSON-like configuration. Strict Python JSON parsing rejects the installed file at line 205, column 5. | `OBS-CONFIG-01` | Grammarly parser/normalization behavior UNKNOWN; the collector failure is **not an observed app error**. Do not require the clone to reproduce that parse failure. |
| FM-04 | `IntegrationOptionsKeywordBlocklist.json` is JSON-shaped shipped policy data. M-STORE records strict parse result, key vocabulary and hash. | `OBS-CONFIG-02` | Runtime loader, reload/hot-update rules UNKNOWN. |
| FM-05 | Main Info.plist has no `CFBundleDocumentTypes` declaration. | `OBS-BUNDLE-01` | Import/export/document support is UNKNOWN, not established absent. A `.dmg` URL literal is a distribution reference, not document import evidence. |
| FM-06 | Handoff activity type `com.grammarly.keyboard.document.handoff` is declared. | `OBS-BUNDLE-01`, existing Info.plist REA evidence | Handoff userInfo fields, accepted document schema, receiving screen, eligibility and errors UNKNOWN. |

## Integration policy candidates from shipped data

These are requirements to investigate, supported by installed configuration. They are not live-verified interaction guarantees. Avoid reusing the packaged policy data wholesale; implement independently and verify representative behavior.

| ID | Inputs and shipped policy behavior | Evidence | Unconfirmed behavior |
|---|---|---|---|
| IN-01 | Policy schema selects host/field contexts using `BundleIdentifier`, `Domain`, `Path`, `ElementName`, with `IsEnabled`, `CheckAncestors`, `IgnoreKeywordBlocklist`, `RequiresBrowserExtension`, `AllowInTextFields`, `AllowInComboBoxes`, `IsMailBody`, `Tags`, and position `DefaultPosition`, `Corner`, `Offset`, `ForbiddenCorners`. | `OBS-CONFIG-01`, exact config path above | Match engine, matching order, overlap precedence, inheritance and malformed-rule behavior UNKNOWN. |
| IN-02 | SDK-active/available marker is configured disabled with ancestor checking to avoid duplicate integration. | `OBS-CONFIG-01`, lines 2–7 | Live marker detection, spelling of accessibility/DOM attribute carrying it, and fallback UNKNOWN. |
| IN-03 | `grammarly-desktop-enable` marker is configured enabled and bypasses keyword blocklist; `grammarly-desktop-disable` marker is configured disabled with ancestor checking. | `OBS-CONFIG-01`, lines 8–19 | Marker propagation, precedence relative to explicit app block list, runtime correctness UNKNOWN. |
| IN-04 | Google Translate has a combo-box allow rule. Google Sheets has domain/path/editor selector with text-field/combo-box enabling and default-position metadata. | `OBS-CONFIG-01`, lines 20–39 | Current app compatibility and actual placement UNKNOWN. |
| IN-05 | Keyword policy lists email addressing/navigation fields, personal-information/search fields, and account/login fields in multiple languages. Its keys include `ElementName`, `Language`, `Notes`. | `OBS-CONFIG-02`, lines 2–106 | This is not proof of suppression in password or other fields. Accessible names, locales, secret-field exclusion and live fallback behavior UNKNOWN. |

## Network/protocol boundaries

All destinations below are **literal references**, not captured requests. No server method, payload, header, authentication mechanism, retry timing, protocol version, compression or message framing has been confirmed. Proprietary backend compatibility is therefore UNKNOWN. A clone needs its own analysis/generation service contract until separately specified.

| ID | Evidence-backed boundary | Evidence | UNKNOWN |
|---|---|---|---|
| NP-01 | Main bundle registers URL schemes `grammarly.mac-extension`, `grammarly`, `superhuman.mac-extension.all`. | `OBS-BUNDLE-01`; REA Info.plist evidence above | URL host/path/query syntax, callbacks, validation, permitted actions, duplicate invocation and invalid-input errors UNKNOWN. Do not invent an OAuth callback schema from registration alone. |
| NP-02 | A demangled GRNetwork symbol is `(extension in GRNetwork):Network.NWProtocolTLS.Options.setVerifier(_: GRNetwork.SecProtocolVerifier, on: __C.OS_dispatch_queue) -> ()`. | REA `ev_c36c55bdf07f0b560edc828e0821f8952070de02776b312782ba3f803ef8145d` | TLS implementation capability does not prove active traffic, pinning or policy. Versions, trust validation and error presentation UNKNOWN. |
| NP-03 | ProjectLlamaContent contains HTTPS authentication, applet, update and support literals listed below. | `OBS-URL-01` | Which are used, environment selection, full endpoint set, methods/payload/auth/retries UNKNOWN. |
| NP-04 | GRServices contains incomplete HTTPS service prefixes listed below. | `OBS-URL-04` | Domain suffix concatenation, complete hostnames, resource paths and transport usage UNKNOWN. |
| NP-05 | No valid HTTP(S)/WS(S) URL literals were retained from `__cstring` sections of inspected GRNetwork and GRCoreApi binaries. | `OBS-URL-02`, `OBS-URL-03` | This limited string observation cannot establish absence of HTTP/WebSocket or other network use. HTTP version, WebSocket handshakes and frame contracts remain UNKNOWN. |
| NP-06 | HTTP cache / `.binarycookies` paths and WebKit storage coexist with web content and native networking evidence. | PS-08–09; REA `ev_6fbdec0f1ba6308c78ecc080d40b70dd7d4ca6c41027e54cb06901cb5410ca63` identifies `Grammarly Desktop Web Content.xpc` | Process-to-process transport, web bridge API, ports, origin trust model, requests, serialization and error behavior UNKNOWN. |
| NP-07 | A `http://localhost` literal appears in ProjectLlamaContent. | `OBS-URL-01`, arm64 file offset `0x2e850e0` | No local listener is proven; port, route, binding, clients, auth and lifecycle UNKNOWN. |

Selected literal citations follow. Offsets are **whole universal-file offsets for arm64 strings**, not virtual addresses. Full sanitized x86_64/arm64 inventory is in `OBS-URL-01` and `OBS-URL-04`; there are additional support, test and preproduction URL literals there. None was requested or contacted.

ProjectLlamaContent file: `/Applications/Grammarly Desktop.app/Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/ProjectLlamaContent`, SHA-256 `c80fff86c143971e4b5874afa714ed0fb38f8cd22ba5ae2e7266de41c61276e1`.

| Exact literal | File offset | Classification |
|---|---|---|
| `https://auth.grammarly.com` | `0x2ec10c0` | Authentication-named destination candidate; protocol contract UNKNOWN |
| `https://download-mac.grammarly.com` | `0x2ebe950` | Download-named destination candidate |
| `https://download-mac.superhuman.com/hub/SuperhumanPlatform.dmg` | `0x2e4fc40` | Distribution file reference; download behavior UNKNOWN |
| `https://www.grammarly.com/service/verify-extension` | `0x2e5a200` | Extension verification-named resource |
| `https://www.grammarly.com/browser/` | `0x2e5a240` | Browser resource |
| `https://applet-bundles-static.grammarly.com` | `0x2e85020` | Applet bundle-named host |
| `https://applet-bundles.grammarly.com` | `0x2e85050` | Applet bundle-named host |
| `https://applet-bundles-static.grammarly.net` | `0x2e85080` | Applet bundle-named host |
| `https://applet-bundles.grammarly.net` | `0x2e850b0` | Applet bundle-named host |
| `https://applet-bundles.grammarly.net/applets/assistant` | `0x2e85820` | Assistant resource |
| `https://skills-static.prod-partner-platform.grammarlyaws.com` | `0x2e85490` | Skills resource-named host |
| `https://www.grammarly.com/privacy-policy` | `0x2eca118` | Privacy link |
| `https://grammarly.com/suspended-service-russia-belarus` | `0x2e5a270` | Restricted-service help reference; behavior UNKNOWN |
| `https://gateway.zscaler.net` | `0x2e85290` | Literal may be a compatibility/detection target, not an app backend; use UNKNOWN |
| `http://localhost` | `0x2e850e0` | Localhost reference; listener UNKNOWN |

GRServices file: `/Applications/Grammarly Desktop.app/Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Frameworks/GRServices.framework/Versions/A/GRServices`, SHA-256 `57be9e64ee6b1d15b680b7ff84c00c8a04bb3991b1c21634c2782a8663b9522e`.

| Exact incomplete literal | File offset |
|---|---|
| `https://gateway.` | `0x1454c0` |
| `https://account.` | `0x145500` |
| `https://settings.` | `0x145520` |
| `https://redirect.` | `0x145540` |
| `https://authorship.` | `0x1456a0` |
| `https://apigw.cplane.` | `0x1456e0` |
| `https://mac-extension.` | `0x145740` |
| `https://support.` | `0x145820` |

## Error and lifecycle unknowns requiring observation

| ID | Requirement gap | Evidence boundary |
|---|---|---|
| PS-11 | Corrupt/missing preferences, locked/read-only/full disk, schema upgrade/downgrade, DB corruption, partial write, account switch, multi-instance races and crash recovery behavior are UNKNOWN. | Schema/filename-only evidence `OBS-PREF-*`, `OBS-SQL-*`, `OBS-SUPPORT-01` does not exercise these states. |
| NP-08 | Offline, DNS failure, proxy/auth proxy, revoked login, expired sessions, TLS failure, timeouts, rate limits, malformed responses, server 4xx/5xx and reauthorization state machines are UNKNOWN. | R-MAIN labels `Can’t connect to %@` and `Please check your internet connection.`; no request capture or failure injection. Preference names `wasSessionTimeoutsAlertShown`, `userDismissedTimeoutWarning` are hints, not executed errors. |
| FM-07 | User-facing import/export formats, Markdown/HTML/plain text/RTF handling, attachments, document-size limits, clipboard formats and Unicode offset conventions are UNKNOWN from this persistence scope. | E-IDENT has no declared document types; PS/FM metadata does not determine document formats. BB-004 observes one textarea edit, not a clipboard/import/export format. |

## 8. Additional discovered surfaces and platform boundaries

| ID | Candidate requirement / input-output boundary | Confirmation and UNKNOWN details | Evidence |
|---|---|---|---|
| SUP-001 | Engagement review can be a distinct writing outcome alongside correctness, clarity, delivery and style. | RESOURCE-CONFIRMED category label only; model, suggestions and current UI placement UNKNOWN. | R-ALERT `outcome.title.engagement` = `Engagement` |
| SUP-002 | Compact originality cards can name external sources and show a match percentage; AI-pattern cards can present a resemblance result. | RESOURCE-CONFIRMED only; percentage denominator, thresholds, false positives, source corpus and combined findings UNKNOWN. | R-ALERT `plagiarism.card.headerTitle`, `compactCard.plagiarism.externalSource`, `aiDetector.card.title` |
| SUP-003 | Inclusive-language assistance has a compact-card entry. | RESOURCE-CONFIRMED label only; eligible terms, language coverage and transformations UNKNOWN. | R-ALERT `compactCard.inclusivity.title` |
| SUP-004 | Spoken accessibility vocabulary distinguishes punctuation and whitespace, including zero-width/non-breaking spaces and mathematical/currency symbols. | RESOURCE-CONFIRMED vocabulary; text-to-speech use, focus announcements and mapping to edits UNKNOWN. Do not infer dictation grammar from spoken labels. | R-CORE keys `zero width space (spoken whitespace name)`, `non-breaking space (spoken whitespace name)`, `summation symbol (spoken punctuation name)` |
| SUP-005 | A cannot-check-text recovery surface can offer saving work, quitting/reopening a named host, or a support article. | RESOURCE-CONFIRMED; error cause, host targeting and successful recovery UNKNOWN. | R-CORE `Can't check your text`, `Quit %@?`, `Reopen %@`, `Open article` |
| SUP-006 | Onboarding/web-content connection and generic failures offer retry, cancellation and support. | RESOURCE-CONFIRMED in two XPC resources; actual display conditions, retry timing and state retention UNKNOWN. | R-ONBOARD and R-WEB `Can’t connect to Grammarly`, `Try Again`, `Cancel`, `Contact Support` |
| SUP-007 | Meeting summaries distinguish timeout, missing recording-session data and load failure. | RESOURCE-CONFIRMED; timeout duration, retry safety, automatic retries and old summary preservation UNKNOWN. | R-NOTEFEATURE keys `Summary generation timed out. Please try again later.`, `Unable to load summary. Recording session data is missing.`, `Failed to load summary.` |
| SUP-008 | An unnamed meeting can use a generic meeting title, and voice UI has start/stop entry labels. | RESOURCE-CONFIRMED; title-generation and session identity UNKNOWN. | R-NOTEFEATURE `Meeting (unnamed recording title)`; R-AVI `Voice dictation`, `Stop dictating`, `Start Notetaking` |
| SUP-009 | Audio models have a multilingual choice label. | RESOURCE-CONFIRMED only; no supported transcription-language list or automatic language detection has been established. | R-MODELS `Multilingual` |
| SUP-010 | Controls expose accessibility names, roles, actions and boundary enabled states, rather than relying on pixels alone. | OBSERVED AX trees and Chrome buttons; complete keyboard traversal, screen-reader experience, focus restoration and shortcut collision rules UNKNOWN. | O-NATIVE-WELCOME, O-NATIVE-BLOCK, O-CHROME `Previous suggestion`, `Next suggestion` |
| SUP-011 | Native integration may use accessibility read/write/notifications and synthetic events. | Static capabilities only; per-host mechanism, permission grant, protected-field exclusions, event selection and secure-input behavior UNKNOWN. | E-AX `AXIsProcessTrusted`, `AXUIElementSetAttributeValue`, `CGEventPostToPid`; E-DEMANGLE `focusedUIElement` |
| SUP-012 | App metadata requests microphone/audio capture and Apple Events automation and declares application/keychain groups. | RESOURCE-CONFIRMED permissions/entitlements; consent state and actual collection/automation UNKNOWN. No permission changes were performed. | E-IDENT `NSMicrophoneUsageDescription`, `NSAudioCaptureUsageDescription`, `NSAppleEventsUsageDescription`; E-SIGN entitlement names |
| SUP-013 | Updater UI exposes install-now/later/skip/remind/permission/progress surfaces. | Packaged selectors are confirmed; runtime states, native controls and installed update effects UNKNOWN. System-template helper menus are excluded from functional parity. | E-IB `installNow:`, `installLater:`, `doNotInstall:`, `installUpdate:`, `remindMeLater:`, `skipThisVersion:`, `finishPrompt:` |
| NP-09 | Packaged in-process JavaScript/native messaging has named bridge surfaces and a declared origin string. | Static protocol entry points only; payload types, envelope, ordering, errors, trust boundary, lifecycle, serialization and runtime use UNKNOWN. This is not an HTTP/WebSocket contract. | E-BRIDGE exact source lines 6/31/37/38: `gos_message_bridge.postMessage`, `grammarlyMessagingBridge`, `grammarlyMessageBridge`, `grammarly-message-handler://grammarly`. Prior REA `ev_b130351875bb3ef03ffd31e7708c8dc03629f6bf5f66f1eec9ced57df8dab556` inventories the resource; it does not itself establish each literal. |
| NP-10 | Application-local service boundaries include packaged web-content and onboarding XPC services. | XPC packaging declarations confirmed; message names, interfaces, encoders, validation, reconnection and actual invocation UNKNOWN. | E-INVENTORY; REA `ev_6fbdec0f1ba6308c78ecc080d40b70dd7d4ca6c41027e54cb06901cb5410ca63`, `XPCService.ServiceType=Application`; `com.grammarly.DesktopWebContent` |

## 9. Input/output, edge-case and acceptance matrix

These cases define a finite validation boundary. “UNKNOWN expected behavior” means the independent implementation may choose a documented behavior, but must not claim that choice reproduces the original. Tests below are specifications, not source code or an implementation of Grammarly.

| Test ID | Input / setup | Expected original behavior and scope | Citation |
|---|---|---|---|
| T-001 | English fixture in a compatible Chrome textarea | The five proposals in section 2 were observed. Exact rerun equivalence/server determinism UNKNOWN. | BB-001–004 / O-CHROME |
| T-002 | Accept only the tested subject–verb proposal | Tested occurrence changes `I has` to `I have`; visible pending count decreases by one. Other contexts and count races UNKNOWN. | BB-004 / O-CHROME |
| T-003 | Move between suggestions at first/last boundaries | Navigation exists; first Previous and last Next were disabled in the observed sequence. Wraparound via keyboard UNKNOWN. | BB-003 / O-CHROME |
| T-004 | Empty text, one/two/three words; 29/30 words; 199/200 style-sample words | UI resources describe 3/30/200-word conditions in different features. Actual boundary enforcement, punctuation and tokenization UNKNOWN. | WR-020, WR-023, WR-049; ER-078–080 |
| T-005 | Unicode astral characters, combining marks, emoji, zero-width/no-break spaces, RTL and mixed languages | Expected ranges, segmentation, normalization, direction and rendering UNKNOWN. Spoken vocabulary is not a Unicode wire-offset specification. | SUP-004; E-AX; no fixture captured |
| T-006 | Edit/select/paste while results are pending; overlapping corrections; delete origin field | Stale-result cancellation, rebasing, patch atomicity and orphan-result behavior UNKNOWN. | BB-004 exercised only one stable edit; WR-005–018 |
| T-007 | Accept/dismiss/bundle/undo/copy with rich text and multiple paragraphs | One plain-text acceptance observed; all other mutation scopes, clipboard MIME types, formatting and undo grouping UNKNOWN. | BB-004–005; WR-010, WR-037–043; FM-07 |
| T-008 | Blocked app/site, admin allow versus user block, subdomain, ancestor opt-in/out and SDK active marker | Exclusion table observed; match precedence, policy reload, wildcard/subdomain and secret-field safety behavior UNKNOWN. | BB-007; IN-01–05; SC-018–021 |
| T-009 | App restart, crash, account switch, different device, multiple instances, upgraded/downgraded schema | Defaults, persisted choices, migration, recovery and sync behavior UNKNOWN. Observed keys/schemas are not lifecycle guarantees. | PS-01–11; AU requirements |
| T-010 | Missing/denied/revoked accessibility, automation, microphone, system audio or clipboard access | Permission/error labels exist; grant/revocation transitions, degraded subset and retrospective recovery UNKNOWN. | SUP-011–012; R-MAIN `Allow clipboard access`; R-VOICE `No microphone permission` |
| T-011 | Offline, DNS/proxy/TLS failure, rate limit, expired login, malformed reply or 4xx/5xx response | UI contains error families; transport-to-error mapping, timeout, retry, backoff, queueing and fallback UNKNOWN. No service failure was injected. | ER-001–101; NP-08 |
| T-012 | Prompt empty/too long, oversized or unreadable attachment, context overflow, missing insertion target | Error labels discovered; exact size limits, supported files, incremental uploads and output retention UNKNOWN. | AI-019–026, AI-029–038; ER-050–056 |
| T-013 | Snippet name/body missing, duplicate or near either packaged maximum | Validation labels exist; active 30/400 name and 1,000/5,000 body branches and counting semantics UNKNOWN. | WR-073–078; ER-083–087 |
| T-014 | Dictation: no device, start twice, stop idle, silence, cancel while processing, device unplug, interrupted stream | Specific error labels exist; all actual state transitions, retained audio/text and retry safety UNKNOWN. | VO-001–014; ER-001–018 |
| T-015 | Meetings: overlapping events, start during recording, stop/resume, timezone/day boundary, absent artifacts, partial sharing failure | Candidate controls and failures discovered; calendar scheduling, exclusivity, resume identity and dispatch behavior UNKNOWN. | NT-001–072; ER-019–036 |
| T-016 | Authorship: unsaved doc, clipboard denied, page ceiling, edited past activity, delete while syncing | Source classification and limits are product-copy claims; tracking coverage, data retention and deletion completeness UNKNOWN. | AU-001–026; ER-088 |
| T-017 | Score/tone/originality on factual/incorrect/AI/human material | These features have resource labels; accuracy, calibration, corpus, guarantee and real scoring functions UNKNOWN. No quality benchmark performed. | WR-021–029, WR-056–063; SUP-001–003 |
| T-018 | Go switch, standalone Notetaker migration, trial/quota reset, organization/country change | Alternate surfaces exist; entitlement mapping, migration, automatic changes, prices and actual resets UNKNOWN. No mode/plan/account changes performed. | SC/AI/NT requirements; ER-045, ER-071–077 |
| T-019 | Corrupt settings/database, full disk, read-only or locked store, partial write and unavailable encrypted storage | Persistence failure labels and schemas exist; write atomicity, repair, eviction and fallback UNKNOWN. No corruption/failure injection performed. | PS-11; AI-015–016; ER-055–056 |
| T-020 | Diagnostic report cancelled, invalid, logged out, recording reaches cap, upload fails | UI distinguishes diagnostics from dictation; 10-minute cap appears in diagnostic-copy only. Actual capture/upload/retention UNKNOWN. No report was sent. | ER-089–095; SC-056–064 |

## 10. Clean-room implementation boundary and unresolved contracts

| Requirement | Rule / unresolved contract | Citation |
|---|---|---|
| CR-001 | Independently author code, UI language, branding, layouts and assets. Do not transplant the inspected bundles, localization catalogs, nibs, scripts, fonts, images, public signing key, identifiers or vendor service configuration into a clone. Original facts remain evidence only. | U-REQUEST; E-INVENTORY |
| CR-002 | An independently designed backend contract is a new design choice, not a recovered protocol. The service's methods, payloads, authentication/token exchange, HTTP/WebSocket version, binary codecs, streaming frames, error codes, compression, ordering, rate limits and retries are UNKNOWN. | NP-01–10; no captured request |
| CR-003 | Use an independently chosen storage namespace/schema and signing identity unless separately implementing a specifically verified interoperability format. Listed vendor keys/paths are descriptive evidence, not required identities or permission grants. | U-REQUEST; PS/FM requirements; E-SIGN |
| CR-004 | Grammar, rewriting, translation, tone, originality detection, style learning, speech and summarization algorithms must be independently implemented or sourced. No algorithm/model recovered; only the finite correction fixture is observed. | U-REQUEST; BB-001–004; WR/AI/VO/NT requirements |
| CR-005 | Resource-only state candidates are not executable parity acceptance criteria until confirmed. Keep UNKNOWNs explicit rather than silently replacing them with plausible behavior. | U-REQUEST; source-status rules in section 1 |

Open contract groups: complete native-versus-extension attribution; every mode/tier/language/screen; complete UI geometry and keyboard focus; all unobserved transitions; supported host/editor/version matrix; precise edit spans and rich-text semantics; factory defaults and persistence timing; BLOB record serialization/encryption; import/export/clipboard/attachment formats; service requests and authentication; cross-device sync/deletion; failure/recovery/backoff; limits and quotas; model quality and performance. All remain UNKNOWN beyond the explicitly cited facts.

## 11. Study limits and coverage reconciliation

- **REA used directly:** imported existing evidence; decoded recognized UI archive metadata; observed two native windows; attempted a declared native tab action; parsed seven additional UI string resources; inspected SQLite schema with no rows. Existing evidence supplied executable metadata, signing declarations, framework imports/exports, primary resources and previous native-bridge names.
- **Runtime behavior reused:** earlier Computer Use observations established the Chrome fixture and settings state. The Chrome fixture is not represented as an REA request capture or as proof of Desktop-only behavior.
- **Native action limit:** REA returned AXError -25205 for Customization-tab press. This does not prove that normal clicking fails. No permission/host configuration was changed to bypass it.
- **Native deep providers unavailable:** REA reported Ghidra not configured, Hopper missing and IDA not configured. No decompilation was performed for this spec and no software was installed. Function bodies and call paths are UNKNOWN; declarations/symbols alone do not establish behavior.
- **Protocol capture limit:** no retained HAR/SAZ/PCAP or accessible existing Chrome DevTools endpoint was available in this study. The inspected Chrome profile had no `DevToolsActivePort` file at the checked path. No browser was restarted, interception certificate installed or traffic decrypted. This bounded observation does not establish that capture is impossible or that a protocol is absent.
- **Persistence limit:** metadata and schema only; no preference values, account records, personal notes, document content, cookie/Keychain values or database rows were retained. REA's private-copy inspection does not establish atomic acquisition of a live DB/WAL pair.
- **Resource coverage:** primary English resources and listed supplementary English resources were examined. Other locale copies, dynamic remote UI, updated applets, alternate accounts, hidden experiments and every server response were not exhausted. Counts of labels are not counts of features. Main-catalog leftover-label groups are explicitly unresolved below the feature table.
- **Framework/template limit:** generic menus inside helper-app nibs are not automatically user-visible product features. The packaged updater actions establish selectors, not installed-update behavior. Platform/provider errors are never promoted to app error requirements.
- **Clean-room constraint:** this artifact contains paraphrased behavioral descriptions plus minimal factual locators; no implementation code or assets.


## 12. Sanitized observation ledger

The following metadata-only ledger resolves OBS-* citations. No raw source code, assets, private records or values are present. A persistent supporting JSON observation file is available at `/Users/alex/.codex/visualizations/2026/10/23/01a16888-9c42-7603-9c37-09f6f2491ed8/grammarly-clone-observations.json`, SHA-256 `8994b934c0da213cd1257f9e42de5fbfbf4c99f76eb9ecd3ee00b4b3774f1e84`. The implementer needs only this specification; the JSON is for evidence audit.

| ID | Source | Method | Observation SHA-256 |
|---|---|---|---|
| OBS-PREF-01 | `~/Library/Preferences/com.grammarly.ProjectLlama.plist` | plistlib; top-level key names and value types only; no values retained | `2ad8aba782b0393b97822d02a8d404d69e6842b4517b37a2d91a8dba7ea0b83f` |
| OBS-PREF-02 | `~/Library/Preferences/com.grammarly.ProjectLlama.UpdateService.plist` | plistlib; top-level key names and value types only; no values retained | `e2a575b67e08880108becce298489ab1d3ef06da5f04574c8a6a312bd94be595` |
| OBS-PATH-01 | `~/Library/Application Support` | directory-entry names and types only; cookies unopened | `072e03797799aac0d7687e663306ea84ab5e86ac68aae4bf2eb5b3cdcd1f8cf3` |
| OBS-PATH-02 | `~/Library/Caches` | directory-entry names and types only; cookies unopened | `7d6f70f3705c02fdceb7948c6f1da3f71298c2183f6e57c81d7bdf6f413a6402` |
| OBS-PATH-03 | `~/Library/HTTPStorages` | directory-entry names and types only; cookies unopened | `da9f2e8722a60c687e509873dc1a73962a06b6941d09ea21a9210cfa820a2472` |
| OBS-PATH-04 | `~/Library/WebKit` | directory-entry names and types only; cookies unopened | `7b9e29ae320d62ba9d6624da979358199df3d667c6b42c8c52a765cf705cf62f` |
| OBS-SUPPORT-01 | `~/Library/Application Support/com.grammarly.ProjectLlama` | read-only filesystem names, types, and byte lengths; user data files unopened | `4e7ee9794c71510d23b2009ce87a4412fff7498a0397a84546ce4bad673b7912` |
| OBS-SQL-01 | `~/Library/Application Support/com.grammarly.ProjectLlama/Authorship/{scope}/store.db` | sqlite read-only immutable; sqlite_master table names and PRAGMA table_info only; no rows/default values | `713684240eb51e217f667ff2f7ae656a0264ea369390a696943883cb0bb8608b` |
| OBS-SQL-02 | `~/Library/Application Support/com.grammarly.ProjectLlama/LocalStorage/{scope}.db` | sqlite read-only immutable; sqlite_master table names and PRAGMA table_info only; no rows/default values | `1c87a7cabdeda072e1b2afbcfafa473c8d94af2dd93c3fdcda3f39b28e189807` |
| OBS-SQL-03 | `~/Library/Application Support/com.grammarly.ProjectLlama/LocalStorage/{scope}_ChatAssistantHistory.db` | sqlite read-only immutable; sqlite_master table names and PRAGMA table_info only; no rows/default values | `91a03b5f57ba85119f16da0c73af5aa17a9cd65fca2579bc97cc888e65e09843` |
| OBS-SQL-04 | `~/Library/Application Support/com.grammarly.ProjectLlama/LocalStorage/{scope}_WritingStyleData.db` | sqlite read-only immutable; sqlite_master table names and PRAGMA table_info only; no rows/default values | `6e63e19c8e1a8131181f1418b26da825b21dec1b4aec34752fed70ef2847ad19` |
| OBS-BUNDLE-01 | `/Applications/Grammarly Desktop.app/Contents/Info.plist` | plistlib of shipped public bundle metadata; whitelisted fields only | `a6d5724e33de7fc778d028596ba507a06798eaf585f5902b4be1f7a2c43f9a48` |
| OBS-CONFIG-01 | `/Applications/Grammarly Desktop.app/Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Frameworks/GRLlamaCore.framework/Versions/A/Resources/IntegrationOptions.json` | shipped config key names, strict JSON parse test, and paraphrased small policy examples; no source/assets copied | `d9a1d238f3c791ec2fb179f5ae3b993ec94a814097b95d7e8cadd170112c85f2` |
| OBS-CONFIG-02 | `/Applications/Grammarly Desktop.app/Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Frameworks/GRLlamaCore.framework/Versions/A/Resources/IntegrationOptionsKeywordBlocklist.json` | shipped config key names, strict JSON parse test, and paraphrased small policy examples; no source/assets copied | `886a610b2b9c9add1b47ec8f9c94fde300ee159f64614ed178dbb998cb4dc09f` |
| OBS-URL-01 | `/Applications/Grammarly Desktop.app/Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/ProjectLlamaContent` | read-only fat Mach-O section metadata parser; ASCII URL-shaped NUL-terminated __cstring literals; excludes query strings, userinfo, statsig console project path; no disassembly/decompilation | `271af5185c4858742004bb13bbe0b7d25a2775090e25f871d32fa4bd2136dd49` |
| OBS-URL-02 | `/Applications/Grammarly Desktop.app/Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Frameworks/GRNetwork.framework/Versions/A/GRNetwork` | read-only fat Mach-O section metadata parser; ASCII URL-shaped NUL-terminated __cstring literals; excludes query strings, userinfo, statsig console project path; no disassembly/decompilation | `7f68eabb047cdfcab834bd35400ee2e4f914c8f1e4608d6376641881e9300a58` |
| OBS-URL-03 | `/Applications/Grammarly Desktop.app/Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Frameworks/GRCoreApi.framework/Versions/A/GRCoreApi` | read-only fat Mach-O section metadata parser; ASCII URL-shaped NUL-terminated __cstring literals; excludes query strings, userinfo, statsig console project path; no disassembly/decompilation | `15d9224367fc5be0804f0c2464f462f322620645afd24ce35f9c44ff121d5641` |
| OBS-URL-04 | `/Applications/Grammarly Desktop.app/Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Frameworks/GRServices.framework/Versions/A/GRServices` | read-only fat Mach-O section metadata parser; ASCII URL-shaped NUL-terminated __cstring literals; excludes query strings, userinfo, statsig console project path; no disassembly/decompilation | `ca90cac5768b5905fb6efb4a035558e325c037a0f1457d316554a70279b7c60c` |
