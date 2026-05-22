# DigiByte Wallet iOS Repo Map

Last refreshed: 2026-05-22
Compatibility target: DigiByte Core `v8.26.2` public stable behavior for DGB SPV, plus RC41/testnet25 DigiDollar bring-up on P2P port `12032`.

## Root

- `DigiByte.xcodeproj/` - Xcode project, shared schemes, target/build configuration graph.
- `DigiByte.xcworkspace/` - Workspace wrapper.
- `.gitmodules` - Submodules for BRCore, DNS/unbound/nettle, and Swift UI/support libraries.
- `BundleVersion`, `versioning_branch`, `scripts/icon_versioning.sh` - Version/build-number support.
- `Snapfile`, `Screenshots/` - Snapshot/test automation.
- `README.md`, `LICENSE`, `ToDos*`, `images/` - Project metadata and public assets.

## Upstream Fork Context

- GitHub identifies this repository as a fork of `breadwallet/breadwallet-ios`.
- The fork is far diverged from upstream Breadwallet history; upstream should be treated as an implementation reference for Xcode/Swift/iOS modernization only.
- Do not directly merge broad upstream changes without separating DigiByte-specific protocol constants, address handling, derivation compatibility, Digi-ID, DigiAssets, app services, and branding.
- Upstream `breadwallet/breadwallet-ios` is itself marked unmaintained and points newer BRD mobile work at `breadwallet/brd-mobile`, so newer-iOS fixes may need to be studied across both histories and then backported narrowly.

## Main App: `DigiByte/`

- `Info.plist` - URL schemes, document/payment MIME types, app configuration.
- `digibyte.entitlements` - Main app entitlements. Local uncommitted state has empty app-group array.
- `Audio/`, `Fonts/`, `Storyboards/`, `Settings.bundle/`, `Other/*.lproj/` - App resources, launch UI, settings, BIP39 localized word lists.

### `DigiByte/Source`

- `AppDelegate.swift`, `main.swift` - App entrypoint.
- `ApplicationController.swift`, `WalletCoordinator.swift`, `ModalPresenter.swift`, `URLController.swift` - Application composition, routing, modal presentation, URL handling.
- `WalletManager.swift` - SQLite wallet store, BRWallet/BRPeerManager ownership, block/peer/transaction persistence, sync callbacks.
- `BRCore.swift` - Swift wrapper over the C `BRCore` module, including DigiDollar TD/DD address, balance, mint, vault, and redeem bridge APIs.
- `Sender.swift`, `PaymentRequest.swift`, `PaymentProtocol.swift`, `FeeUpdater.swift`, `FirstBlockWithWalletTxRequest.swift`, `AssetSender.swift` - Payment, fee, explorer/bootstrap, and send flows.
- `Environment.swift`, `Utils.swift`, `RetryTimer.swift`, `ReachabilityMonitor.swift`, `KVStoreCoordinator.swift`, `UserDefaultsUpdater.swift`, `SimpleRedux.swift` - App utilities and state support.
- `DigiIDRequest.swift` - Digi-ID request handling.

### `DigiByte/Source/Constants`

- `Constants.swift` - UI constants and network port selection (`12024` mainnet, `12026` testnet).
- `Strings.swift`, `Symbols.swift`, `Functions.swift`, `ArticleIds.swift` - Localized string access, symbols, helpers, support identifiers.

### `DigiByte/Source/Platform`

- `BRAPIClient*.swift`, `BRAPIProxy.swift` - API client and API extensions for assets, events, features, KV, and wallet requests.
- `BRHTTPServer.swift`, `BRHTTPRouter.swift`, `BRHTTP*Middleware.swift`, `BRWebSocket.swift`, `BRWalletPlugin.swift`, `BRKVStorePlugin.swift`, `BRCameraPlugin.swift`, `BRGeoLocationPlugin.swift`, `BRLinkPlugin.swift`, `BRWebViewController.swift`, `BRBrowserViewController.swift` - Local web/plugin stack.
- `BRDigiID.swift`, `BRDigiIDLegacy.swift` - Digi-ID implementations.
- `DigiDollarProtocol.swift` - Swift helpers for TD/DD address validation, transaction metadata, lock/DCA/ERR policy display, and tests that mirror the C core helpers.
- `BRReplicatedKVStore.swift`, `TxMetaData.swift`, `WalletInfo.swift` - Metadata/KV persistence.
- `BRSocketHelpers.c/.h`, `module.modulemap` - Socket C helper exposed to Swift.
- `BRCoding.swift`, `BRBSPatch.swift`, `BRTar.swift`, `Extensions.swift`, `BRActivityView.swift` - Support utilities.

### UI And State

- `SimpleRedux/` - App actions and state.
- `Models/` - Rates, settings, assets, keyboard info, simple UTXO model, typed model helpers.
- `ViewModels/` - Amount and transaction presentation models.
- `ViewControllers/` - Main UIKit screens including onboarding, send/receive, settings, security, DigiAssets, DigiDollar, scan, sync, transaction detail, and root modals.
- `ViewControllers/DigiDollar/DigiDollarMainViewController.swift` - DigiDollar sub-wallet UI with Overview, Send, Receive, Vault, and Transactions tabs; backs transfer, mint, and full-vault redeem flows.
- `Views/` - Reusable views, transaction cards, drawers, DigiAssets views, loading/progress/wave views.
- `Controls/` - Haptic/menu/segmented controls.
- `Extensions/` - UIKit/Foundation/UserDefaults/WalletManager extensions.
- `FlowControllers/` - Start flow and message UI presentation.
- `Data/` - Emergency rates.
- `Strings/*.lproj/Localizable.strings` - Localizations.

## Extensions

- `DigiByte TodayExtension/` - Today widget Swift controller, storyboards, plist, entitlements. Local uncommitted state has empty app-group array.
- `TodayExtension/` - Legacy/localized Today extension storyboard resources.
- `MessagesExtension/` - iMessage extension controller, assets, localized storyboards, entitlements.
- `NotificationServiceExtension/` - Push notification service extension.
- `DigiByte WatchKit App/` - Watch app storyboards, assets, plist, entitlements.
- `DigiByte WatchKit Extension/` - Watch extension controllers, delegate, complication, data manager, notification payload, entitlements.

## Tests

- `digibyteTests/` - Unit tests for API client, BSPatch, coding, HTTP server, KV store, payment request, phrase, spending limits, wallet auth/creation/info, DigiDollar protocol vectors, and helper utilities.
- `digibyteUITests/` - UI test target, including login smoke coverage and DigiDollar menu/tab smoke coverage.
- `Screenshots/` - Screenshot automation target and helpers.

## Submodules And Dependencies

- `Modules/digibytewallet-core/` - Embedded C SPV core, built as the `BRCore` static library target.
- `Modules/digibytewallet-core/secp256k1/` - Nested secp256k1 C library used by BRCore.
- `Modules/dns/`, `Modules/unbound/`, `Modules/nettle/` - DNSSEC/network support inherited from breadwallet-era dependencies.
- `Modules/libbz2/`, `Modules/sqlite3/` - Local module maps/plists for system libraries.
- `Modules/Kingfisher/` - Image loading/caching library.
- `Modules/MarqueeLabel/` - Scrolling label UI component.
- `Modules/Storez/`, `Modules/UserDefaultsStore/` - State/defaults support.
- `Modules/VisualEffectView/` - Visual effect view support.

## Embedded Core Map

Key files in `Modules/digibytewallet-core`:

- `BRChainParams.h` - DigiByte network params, DNS seeds, ports, magic numbers, checkpoints.
- `BRPeer.c/.h`, `BRPeerManager.c/.h` - P2P protocol, peer discovery, socket connections, SPV sync.
- `BRMerkleBlock.c/.h` - Merkle block parsing, proof-of-work/difficulty checks, multi-algo block fields.
- `BRWallet.c/.h` - Address generation, UTXO tracking, balance, transaction creation/signing.
- `BRTransaction.c/.h` - Transaction serialization, witness serialization, txid/wtxid, fees, ECDSA signing, Taproot key-path sighash, and Taproot script-path sighash.
- `BRAddress.c/.h`, `BRBase58.c/.h`, `BRBech32.c/.h` - Address/script encoding, including SegWit/Taproot address handling.
- `BRKey.c/.h`, `BRBIP32Sequence.c/.h`, `BRBIP38Key.c/.h`, `BRBIP39Mnemonic.c/.h`, `BRBIP39WordsEn.h` - Keys, HD derivation, encrypted keys, mnemonic handling, x-only keys, Schnorr signatures, and Taproot output-key helpers.
- `BRCrypto.c/.h`, `crypto/`, `crypto/sha3/` - Hashes, HMAC/PBKDF2/scrypt, multi-algo PoW crypto.
- `BRBloomFilter.c/.h` - BIP37 bloom filters.
- `BRPaymentProtocol.c/.h` - BIP70/BIP75-style payment protocol.
- `BRDigiAsset.c/.h`, `BRAssetData.c/.h` - DigiAsset helpers.
- `BRDigiDollar.c/.h` - DigiDollar TD/DD addresses, token scripts, OP_RETURN metadata, lock-tier/DCA/ERR helpers, collateral Taproot trees, and control blocks.
- `BRWalletCreateDigiDollarTransfer()` - Builds wallet-owned DD transfer transactions with DGB fee inputs.
- `BRWalletCreateDigiDollarMint()` - Builds mint transactions with DGB collateral, DD token output, and mint metadata.
- `BRWalletDigiDollarVaults()` and `BRWalletCreateDigiDollarRedeem()` - Track wallet-owned vaults and build full-position redeem transactions with normal/ERR burn policy.
- `module.modulemap` - Clang module exported to Swift as `BRCore`.

## Build/Audit Findings

- Existing uncommitted iOS project/entitlement changes were preserved.
- Submodules were initialized locally so Xcode can see project-referenced sources.
- Narrow build fix changed three embedded-core headers:
  - `Modules/digibytewallet-core/BRMerkleBlock.h`
  - `Modules/digibytewallet-core/BRPeer.h`
  - `Modules/digibytewallet-core/BRWallet.h`
- `xcodebuild -project DigiByte.xcodeproj -scheme BRCore -configuration Debug -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build` succeeds.
- The iOS 26.5 simulator runtime is now installed locally and `iPhone 17 (F24B7821-AF76-460E-8687-ABEFA542146D)` is booted.
- Legacy deployment targets in the app and embedded module projects were raised to iOS 12.0 to satisfy Xcode 26's simulator toolchain.
- `DigiByte/Source/ViewControllers/DigiAssets/DAMainViewController.swift` was adjusted for newer UIKit by renaming the private `tabs` property to `assetTabs`.
- `env DGB_FIXED_PEER=127.0.0.1:12032 xcodebuild build -project DigiByte.xcodeproj -scheme Testnet -configuration Testnet -destination 'platform=iOS Simulator,id=F24B7821-AF76-460E-8687-ABEFA542146D'` succeeds.
- The built app installs on the iOS 26.5 simulator with bundle id `org.digibytefoundation.DigiByte`.
- Focused `DigiDollarProtocolTests`, `testCreateWalletOrLoginSmoke`, and `testDigiDollarMenuOpens` pass on the iPhone 17 iOS 26.5 simulator.
- The app launches to the PIN/main-wallet path on the simulator. The current simulator wallet PIN is `111111`.
- A local RC41 bridge node is running on `127.0.0.1:12032` with bloom filters enabled and connected to public RC41 peers.
- Remaining live-network blocker: the local bridge node has no funded wallet loaded, so live funded mint/redeem broadcast has not yet been proven.
- Remaining non-fatal warnings include duplicate implicit dependency warnings around `Storez.framework`.

## Compatibility Notes For DigiByte Core v8.26.2

- The app is an SPV wallet and does not embed DigiByte Core consensus code.
- Current audited paths use mainnet `12024`, mainnet magic `0xdab6c3fa`, testnet magic `0xddbdc8fd`, legacy embedded DNS seeds, checkpoints, protocol `70019`, bloom filters, `getheaders/getblocks`, `merkleblock`, and transaction relay.
- DigiDollar RC41/testnet25 validation uses P2P port `12032` through a local bloom-capable bridge peer.
- DigiByte Core `v8.26.2` uses a newer DNS seed set than this embedded iOS core; seed refresh is the next protocol follow-up.
- DigiDollar wallet-side address, transfer, mint, vault, and redeem builders are present in the embedded core and surfaced through Swift/iOS UI. The mobile wallet does not run DigiDollar oracle or full-node consensus logic.
- Checkpoint freshness and DNS seed liveness still need runtime verification against public `v8.26.2` peers.
