# Changelog

All notable changes to this project will be documented in this file.

## [0.8.1](https://github.com/jorisnoo/Harvie/releases/tag/v0.8.1) (2026-07-03)

### Features

- show override count in client overrides header ([91b7e89](https://github.com/jorisnoo/Harvie/commit/91b7e89bd63fe255a73901ab9b1fdd63e8518f3c))
- **toolbar:** combine document switching with filters ([c923c86](https://github.com/jorisnoo/Harvie/commit/c923c86d6107f85cc2494ba584774263f4532d9f))
- **invoices:** support shift-click state selection ([84952bc](https://github.com/jorisnoo/Harvie/commit/84952bc3c314ba0e9688f8c7d77eee2523dde2e1))

### Bug Fixes

- **invoices:** stabilize state filter list layout ([62a0ffe](https://github.com/jorisnoo/Harvie/commit/62a0ffeb5f5406497a732d53af54353d1821d743))

### Tests

- update invoice state tests ([835999f](https://github.com/jorisnoo/Harvie/commit/835999f8061e651d354662e42738699ba0467c60))

### Styles

- **invoices:** use primary color for selected drafts ([1319620](https://github.com/jorisnoo/Harvie/commit/13196202b636f3bf59058d2d8b60784137aa66ee))
## [0.8.0](https://github.com/jorisnoo/Harvie/releases/tag/v0.8.0) (2026-07-03)

### Features

- enable per-client override ([14faaa5](https://github.com/jorisnoo/Harvie/commit/14faaa59f3865a8631112e34d26ff6bd986b870a))
- **invoices:** multi-state filtering via chip bar ([53f4597](https://github.com/jorisnoo/Harvie/commit/53f459743c5358dbf9646bd0c687a2cba15270cb))
- **settings:** add Tab navigation between creditor info fields ([b67b20d](https://github.com/jorisnoo/Harvie/commit/b67b20dbfadff370fd2a1dd45a216804f83134b4))
- **settings:** add API key link when no Harvest token present ([fcb0dd8](https://github.com/jorisnoo/Harvie/commit/fcb0dd88596903b31f8c77be10f88dec38cf1431))
- allow customizing sent date when marking invoices as sent ([25018b4](https://github.com/jorisnoo/Harvie/commit/25018b4fe7a8a96e137a6f1c712c37cabd58c5df))

### Code Refactoring

- redesign markAsSent sheet with side-by-side date picker layout ([3303a1d](https://github.com/jorisnoo/Harvie/commit/3303a1dbcff3d75bd4f3a6ba917f92868a86b13d))
## [0.7.2](https://github.com/jorisnoo/Harvie/releases/tag/v0.7.2) (2026-05-28)

### Features

- **export:** implement Harvest data export to CSV and JSON ([249e667](https://github.com/jorisnoo/Harvie/commit/249e667f805fc672bee88a3d158e2b85c4a307b6))
- **invoices:** add batch actions to list context menu ([4797b41](https://github.com/jorisnoo/Harvie/commit/4797b411bf96a7da6316699959aa9bc1e4777ce6))
- **release:** add --build-number parameter to release script ([fd8e246](https://github.com/jorisnoo/Harvie/commit/fd8e246d27ecfa0edf0d2f32ff22115a154c30d4))
- **templates:** graduate from beta ([661b145](https://github.com/jorisnoo/Harvie/commit/661b1452293ec9fbb2997d87359f60896a507760))
- **templates:** add funky and neon-noir invoice template designs ([b1ad650](https://github.com/jorisnoo/Harvie/commit/b1ad6506d51ef8cbd08d923788e81c568c4a25de))
- initialize label editor language from settings ([dd6c73a](https://github.com/jorisnoo/Harvie/commit/dd6c73a040aecc71bec61c85835a99663e04c54c))
- **labels:** show customized labels summary in client overrides ([92be595](https://github.com/jorisnoo/Harvie/commit/92be5959550cb5e1cbefd126d1bc56b4015c5577))
- add estimates feature ([59e889a](https://github.com/jorisnoo/Harvie/commit/59e889aa7c45b9060ac94c2abeede6f5b2b66729))

### Code Refactoring

- **settings:** add client name to remove override button and improve spacing ([30d4038](https://github.com/jorisnoo/Harvie/commit/30d4038e33e4323c71f56f8e581d0399b0a3c31f))
- consolidate sort and filter controls in ContentView ([0ac4365](https://github.com/jorisnoo/Harvie/commit/0ac436517eddd2c7f5331e55780667f05864022b))
## [0.7.1](https://github.com/jorisnoo/Harvie/releases/tag/v0.7.1) (2026-04-22)

### Features

- add per-client setting overrides for language, columns, and labels ([be04709](https://github.com/jorisnoo/Harvie/commit/be047096096183e7e436c8d42947387aaa6f89e0))

### Code Refactoring

- **qr-bill:** consolidate paragraph styles with dynamic line heights ([c3d0b82](https://github.com/jorisnoo/Harvie/commit/c3d0b828b0b4a337ef4d68b4840be5367301d9c8))
- **feature-flags:** restructure with enum-based system and runtime overrides ([d4c015e](https://github.com/jorisnoo/Harvie/commit/d4c015ed1d640a335238e110300fcbb6cf5a37db))
- extract update prompt and improve code formatting ([c35eedd](https://github.com/jorisnoo/Harvie/commit/c35eedd534b65346ab7b9cbfea1154fc35f346c8))
- **address:** improve parsing and rendering of multi-line addresses ([3ec9995](https://github.com/jorisnoo/Harvie/commit/3ec999526ae93cb3a100568a8f3671c9342261c1))
## [0.7.0](https://github.com/jorisnoo/Harvie/releases/tag/v0.7.0) (2026-03-23)

### Features

- streamline open invoice toolbar and stay on open tab after marking paid ([d61b9a8](https://github.com/jorisnoo/Harvie/commit/d61b9a85dab997bc3c456390094dd6eb5ee27650))
- add mark as paid/unpaid actions with selectable payment date ([736280d](https://github.com/jorisnoo/Harvie/commit/736280d025d5ac786a70715441cee0eb55fb83f9))
- add payment terms with automatic due date calculation ([f795791](https://github.com/jorisnoo/Harvie/commit/f7957917d3ec6e10b9d16869b03d74d8bdf7ed69))
- make email subject configurable in settings ([ab26058](https://github.com/jorisnoo/Harvie/commit/ab26058a39c0cdd352f258830a9a9e7b2def9555))
- allow date changes on sent invoices and prompt before sending ([35b2d67](https://github.com/jorisnoo/Harvie/commit/35b2d670dd3086df3cb4cd717d6d8e0a9e0ee0e5))
## [0.6.0](https://github.com/jorisnoo/Harvie/releases/tag/v0.6.0) (2026-03-16)

### Features

- include invoice title in email subject ([cd6edcc](https://github.com/jorisnoo/Harvie/commit/cd6edcc78bf4a393a5b8fce810371fb7c5d1fc55))
- make full row clickable to focus text fields in QR bill settings ([1fc5e90](https://github.com/jorisnoo/Harvie/commit/1fc5e90e68e0ba78f0f26e1cd150db49c347ce71))
- animate sidebar totals and fix rounding ([7ff7f8e](https://github.com/jorisnoo/Harvie/commit/7ff7f8e177c62139796e614327e81ba354a4049b))
- include tax/discount in live amount calculations and fix save indicator layout ([9082c71](https://github.com/jorisnoo/Harvie/commit/9082c71c9bb2267b11cfd0d0af2906343df0d1ac))

### Bug Fixes

- animate line item total on quantity/price change ([fb4c30e](https://github.com/jorisnoo/Harvie/commit/fb4c30e51f671863763d026734f89496f25fc432))
- show loading spinner in toolbar during send via email ([08c9e1b](https://github.com/jorisnoo/Harvie/commit/08c9e1b68bb758751ace32faee9662b552ba94a4))
- use Swiss rounding (nearest 0.05) and check actual modifications ([96f79b4](https://github.com/jorisnoo/Harvie/commit/96f79b4994970605c89a01d808ac860aacff1004))
- prevent spurious saves and overlapping save indicators on editable fields ([0bb7091](https://github.com/jorisnoo/Harvie/commit/0bb70911350cac7885a7c0db2274017ed6f08fdd))
- **ci:** handle multi-line downloadUrl in website update step ([d422391](https://github.com/jorisnoo/Harvie/commit/d422391ed562870ef5a31c15f9bdf8b75c7fde0d))

### Code Refactoring

- use bundled resources and simplify overlay animation ([b6ce4ce](https://github.com/jorisnoo/Harvie/commit/b6ce4ce1c7073853a6983b53a7efe9b1567a567a))

### Chores

- cleanup from code review ([b98753c](https://github.com/jorisnoo/Harvie/commit/b98753c737a2dca5df567b72806593f0c53ccad6))
## [0.5.0](https://github.com/jorisnoo/Harvie/releases/tag/v0.5.0) (2026-03-13)

### Features

- make line item quantity editable ([0b1e761](https://github.com/jorisnoo/Harvie/commit/0b1e7619cb191603376c6ba8ed57ccb243bd7002))
- overlay QR bill on last page when space available instead of appending ([b7e83ac](https://github.com/jorisnoo/Harvie/commit/b7e83aca4afedb3322b21cb1442969c175b45be0))

### Bug Fixes

- remove input filtering from quantity and price bindings ([1abb82a](https://github.com/jorisnoo/Harvie/commit/1abb82ad65f12869b0655e9dac06748796ec7a9b))
- skip API mutations in demo mode ([5d344bd](https://github.com/jorisnoo/Harvie/commit/5d344bd2e1c5825ecc28436335c156f838c53543))
- header alignment ([61763fc](https://github.com/jorisnoo/Harvie/commit/61763fcd1b266ea8888e7cfc48c41e1933ddc1b7))
- allow notes text view to expand fully instead of constraining minimum height ([ece62bf](https://github.com/jorisnoo/Harvie/commit/ece62bfbb6396290b702cdc2b56679937c9d6810))

### Continuous Integration

- update website repo download URL path from YAML to config.php ([a222550](https://github.com/jorisnoo/Harvie/commit/a2225506b30982514b2610aeb890f46a96d9ad65))
## [0.4.5](https://github.com/jorisnoo/Harvie/releases/tag/v0.4.5) (2026-03-11)

### Features

- auto-switch filter and follow invoice after marking as sent or draft ([f30a48d](https://github.com/jorisnoo/Harvie/commit/f30a48d02d3d0dfee18bb33490845fcb506be10c))
- rebrand to Harvie with new contact email, website, and privacy policy links ([c620921](https://github.com/jorisnoo/Harvie/commit/c6209210b085192e02979cd3ef9388fa70e6677d))
- support local resource loading in custom templates and update website URL in release workflow ([cb0dab4](https://github.com/jorisnoo/Harvie/commit/cb0dab4bd5fd954aedbc4c66af67b003c724fc5b))
- updated icon ([76c999f](https://github.com/jorisnoo/Harvie/commit/76c999f142d6da2bd9e823579e5fd3a92266522f))

### Bug Fixes

- fall back to first available template when selected template no longer exists ([1e73658](https://github.com/jorisnoo/Harvie/commit/1e73658d18e1114200bcd632034b3115092e5967))
- update mark-as-draft button icon to arrow.uturn.backward ([b1dacfe](https://github.com/jorisnoo/Harvie/commit/b1dacfea4e9c283869e12f0c0739aae7f0683329))

### Documentation

- compressed images ([e5bfcdc](https://github.com/jorisnoo/Harvie/commit/e5bfcdc4d24955c0085f2ef3fd6c0fdeae768277))
## [0.4.4](https://github.com/jorisnoo/Harvie/releases/tag/v0.4.4) (2026-03-10)

### Features

- add Cmd+Return keyboard shortcut to deselect focused field in invoice detail view ([3e6bdda](https://github.com/jorisnoo/Harvie/commit/3e6bddac8372e833353986632544d479448ba481))

### Build System

- universal build ([604373b](https://github.com/jorisnoo/Harvie/commit/604373bcf187b3629d925bf0076517643f6c011e))
- rename to Harvie ([9be9e87](https://github.com/jorisnoo/Harvie/commit/9be9e87f54f70026e817733e95e70c5f44a1a87a))
## [0.4.3](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.4.3) (2026-03-09)

### Bug Fixes

- ignore double-clicks in click-outside-text-fields monitor to prevent unintended field deselection ([868ea06](https://github.com/jorisnoo/HarvestQRBill/commit/868ea06b0c386d0b473e611ce88642093fe191b5))
## [0.4.2](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.4.2) (2026-03-09)

### Features

- move send-via-email into draft send menu and restrict standalone email button to open invoices ([6e54234](https://github.com/jorisnoo/HarvestQRBill/commit/6e54234dd692fe22b2b6a964a8a3a259cc9a2bd6))
- add memberwise inits, multiline line item editing, and email for open invoices ([adbcd4d](https://github.com/jorisnoo/HarvestQRBill/commit/adbcd4d46d22f31bba1edea04fb5e10b9029b490))
- add Send via Email option with QR Bill PDF attachment ([0aa08bf](https://github.com/jorisnoo/HarvestQRBill/commit/0aa08bf5d50c91be9b9deb6565a598f7a25eef0b))
- add sidebar status bar showing filtered invoice count and total ([ae671a3](https://github.com/jorisnoo/HarvestQRBill/commit/ae671a3c2a9d92dacd90e64a72cb43479e1b534c))
- add progress indicator for batch invoice update operations ([103c248](https://github.com/jorisnoo/HarvestQRBill/commit/103c248a8e7073f8be09f791d2b73cd227726c64))

### Bug Fixes

- dim saving line items and remove redundant edited state cleanup on save ([9d6ce90](https://github.com/jorisnoo/HarvestQRBill/commit/9d6ce906c2ac803049a2392e69f5e68d60719f88))
- replace inverted hide-column toggles with direct show-column bindings ([a72d27a](https://github.com/jorisnoo/HarvestQRBill/commit/a72d27a8f9fe2260ac7f8860d5598f8c94d11de7))
- update mark-as-sent button icon to text.badge.checkmark ([445eb2e](https://github.com/jorisnoo/HarvestQRBill/commit/445eb2e771817ca71492019f5ad2dec656ca6f1f))
- use template language label in email subject and improve line item text field focus behavior ([ee128e7](https://github.com/jorisnoo/HarvestQRBill/commit/ee128e7a352787fd3ad957166a84f38f4c6e4a5f))
- add nonisolated annotations and explicit Codable conformances for Swift 6 strict concurrency ([23c8b3f](https://github.com/jorisnoo/HarvestQRBill/commit/23c8b3fe985d2af6bcda42365c995b2e078d53a2))
- make template settings scrollable to prevent content overflow ([508047b](https://github.com/jorisnoo/HarvestQRBill/commit/508047b7541e301d407b9ab0b710dc015d543a48))
- merge column visibility toggles into PDF source section to reduce overflow ([14e4cb5](https://github.com/jorisnoo/HarvestQRBill/commit/14e4cb5b44ad17959278a3354717736a1176e4df))

### Code Refactoring

- replace custom MultilineTextField with native TextEditor for line item editing ([c713f10](https://github.com/jorisnoo/HarvestQRBill/commit/c713f100ddd918a1f0272153551e17845ad21805))
- replace hardcoded strings with Strings constants for localization ([59862d9](https://github.com/jorisnoo/HarvestQRBill/commit/59862d94d845b6bd716286edc1d6217f7b3ae096))
- move column visibility from per-template to global app settings ([5ba89b8](https://github.com/jorisnoo/HarvestQRBill/commit/5ba89b827eaa6d516b31d08ffcef9caa6334fea9))
## [0.4.1](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.4.1) (2026-03-09)

### Features

- replace TextField with TextEditor for line item descriptions and add Harvest-flavored markdown rendering ([38b7841](https://github.com/jorisnoo/HarvestQRBill/commit/38b7841b03500d6fca12e19275c72248b438b196))
- add automatic update check on app launch ([6830100](https://github.com/jorisnoo/HarvestQRBill/commit/6830100ce39f674d6d921ece80962fcde19c71dc))

### Bug Fixes

- move sent date from dates section to invoice summary section ([a03951f](https://github.com/jorisnoo/HarvestQRBill/commit/a03951f64ce609bb4dc8a718dfbdc361bcc85051))
- remove explicit labelStyle from Export QR Bill button ([3df3d06](https://github.com/jorisnoo/HarvestQRBill/commit/3df3d062c5c84ca3ca328e2e948e9f82524b19ec))
- improve unit price field input filtering, refresh after saves, and use standard rounded border style ([fb2353a](https://github.com/jorisnoo/HarvestQRBill/commit/fb2353a5b5cb3cd44e899c5be6e8d85be652e67f))

### Documentation

- lower minimum macOS requirement from 15.0 to 14.0 ([709b725](https://github.com/jorisnoo/HarvestQRBill/commit/709b725abf5d7a37497d4a3956b7b5358cf46824))

### Chores

- add SwiftLint configuration and build phase integration ([2b87fc4](https://github.com/jorisnoo/HarvestQRBill/commit/2b87fc4f62accc126bd92c5988dd29965e60ba15))
## [0.4.0](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.4.0) (2026-03-04)

### Features

- enable text selection on download path caption in settings ([1565d31](https://github.com/jorisnoo/HarvestQRBill/commit/1565d31fa3f92f4e3f3a9433c70050bad2fa3539))
- make paid watermark customizable with HTML/CSS styling and settings UI ([b751c3c](https://github.com/jorisnoo/HarvestQRBill/commit/b751c3c1ea4de5b077f0014b7f8bbff1d426a7c4))
- add localized "PAID" watermark overlay to invoice PDFs for paid invoices ([7daec86](https://github.com/jorisnoo/HarvestQRBill/commit/7daec864636ae03e4957057e6c62c3c8d917d15e))
- add focus state tracking and visual focus rings to editable fields in invoice detail ([9a5deb8](https://github.com/jorisnoo/HarvestQRBill/commit/9a5deb828ae810e745b26ca94ae76229006f1c6d))
- add label editor for customizing template and QR bill labels per language ([2b30132](https://github.com/jorisnoo/HarvestQRBill/commit/2b301322da3e5a26c2d5211749d8a5a7c4c887de))
- add helper text for company logo setting in templates ([16e4573](https://github.com/jorisnoo/HarvestQRBill/commit/16e45737ac0a588fd2e02fe9a082fcf32e16103a))
- add template variables reference page and insert variables at cursor position ([7bd1f96](https://github.com/jorisnoo/HarvestQRBill/commit/7bd1f969f34fe0661ec6b79c173b9bfde236bb12))
- localize QR bill labels based on selected template language ([37bd01a](https://github.com/jorisnoo/HarvestQRBill/commit/37bd01a5b3449885889a8108f0311b7678d49be0))
- add markdown list support to template engine with em-dash styled list rendering ([5da3c45](https://github.com/jorisnoo/HarvestQRBill/commit/5da3c4534f5b066755affd7174e6c75557c46eab))
- store user templates on disk with file watching and external editor support ([d092dce](https://github.com/jorisnoo/HarvestQRBill/commit/d092dcef0690a2e839bd34b3b5add53ebd8b44de))

### Bug Fixes

- normalize toolbar button heights for consistent alignment in template list ([cf3b6ce](https://github.com/jorisnoo/HarvestQRBill/commit/cf3b6ce3baaaec9b5e0de77896d329248d3b6c05))
- add spacing before additional info section in QR bill renderer ([c11a2f7](https://github.com/jorisnoo/HarvestQRBill/commit/c11a2f701582124762fe469928a58b76bc554865))
- treat single-asterisk markdown as bold instead of italic in template engine ([c244bc7](https://github.com/jorisnoo/HarvestQRBill/commit/c244bc782d4bbc84640ab0185707b852c9e903c5))
- auto-clear saved indicator after 2s and show default values in label editor fields ([b23ea79](https://github.com/jorisnoo/HarvestQRBill/commit/b23ea79aa7fc73bddb62511783d3c8793998d4c3))
- allow multiline line item descriptions and adjust text field padding ([c0ce14b](https://github.com/jorisnoo/HarvestQRBill/commit/c0ce14ba8bc87e83ba54576eacbfb95816ee61b4))
- preserve scroll position in HTML editor and extract PreviewPanel to reduce SwiftUI re-evaluation ([a3b25a7](https://github.com/jorisnoo/HarvestQRBill/commit/a3b25a78e7b9a5fc3334b1c854ba86a4c8061fb0))

### Code Refactoring

- deduplicate PDF/QR-bill logic, extract filtering models and export into separate files ([0fc1bad](https://github.com/jorisnoo/HarvestQRBill/commit/0fc1bad65d869cee01697e4842a4087212dc3186))
- simplify paid watermark styling, fix overlay alignment, and remove custom text option ([532b5f0](https://github.com/jorisnoo/HarvestQRBill/commit/532b5f0ded5583998d8b314d5a0f80eec9437f0e))
- consolidate paid date logic into effectivePaidDate and deduplicate preview HTML builder ([08130ba](https://github.com/jorisnoo/HarvestQRBill/commit/08130ba19faa5d61d22eddfbd138e6556eab0d96))
- move app settings from Keychain to UserDefaults and improve template selection error handling ([1e7783f](https://github.com/jorisnoo/HarvestQRBill/commit/1e7783fe683a8a7a986b702a4970517701c98e90))
- extract EditableField utility and consolidate sheet state in InvoiceDetailView ([c97b4f2](https://github.com/jorisnoo/HarvestQRBill/commit/c97b4f296aedcc06906e39f9ff9630bdee86acc0))

### Continuous Integration

- add automatic Homebrew cask update step to release workflow ([55ee136](https://github.com/jorisnoo/HarvestQRBill/commit/55ee1361d6b8652c4696162041ff7af784afe2a7))

### Chores

- add .worktrees directory to .gitignore ([859cce5](https://github.com/jorisnoo/HarvestQRBill/commit/859cce55bb88e75c7331db5c6e67ac7336be0557))
## [0.3.0](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.3.0) (2026-02-16)

### Features

- show invoice amount instead of zero when due amount is empty ([acdfb82](https://github.com/jorisnoo/HarvestQRBill/commit/acdfb82c3ca952d018e67dd133413ff2284ae601))
- add drag-and-drop PDF export for invoices and pin Xcode 16 in CI ([c03cdc8](https://github.com/jorisnoo/HarvestQRBill/commit/c03cdc81a080381357fcd8195806fbd210c0d0bf))
- add template preview window with sample data rendering ([0b70865](https://github.com/jorisnoo/HarvestQRBill/commit/0b70865809c351c170e950123b3c9176113db5a8))
- add company logo support to invoice templates with storage, settings UI, and rendering ([431e043](https://github.com/jorisnoo/HarvestQRBill/commit/431e0432e41719d540da05b868db0606f57460e5))

### Bug Fixes

- freeze when collapsing sidebar ([ba0aff3](https://github.com/jorisnoo/HarvestQRBill/commit/ba0aff30ae8b70ca8ecf0cac5cee9a37ad826f80))
- persist template editor variables panel visibility with @AppStorage ([a8d6e56](https://github.com/jorisnoo/HarvestQRBill/commit/a8d6e56a0f6d4b194ca280f3a5e3bca0dcf43ab2))
- lower macOS deployment target from 15.0 to 14.0 (Sonoma) ([aae11c2](https://github.com/jorisnoo/HarvestQRBill/commit/aae11c277e0f445f4385f1a749c165558f41c6fe))
- set macOS deployment target to 15.0 (Sequoia) ([4f9456f](https://github.com/jorisnoo/HarvestQRBill/commit/4f9456f694afff93848953b791e98ece25576a66))
- only reload invoices from API when credentials or demo mode change ([9f67ef0](https://github.com/jorisnoo/HarvestQRBill/commit/9f67ef0324650333b4f8c047d01dc7e94ee13d6d))
- include user company logo in template editor preview context ([66af7ba](https://github.com/jorisnoo/HarvestQRBill/commit/66af7ba824918bab1c0589b4b602724b4533b722))

### Continuous Integration

- add macos 26 to tests ([da73f8b](https://github.com/jorisnoo/HarvestQRBill/commit/da73f8b21329c4401ebc729f50a5d06eba6c3a74))
- disable code signing in GitHub Actions build workflow ([d1cb799](https://github.com/jorisnoo/HarvestQRBill/commit/d1cb7991ec51cccbf5514cc60356a4a808fa6b43))
- add GitHub Actions workflow to build and test on macOS 14/15 ([46ad2dc](https://github.com/jorisnoo/HarvestQRBill/commit/46ad2dc9bbc4215ba2fe718a6122d6e41457cc9e))

### Chores

- downgrade Xcode project objectVersion to 70 for broader compatibility ([f5cb4ef](https://github.com/jorisnoo/HarvestQRBill/commit/f5cb4ef5741bfb1093da78bd9f5b2e0504aae141))
## [0.2.6](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.2.6) (2026-02-12)

### Features

- render line item descriptions as inline markdown with bold and italic support ([3e154c1](https://github.com/jorisnoo/HarvestQRBill/commit/3e154c109a88c7a1a1a32fbab653ee306856f70d))

### Bug Fixes

- remove fixed height constraint and enable multi-page PDF pagination with proper page-break rules ([ecfbaf3](https://github.com/jorisnoo/HarvestQRBill/commit/ecfbaf303f8e2b410f330032a622891bb5078569))

### Performance Improvements

- cache formatters, regex, and encoders to avoid repeated allocations ([74efdfb](https://github.com/jorisnoo/HarvestQRBill/commit/74efdfb062fdee1ddb8134ec11545bb34440c1cd))

### Code Refactoring

- derive selectedInvoice from selectedInvoiceIDs, cache number formatters, and batch sort updates during settings restore ([d1ae9ba](https://github.com/jorisnoo/HarvestQRBill/commit/d1ae9ba8b366f4756c8bbf32f3b4840f2a5dd70e))
- cache sorted invoices and settings in view model, pass creditor info and app settings to detail view as props ([2ef24d8](https://github.com/jorisnoo/HarvestQRBill/commit/2ef24d8e963eb2a7dde972299e85a6c3d911fa3d))

### Chores

- switch to forked aptabase-swift with custom host support and remove debug-only analytics guard ([059c02b](https://github.com/jorisnoo/HarvestQRBill/commit/059c02b47cdc40b62a8e3da2467f57c73d200ae8))
- remove badge section from README ([055380c](https://github.com/jorisnoo/HarvestQRBill/commit/055380c07db746f6f8f573dc666f81bf3e58f73a))
## [0.2.5](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.2.5) (2026-02-11)

### Features

- add feedback tab to settings with contact and issue reporting links ([bb368ce](https://github.com/jorisnoo/HarvestQRBill/commit/bb368cec86498b3cf94debe135aec330473e9a0a))
- add markdown filter to template engine for rich text in descriptions and notes ([f121b73](https://github.com/jorisnoo/HarvestQRBill/commit/f121b73f0947587264131bb527f9543cc957f1a2))
- add feature flags ([4044a32](https://github.com/jorisnoo/HarvestQRBill/commit/4044a327fc99619535b7e3c9fe406b53a3d7a3ca))
- add column visibility toggles and total hours to invoice templates ([2fcf4df](https://github.com/jorisnoo/HarvestQRBill/commit/2fcf4df40c7e331be14bbe06a3c989ef6c5e487d))
- add custom templates ([fc4841c](https://github.com/jorisnoo/HarvestQRBill/commit/fc4841c8d9baf2b331aa0e09ae0524a68cde38fb))

### Bug Fixes

- skip QR bill generation for unsupported currencies ([28fb2e3](https://github.com/jorisnoo/HarvestQRBill/commit/28fb2e3e56dcbaf10fafd0efdebbc5afeffe52d1))
- set A4 dimensions and 75% zoom for template PDF rendering ([dfd0288](https://github.com/jorisnoo/HarvestQRBill/commit/dfd02886a6e6b7a5438eccc93559c3681f4b4855))
- harden WKWebView configuration for template PDF rendering with non-persistent data store, disabled JS, and proper window-server GPU context ([0e2c61e](https://github.com/jorisnoo/HarvestQRBill/commit/0e2c61e4f144f1224108b379ab6dcf837f6d561f))
- add hidden render window for WKWebView GPU context and terminate app on last window close ([cf18273](https://github.com/jorisnoo/HarvestQRBill/commit/cf182733127316265c00163aba844e7366f11da9))
- add column toggle CSS defaults to templates and ensure visibility overrides cascade correctly ([1b214e7](https://github.com/jorisnoo/HarvestQRBill/commit/1b214e7c52d6f06d7408bfda8b64907f0aa7e7ca))
- set description column width to 100% in all invoice templates for proper table layout ([91dadd2](https://github.com/jorisnoo/HarvestQRBill/commit/91dadd2b2818c02f5a92f40582eefe57406e5998))
- improve TemplatePreviewView stability with navigation delegate, crash recovery, and launch services entitlement ([0578c6e](https://github.com/jorisnoo/HarvestQRBill/commit/0578c6e4cce1b891ac4618dd1d390590d8178369))
- use single Window for main scene and scope classic template column alignment to items table ([394fa44](https://github.com/jorisnoo/HarvestQRBill/commit/394fa44be3d55f035292c4c510afcd18ddd5ec2b))
- add timeout and robust error handling to template PDF rendering ([99c49cb](https://github.com/jorisnoo/HarvestQRBill/commit/99c49cb747ff26e5ed284692694d7736fd0fb84f))

### Code Refactoring

- replace manual save button with debounced auto-save for settings ([14817b4](https://github.com/jorisnoo/HarvestQRBill/commit/14817b41d999436550eb9be258dfc18ee3e3c4c7))
- extract CSS custom properties and fix editor window lifecycle management ([7b0f3c7](https://github.com/jorisnoo/HarvestQRBill/commit/7b0f3c73b6de2311f9e2174f037c3a01acea99a1))
- extract shared utilities, deduplicate API/PDF logic, and add reusable ConfirmationSheet ([d8486f8](https://github.com/jorisnoo/HarvestQRBill/commit/d8486f8a4f492888542f3c0b5afb6c29f8f91571))

### Chores

- disable customPDFTemplates feature flag and mark templates tab as beta ([208d2e1](https://github.com/jorisnoo/HarvestQRBill/commit/208d2e1bb5eb6cb89cf4facd11ac2cb650c49461))
## [0.2.4](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.2.4) (2026-02-11)

### Features

- reload invoices and creditor info when settings are saved, add retry button to setup prompt ([3e9d676](https://github.com/jorisnoo/HarvestQRBill/commit/3e9d6768f58cc4858ffede08d3b4c9110b18fb91))
- show setup required prompt with open settings button when credentials are missing ([705afd9](https://github.com/jorisnoo/HarvestQRBill/commit/705afd9035e3b2981ace4d363c270aaa62fc24c0))
## [0.2.3](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.2.3) (2026-02-11)

### Code Refactoring

- use focusedSceneValue instead of NotificationCenter for menu refresh action ([14560f7](https://github.com/jorisnoo/HarvestQRBill/commit/14560f78490227292587908fcfe343ed31c91413))
- use native Settings scene and NotificationCenter instead of focused values for settings and refresh ([88f2a6f](https://github.com/jorisnoo/HarvestQRBill/commit/88f2a6fe458a17f6327da7d4e6bca036ecec6024))
## [0.2.2](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.2.2) (2026-02-11)

### Features

- wrap demo mode code in #if DEBUG to exclude it from release builds ([ea6d2e6](https://github.com/jorisnoo/HarvestQRBill/commit/ea6d2e649fdc1edc63fbc95a556ac1206a74d73a))
- add auto-update install flow with restart prompt and disable app sandbox for direct distribution ([b8df5b7](https://github.com/jorisnoo/HarvestQRBill/commit/b8df5b7e6ab3ebf2693ecf26fa9692e1f58cffae))
## [0.2.1](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.2.1) (2026-02-11)

### Features

- replace full list reload with targeted invoice refresh and move GitHub repo config to Info.plist ([909cfa1](https://github.com/jorisnoo/HarvestQRBill/commit/909cfa1a16cedd45b40864e6e79830ebbfc05888))
- add search filtering for invoices by number and client name ([581018a](https://github.com/jorisnoo/HarvestQRBill/commit/581018aaa81c7b2c37bef884982938e21aeb4da2))
- refresh invoice list after updating issue date, marking as sent, or marking as draft ([3be5f19](https://github.com/jorisnoo/HarvestQRBill/commit/3be5f19c047ba64e1cd5b319686b1bfe500ce5e3))

### Code Refactoring

- add in-memory cache to KeychainService and use update-or-add instead of delete-then-add ([eefd204](https://github.com/jorisnoo/HarvestQRBill/commit/eefd204986e51628a2448f7498cf4e9bba9a3677))
## [0.2.0](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.2.0) (2026-02-11)

### Features

- invoice detail view improved ([bd6ca13](https://github.com/jorisnoo/HarvestQRBill/commit/bd6ca1323b58008d666dfd5d6263d525e26b634d))
- ui cleanup ([e933b90](https://github.com/jorisnoo/HarvestQRBill/commit/e933b902c7373f607f233e7f0eb25d555e26b642))
- allow chaning invoice date and mark as sent/draft. ([279c668](https://github.com/jorisnoo/HarvestQRBill/commit/279c668cb4caffa3c44d9a33d6d64d584a12154e))
- add plausible ([c3f5b9b](https://github.com/jorisnoo/HarvestQRBill/commit/c3f5b9bb0b53c9478af9521fd703e82d5f8bcacc))
- add multi-selection detail view with export actions ([36bbb06](https://github.com/jorisnoo/HarvestQRBill/commit/36bbb0646ff5ef570aa3df47a5b5bceb10b0737e))
- add selection mode with native multi-select support ([faca70f](https://github.com/jorisnoo/HarvestQRBill/commit/faca70f163903a3678c008d1eafe3ef926ad08fa))
- adjust qr layout ([4f56043](https://github.com/jorisnoo/HarvestQRBill/commit/4f56043ca7d743bc15bdbb19a19c7198ad937361))
- add autoupdater ([e98132e](https://github.com/jorisnoo/HarvestQRBill/commit/e98132ec4b702a73e2c9adbfdf1f2744153bbed9))

### Bug Fixes

- list select ([d99397c](https://github.com/jorisnoo/HarvestQRBill/commit/d99397ce030597d3e9ef83a4d5bcb5188e56cefc))
- plausible ([dfaf253](https://github.com/jorisnoo/HarvestQRBill/commit/dfaf253736127a9c4dcb42a8a53a33f6b23c6781))
- api race condition ([92d800d](https://github.com/jorisnoo/HarvestQRBill/commit/92d800d7d59564bdc84716f7676e46d5a5c49ab8))
- cmd a to select ([f3728de](https://github.com/jorisnoo/HarvestQRBill/commit/f3728de665c6d808a8fa94fca79f3fc58da63ce1))
- implement security audit recommendations ([af0d4fe](https://github.com/jorisnoo/HarvestQRBill/commit/af0d4fe990d679d7bf3069d6cd62313fc7fbd476))
- quartely filter ([180449f](https://github.com/jorisnoo/HarvestQRBill/commit/180449f52a71d75c09971cbf8a2a0280884c5261))
- readme ([ef986df](https://github.com/jorisnoo/HarvestQRBill/commit/ef986dfe14531f65a0660df2938dd127f5ef88b7))

### Code Refactoring

- generalise build scripts, use British spelling for notarise, add App Store build config and notes heading ([6841814](https://github.com/jorisnoo/HarvestQRBill/commit/6841814e0b25ff12e96935be9ff1a919ea0bc69c))
- migrate analytics from AviaryInsights/Plausible to Aptabase with more granular event tracking ([3b3c073](https://github.com/jorisnoo/HarvestQRBill/commit/3b3c073e8b6645b819c75584a870d213867df2d3))
- simplify state indicator in detail view and clear invalid selections on filter/sort changes ([f7cbca9](https://github.com/jorisnoo/HarvestQRBill/commit/f7cbca9e7889a984681711b7c586de90462861a1))
- cleanup ([faeacc0](https://github.com/jorisnoo/HarvestQRBill/commit/faeacc08e6cd7b20625ddc03371d3343c79f1879))
- conform to swift 6 where possible ([8939446](https://github.com/jorisnoo/HarvestQRBill/commit/89394464eca1813932e0bf61b178777111eb8d1a))
- cleanup ([401dcaf](https://github.com/jorisnoo/HarvestQRBill/commit/401dcafe1028b7da799b8a95cd5d421a1dd395bf))

### Documentation

- update readme ([f509b74](https://github.com/jorisnoo/HarvestQRBill/commit/f509b74a5a48a0754e23caa56ea5cf04cf655702))
- add images to readme ([ab92c5c](https://github.com/jorisnoo/HarvestQRBill/commit/ab92c5c15ec03cbba3f7c5fb49187cea414bb167))

### Build System

- add app store toggle ([1fb43dd](https://github.com/jorisnoo/HarvestQRBill/commit/1fb43ddd4cc0ccc1093706a6ac158a3752b5e527))
- add ci script ([1bf0339](https://github.com/jorisnoo/HarvestQRBill/commit/1bf03399391bc1611ff6a1fbfc3441009867a0e4))
- add macosicon ([13a0b9c](https://github.com/jorisnoo/HarvestQRBill/commit/13a0b9ce521199fe46cff1f9e066c91a3b7a9f95))
- link to changelog in release file ([323de60](https://github.com/jorisnoo/HarvestQRBill/commit/323de60a6cfb93d2c1d8b6d22cb2fec1bcf335a0))
- remove unused packages ([d751b0b](https://github.com/jorisnoo/HarvestQRBill/commit/d751b0be90b61cd40647fa9435197cc0b44657fd))
- local build script ([e3f9571](https://github.com/jorisnoo/HarvestQRBill/commit/e3f9571ccdeb9c7db462c175e35ab16357f8b138))

### Chores

- replace AviaryInsights with Aptabase analytics SDK ([d886244](https://github.com/jorisnoo/HarvestQRBill/commit/d886244a23a32f850320dd2c2e38f4a73a999397))
- switch AppUpdater to jorisnoo fork v3.0.0 and remove PromiseKit dependency ([422c2ae](https://github.com/jorisnoo/HarvestQRBill/commit/422c2aeb0e7c1bee369bf60ee2d05d32608c1c9e))
- remove files from xcode ([4d63b67](https://github.com/jorisnoo/HarvestQRBill/commit/4d63b67ae603300c65d6aafb8d20dab9325ef127))
- sync version 0.1.3 to Xcode ([fa58577](https://github.com/jorisnoo/HarvestQRBill/commit/fa585774233abe08ca5fc971abc60cd0871805c9))
## [0.1.3](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.1.3) (2026-01-20)

### Bug Fixes

- use git-auto-commit-action for version sync ([9d93ca9](https://github.com/jorisnoo/HarvestQRBill/commit/9d93ca9c9e318df0d98b608e774e36bed9a1123c))
## [0.1.2](https://github.com/jorisnoo/HarvestQRBill/releases/tag/v0.1.2) (2026-01-20)

### Documentation

- add readme ([0b1e70a](https://github.com/jorisnoo/HarvestQRBill/commit/0b1e70aedd13a38df3d4e67b5f606ff261cd8ce4))
## [0.1.0](https://github.com/jorisnoo/HarvestQRBill/releases/tag/0.1.0) (2026-01-20)

### Features

- Connect to Harvest account to fetch invoices
- Generate Swiss QR Bills compliant with Swiss Payment Standards
- Automatic SCOR reference generation (Creditor Reference ISO 11649)
- Export invoices with QR payment slip as PDF
- Secure credential storage in macOS Keychain
- Native macOS app built with SwiftUI
