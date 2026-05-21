# DigiByte Wallet iOS Architecture

Last refreshed: 2026-05-21

Compatibility target: DigiByte Core `v8.26.2` public stable behavior. This wallet is an SPV mobile wallet and intentionally does not target DigiDollar or `v9.26.0-rc` behavior.

## Executive Summary

`digibytewallet-ios` is a Swift/UIKit DigiByte wallet derived from breadwallet. It preserves the original mobile SPV model: a native C `BRCore` static library handles keys, transactions, merkle blocks, bloom filters, peer messages, and DigiByte proof-of-work checks, while Swift owns app lifecycle, persistence, onboarding, send/receive UI, Digi-ID, DigiAssets screens, and service/API integration.

The runtime boundary is intentionally smaller than a full DigiByte Core node. The app validates wallet-relevant filtered block data and transactions against checkpoints, peer headers, merkle proofs, bloom filters, and transaction rules. It does not maintain a full UTXO set, expose RPC, mine blocks, or implement DigiDollar consensus/oracle features.

## System Boundaries

In scope:

- Swift app, extension, and watch targets in `DigiByte.xcodeproj`.
- Embedded `BRCore` C library from `Modules/digibytewallet-core`.
- SQLite wallet database, peer/block/transaction persistence, and app-group defaults.
- Public DigiByte P2P SPV behavior compatible with DigiByte Core `v8.26.2`.
- Breadwallet-era local web/plugin stack, Digi-ID, payment request, and DigiAssets app flows.

Out of scope:

- DigiByte Core full-node validation, mempool policy enforcement, RPC, mining, and wallet.dat behavior.
- DigiDollar `v9.26.0-rc` mint/transfer/redeem/oracle behavior.
- Server-side rate, feature, metadata, broadcast helper, or support-service availability guarantees.

## Upstream Breadwallet Reference

This repository is a DigiByte fork of `breadwallet/breadwallet-ios` and is thousands of commits diverged from that upstream history. Upstream Breadwallet should be used as a reference when resolving Xcode, Swift, storyboard, extension, signing, or newer-iOS platform problems, but not as a direct merge source for wallet protocol behavior.

When comparing upstream fixes, keep these boundaries explicit:

- Preserve DigiByte network constants, address prefixes, seed phrase derivation compatibility, Digi-ID, DigiAssets, and branding.
- Prefer narrow cherry-picks or manual backports for Xcode/project-format modernization.
- Do not assume BRD/Blockset/Fastsync service paths are appropriate for the resurrected DigiByte SPV wallet.
- Note that `breadwallet/breadwallet-ios` itself is marked unmaintained upstream and points newer BRD work at `breadwallet/brd-mobile`; use both only as references, not as authority over DigiByte protocol behavior.

## Runtime Layers

```text
UIKit app and extensions
        |
        v
Swift wallet/application layer
  AppDelegate, ApplicationController, WalletManager, Sender,
  PaymentRequest, BRAPIClient, view controllers, Redux store
        |
        v
Swift BRCore wrapper
  DigiByte/Source/BRCore.swift
        |
        v
C SPV core static library
  Modules/digibytewallet-core/*.c, secp256k1, crypto/sha3
        |
        v
DigiByte P2P network
  BIP37 bloom-filter SPV, headers/merkleblock/tx relay
```

## Directory Structure

- `DigiByte.xcodeproj/` - project graph, targets, schemes, build settings, signing settings.
- `DigiByte.xcworkspace/` - workspace wrapper.
- `DigiByte/` - main iOS app resources, entitlements, localized resources, and Swift source.
- `DigiByte/Source/` - application controller, wallet manager, BRCore wrapper, send/receive/payment flows, platform services, UI, state, and utilities.
- `DigiByte TodayExtension/`, `MessagesExtension/`, `NotificationServiceExtension/` - iOS extensions.
- `DigiByte WatchKit App/`, `DigiByte WatchKit Extension/` - watch targets.
- `Modules/digibytewallet-core/` - embedded C SPV wallet core and nested secp256k1 source.
- `Modules/dns/`, `Modules/unbound/`, `Modules/nettle/`, `Modules/libbz2/`, `Modules/sqlite3/` - inherited native/system support modules.
- `Modules/Kingfisher/`, `Modules/MarqueeLabel/`, `Modules/Storez/`, `Modules/UserDefaultsStore/`, `Modules/VisualEffectView/` - Swift/UI support dependencies.
- `digibyteTests/`, `digibyteUITests/`, `Screenshots/` - test and screenshot automation targets.

## Key Components

### App Composition

- `DigiByte/Source/AppDelegate.swift` and `main.swift` are the app entrypoints.
- `ApplicationController.swift`, `WalletCoordinator.swift`, `StartFlowPresenter.swift`, `ModalPresenter.swift`, and `URLController.swift` coordinate launch, onboarding, modal flows, wallet root navigation, and URL/deep-link routing.
- `SimpleRedux/`, `ViewModels/`, `ViewControllers/`, `Views/`, `Controls/`, and `FlowControllers/` implement app state and UIKit presentation.

### Wallet Manager

`WalletManager.swift` is the central Swift owner of local wallet state. It manages wallet creation/restore, the SQLite database, transaction/block/peer persistence, sync callbacks, primary-key state, balance notifications, and `BRPeerManager` lifecycle.

### Native Core Bridge

`DigiByte/Source/BRCore.swift` wraps the C module exposed by `Modules/digibytewallet-core/module.modulemap`. Important bridge points include:

- `BRWallet` for key-derived addresses, UTXO state, balance, transaction creation, and signing.
- `BRPeerManager` for peer selection, bloom-filter SPV sync, block/transaction callbacks, and publish status.
- `BRTransaction`, `BRMerkleBlock`, `BRPaymentProtocol`, `BRKey`, and address helpers.
- `WalletManager.lazyPeerManager`, which hydrates persisted blocks/peers and creates the Swift peer manager.
- `NodeSelectorViewController` and `BRPeerManager.setFixedPeer`, which allow an operator-selected peer/port.

### Platform And Services

- `BRAPIClient*.swift` and `BRAPIProxy.swift` handle rates, features, wallet metadata, asset, event, and remote API paths.
- `BRHTTPServer.swift`, `BRHTTPRouter.swift`, middleware files, `BRWebSocket.swift`, and plugin files support the local web/plugin stack inherited from breadwallet.
- `BRDigiID.swift` and `BRDigiIDLegacy.swift` implement Digi-ID flows.
- `BRReplicatedKVStore.swift`, `TxMetaData.swift`, `WalletInfo.swift`, and `KVStoreCoordinator.swift` manage replicated/local metadata.

## Data Flow

### Wallet Creation And Restore

1. Onboarding creates or restores a BIP39 phrase.
2. Swift stores protected wallet state and initializes `BRWallet`.
3. `WalletManager` opens `DigiByte.sqlite`, loads persisted transactions, merkle blocks, peers, and metadata.
4. `BRPeerManager` starts from the latest persisted checkpoint/block state and syncs headers/filtered data from DigiByte peers.

### Receive And Sync

1. Swift asks `BRWallet` for a receive address and renders QR/payment UI.
2. `BRPeerManager` connects to peers, negotiates protocol, installs bloom filters, and receives merkle blocks/transactions.
3. Native callbacks update Swift with block height, balance, transaction, and publish status.
4. Swift persists changes in SQLite and updates UI state/listeners.

### Send

1. Swift parses a destination/payment request, validates amount/fee, and asks native wallet code to create/sign.
2. Native wallet code selects UTXOs, signs with seed-derived keys, and serializes the transaction.
3. `BRPeerManager` publishes the transaction to connected peers.
4. Swift records publish status and updates UI/persistence.

## DigiByte Protocol Constants

The embedded core has been audited against DigiByte Core `v8.26.2`:

| Surface | v8.26.2 value | iOS embedded-core status |
| --- | --- | --- |
| Mainnet magic | `0xdab6c3fa` | Matches |
| Testnet magic | `0xddbdc8fd` | Corrected |
| Mainnet P2P port | `12024` | Matches |
| Testnet P2P port | `12026` | Matches Swift and embedded core |
| Protocol version | `70019` | Corrected |
| Minimum peer protocol | `70017` | Matches |
| Mainnet P2PKH/P2SH | `30` / `63` plus legacy script `5` | Matches audited constants |
| Testnet P2PKH/P2SH | `126` / `140` | Corrected |
| Mainnet/testnet WIF | `128` / `254` | Corrected for testnet |
| Bech32 HRP | `dgb` / `dgbt` | Matches audited constants |

The embedded iOS core currently uses legacy mainnet DNS seeds: `seed.digibyteservers.io`, `seed2.hashdragon.com`, `dgb.cryptoservices.net`, `digiexplorer.info`, `seed1.digibyte.io`, `seed2.digibyte.io`, `seed3.digibyte.io`, and `digihash.co`. DigiByte Core `v8.26.2` uses a newer maintained seed set including `seed.digibyte.io`, `seed.diginode.tools`, `seed.digibyteblockchain.org`, `eu.digibyteseed.com`, `seed.digibyte.link`, `seed.quakeguy.com`, `seed.aroundtheblock.app`, and `seed.digibyte.services`; the iOS seed strategy should be refreshed next. Mainnet checkpoints are hardcoded through height `6309234` and still need freshness review against the current public chain.

## Configuration And Build Notes

Local audit environment:

- Xcode: `Xcode 26.5 (17F42)`.
- Current stable Core target verified from upstream releases: DigiByte Core `v8.26.2`.
- Existing uncommitted signing/entitlement edits were present before this audit and were preserved:
  - `DigiByte.xcodeproj/project.pbxproj`
  - `DigiByte/digibyte.entitlements`
  - `DigiByte TodayExtension/DigiByte TodayExtension.entitlements`

Build work performed:

- Initialized project submodules required by Xcode, including `Modules/digibytewallet-core` and nested `secp256k1`.
- Fixed plain-C `BRCore` compilation by guarding Foundation/`NSLog` use behind `__OBJC__` in embedded-core headers; C files now use the existing `printf` fallback.
- Raised legacy iOS deployment targets in the app and embedded module projects to iOS 12.0 because Xcode 26 no longer ships `libarclite` for older deployment floors.
- Renamed the DigiAssets tab-controller property from `tabs` to `assetTabs` to avoid collision with the newer UIKit `UITabBarController.tabs` API.
- `BRCore` builds successfully for `iphonesimulator` with:

```sh
xcodebuild -project DigiByte.xcodeproj -scheme BRCore -configuration Debug -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build
```

Current iOS app status:

- The iOS 26.5 simulator runtime is installed locally and `xcrun simctl list devices booted` shows `iPhone 17 (F24B7821-AF76-460E-8687-ABEFA542146D)` booted on iOS 26.5.
- The full `DigiByte` app scheme builds successfully for the iOS 26.5 simulator with:

```sh
xcodebuild -project DigiByte.xcodeproj -scheme DigiByte -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' CODE_SIGNING_ALLOWED=NO build
```

- The app installs on that simulator with bundle id `org.digibytefoundation.DigiByte`.
- Current runtime blocker: `simctl launch` starts the process, but the app exits immediately and remains on the Home Screen. Crash reports show a Debug assertion in `ApplicationController.didInitWalletManager()` at `ApplicationController.swift:249` because `walletManager` is nil during startup.
- Non-fatal build warnings remain, including a parent/app-extension `CFBundleVersion` mismatch and duplicate implicit dependency warnings around `Storez.framework`.

## Design Patterns

- C wallet core remains platform-neutral and is exposed to Swift through a Clang module rather than rewritten in Swift.
- Swift owns app orchestration and persistence; C owns deterministic wallet math, signing, transaction serialization, bloom filters, and peer/SPV state.
- Long-running network/database work is separated from UIKit state through managers, callbacks, Redux-style state, and notification/listener patterns.
- Legacy Breadwallet naming remains in some APIs (`bitcoinAmount`, `BITCOIN_TESTNET`, payment protocol names), but audited runtime constants select DigiByte network parameters.
- Service/API calls are treated as app metadata/support dependencies, separate from SPV peer validation.

## Practical Module Map

- Wallet lifecycle: `DigiByte/Source/WalletManager.swift`, `DigiByte/Source/BRCore.swift`, `Modules/digibytewallet-core/BRWallet.*`.
- Peer sync: `WalletManager.swift`, `BRCore.swift`, `Modules/digibytewallet-core/BRPeerManager.*`, `BRPeer.*`, `BRMerkleBlock.*`, `BRBloomFilter.*`.
- Network constants: `DigiByte/Source/Constants/Constants.swift`, `Modules/digibytewallet-core/BRChainParams.h`, `BRPeer.c`, `BRAddress.h`, `BRKey.c`, `BRTransaction.h`.
- Send/receive: `Sender.swift`, `PaymentRequest.swift`, `PaymentProtocol.swift`, `ViewControllers/*Send*`, `ViewControllers/*Receive*`, `BRTransaction.*`.
- Digi-ID and platform stack: `DigiIDRequest.swift`, `Platform/BRDigiID*.swift`, `Platform/BRHTTP*.swift`, `Platform/BR*Plugin.swift`.
- Persistence: `WalletManager.swift`, `KVStoreCoordinator.swift`, `Platform/BRReplicatedKVStore.swift`, SQLite-backed database paths in Swift.
- Extensions: `DigiByte TodayExtension/`, `MessagesExtension/`, `NotificationServiceExtension/`, `DigiByte WatchKit*`.

## Known Risks

- Wallet creation/restore and live SPV peer sync have not yet been walked through in the simulator; current validation proves build and install, but app launch currently crashes before onboarding.
- The launch crash must be fixed before SPV network behavior can be validated.
- Deployment targets were raised to iOS 12.0 for the app and embedded module projects, but release signing and physical-device deployment still need explicit validation.
- App-group entitlements are currently empty while code still references `group.org.digibytefoundation.DigiByte`; extension/shared-default behavior needs validation once signing is settled.
- Checkpoints and DNS seed liveness still need runtime verification against public DigiByte Core `v8.26.2` peers.
- DigiByte Core `v8.26.2` has bloom filters disabled by default unless nodes opt into `NODE_BLOOM`; SPV peer availability must be validated on live peers.
