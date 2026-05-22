# DigiDollar iOS Implementation Plan

## Purpose

This plan describes how to add DigiDollar functionality to the DigiByte iOS
wallet without breaking the existing DigiByte SPV wallet model. The goal is a
mobile DigiDollar sub-wallet that can run against the DigiDollar testnet25 /
RC41 network first, then graduate to mainnet once the protocol branch is
released and mobile validation is complete.

The implementation must be test-driven. Protocol parsing, transaction
construction, Taproot signing, wallet accounting, persistence, and UI flows all
need tests before they are used for live funds.

## Source References

Primary references in `/Users/jt/Code/digibyte`:

- `DIGIDOLLAR_ARCHITECTURE.md`
- `DIGIDOLLAR_EXPLAINER.md`
- `ARCHITECTURE.md`
- `REPO_MAP_DIGIDOLLAR.md`
- `src/primitives/transaction.h`
- `src/base58.{h,cpp}`
- `src/consensus/digidollar.{h,cpp}`
- `src/consensus/dca.{h,cpp}`
- `src/consensus/err.{h,cpp}`
- `src/digidollar/scripts.{h,cpp}`
- `src/digidollar/txbuilder.{h,cpp}`
- `src/digidollar/validation.{h,cpp}`
- `src/wallet/digidollarwallet.{h,cpp}`
- `src/wallet/ddcoincontrol.h`
- `src/wallet/spend.cpp`
- `src/wallet/rpc/wallet.cpp`
- `src/rpc/digidollar.cpp`
- `src/kernel/chainparams.cpp`
- `src/chainparamsbase.cpp`

Existing mobile references in this repo:

- `Modules/digibytewallet-core/BRTransaction.{h,c}`
- `Modules/digibytewallet-core/BRWallet.{h,c}`
- `Modules/digibytewallet-core/BRPeerManager.{h,c}`
- `Modules/digibytewallet-core/BRMerkleBlock.{h,c}`
- `Modules/digibytewallet-core/BRChainParams.h`
- `Modules/digibytewallet-core/BRDigiAsset.{h,c}`
- `DigiByte/Source/BRCore.swift`
- `DigiByte/Source/WalletManager.swift`
- `DigiByte/Source/SimpleRedux/State.swift`
- `DigiByte/Source/ModalPresenter.swift`
- `DigiByte/Source/ViewControllers/AccountViewController.swift`
- `DigiByte/Source/ViewControllers/DigiAssets/DAMainViewController.swift`

## Protocol Facts To Preserve

DigiDollar is UTXO-native. A DigiDollar token output is a zero-DGB P2TR output;
its DD value is recovered from the creating transaction's DigiDollar OP_RETURN
metadata. Mobile accounting must track token UTXOs as
`txid:vout + dd_cents + owner key/address + confirmation state`, not as normal
DGB coins.

Transaction version encoding is authoritative in
`src/primitives/transaction.h`:

- Marker mask: lower 16 bits must be `0x0770`.
- Mint version: `0x01000770`.
- Transfer version: `0x02000770`.
- Redeem version: `0x03000770`.
- There is no partial redemption transaction type.
- Emergency Redemption Ratio is handled through `DD_TX_REDEEM`.

Amounts are cents:

- `100 = $1.00 DD`.
- Minimum mint: `10000` cents.
- Maximum mint: `10000000` cents.
- Minimum DD output: `100` cents.

DigiDollar address format:

- Base58Check with a two-byte version and a 32-byte Taproot output key.
- Mainnet prefix bytes: `0x52 0x85`, displayed as `DD...`.
- Testnet prefix bytes: `0xb1 0x29`, displayed as `TD...`.
- Regtest prefix bytes: `0xa3 0xa4`, displayed as `RD...`.
- The payload is already the full P2TR output key. Do not tweak a recipient key
  again when building transfer outputs.

Mint transactions:

- Inputs: normal DGB UTXOs for collateral and fees.
- `vout[0]`: positive-value DGB collateral P2TR vault output.
- `vout[1]`: zero-DGB DD P2TR token output.
- `vout[2]`: `OP_RETURN <"DD"> <1> <ddAmount> <lockHeight> <lockTier> <ownerXOnlyPubKey>`.
- Optional later output: normal DGB change.
- Collateral output uses a NUMS internal key and Taproot script tree. Key-path
  collateral spending must be impossible.

Transfer transactions:

- Inputs: DD token inputs first, DGB fee inputs after.
- Outputs: zero-DGB P2TR DD recipient outputs, optional zero-DGB DD change,
  optional DGB change.
- Metadata: `OP_RETURN <"DD"> <2> <amount1> <amount2> ...`.
- Metadata amounts map in order to DD token outputs.
- DD conservation must be exact.
- DD inputs are confirmed-only for spending.

Redeem transactions:

- `vin[0]`: collateral vault outpoint.
- Next inputs: DD token UTXOs burned.
- Later inputs: DGB fee UTXOs.
- Collateral and DD inputs use `nSequence = 0xFFFFFFFE`.
- `nLockTime = unlockHeight`.
- `vout[0]`: full collateral returned to a normal DGB address.
- Optional DD change output if selected DD exceeds the burn requirement.
- Metadata: `OP_RETURN <"DD"> <3> <ddChange>`.

Lock tiers:

| Tier | Lock Period | Ratio |
| --- | ---: | ---: |
| 0 | 240 blocks, about 1 hour | 1000% |
| 1 | 30 days | 500% |
| 2 | 90 days | 400% |
| 3 | 180 days | 350% |
| 4 | 1 year | 300% |
| 5 | 2 years | 275% |
| 6 | 3 years | 250% |
| 7 | 5 years | 225% |
| 8 | 7 years | 212% |
| 9 | 10 years | 200% |

DCA and ERR:

- DCA multiplier comes from system-wide collateral health.
- `>=150%`: 1.00x.
- `120%-149%`: 1.25x.
- `110%-119%`: 1.50x.
- `<110%`: 2.00x.
- ERR activates below `100%` health and still requires lock expiry.
- ERR can require up to 1.25x DD burn to redeem full collateral.

## Testnet25 / RC41 Target

The DigiDollar mobile feature should initially target testnet25 / RC41.

Authoritative testnet25 parameters from Core:

- Network/datadir: `testnet25`.
- P2P port: `12032`.
- RPC port: `14026`.
- Onion port: `14126`.
- Message start bytes: `fe c5 b8 e6`.
- Embedded mobile little-endian magic value: `0xe6b8c5fe`.
- Genesis time: `1779393600`.
- Genesis hash:
  `901d46e44cd40764de5ce383717b0d6afd96190e2c6b931a4737ebc8cda96df4`.
- Genesis merkle root:
  `d3ba96686218ada443cc6ad23563b0e6a5aa4990dc8d8e6c0c3ba5dd0ef7538b`.
- DNS seeds:
  - `testnetseed.digibyte.io`
  - `testnetseed.digibyte.link`
  - `testnetseed.digibyte.services`
- Testnet DGB prefixes:
  - P2PKH: `126`
  - P2SH: `140`
  - WIF: `254`
  - Bech32 HRP: `dgbt`
  - xpub: `04 35 87 cf`
  - xprv: `04 35 83 94`
- Taproot active from genesis.
- DigiDollar BIP9 bit: `23`.
- DigiDollar minimum activation height: `600`.
- Oracle/DD activation height: `600`.
- MuSig2 active from height `0`.
- Oracle roster: 17 active keys, 35 reserved slots, 9-signature quorum.

Current iOS blockers for testnet25:

- `Modules/digibytewallet-core/BRChainParams.h` still uses the old testnet port
  `12026`, old magic `0xddbdc8fd`, no testnet DNS seeds, and an obsolete
  genesis/checkpoint.
- The committed Xcode `Testnet` configuration does not visibly define
  `-D Testnet`, so `Environment.swift` may not enter testnet mode.
- `Constants.swift` stores both mainnet and testnet as `DigiByte.sqlite`; this
  must be split before testnet25 QA.
- `BRMerkleBlock.c` currently returns before the DigiByte multi-algo PoW switch,
  making SPV block validation unsafe for RC41.

## Product Layout

DigiDollar should be a first-class wallet feature, not a hidden DigiAssets
screen and not an overload of normal DGB send/receive.

Recommended navigation:

- Add `DigiDollar` to the hamburger drawer between `DigiAssets` and `Settings`.
- Keep the existing home screen focused on DGB.
- Add a compact DigiDollar summary row on the home screen only after DD balance
  accounting is real. The row should show available DD, pending DD, and tap into
  the DigiDollar module.
- Do not add DigiDollar to the existing bottom action menu; that menu is already
  DGB-specific.

Recommended module structure:

- `DigiDollarMainViewController`
  - Full-screen modal feature shell.
  - Patterned after `DAMainViewController`, but with its own models and colors.
  - Uses a bottom tab bar or top segmented control depending on simulator review.
- `DigiDollarOverviewViewController`
  - Available DD, pending DD, locked collateral, system health, oracle price,
    DCA multiplier, ERR state, sync status.
- `DigiDollarSendViewController`
  - Recipient DD address (`DD`, `TD`, `RD` depending on network).
  - Amount in DD/USD cents.
  - DGB fee reserve and selected DD inputs.
  - Review screen and PIN/biometric confirmation.
- `DigiDollarReceiveViewController`
  - Fresh DD receive address.
  - QR code.
  - Copy/share.
  - Network-specific label so users do not send DGB to a DD address.
- `DigiDollarMintViewController`
  - DD amount.
  - Lock tier selector.
  - Required collateral calculation.
  - DGB fee and change.
  - Oracle/system health freshness.
  - Review screen and confirmation.
- `DigiDollarRedeemViewController`
  - Vault/position selector.
  - Unlock height/date.
  - Normal or ERR burn requirement.
  - Collateral return address.
  - Review screen and confirmation.
- `DigiDollarVaultViewController`
  - Positions, collateral, issued DD, lock tier, unlock height, status.
  - Position detail with redeem readiness and transaction history.
- `DigiDollarTransactionsViewController`
  - DD-only activity with mint/send/receive/redeem classification.

Initial visual direction:

- Use the existing DigiByte dark blue foundation so the feature feels native.
- Use green sparingly for peg/health/available state.
- Keep high-risk flows dense and review-focused, not marketing-like.
- Avoid ambiguous wording. Always distinguish `DGB` collateral/fees from `DD`
  stablecoin value.

## Architecture

The DigiDollar implementation should be layered so future Android work can wrap
the same C protocol library.

### Layer 1: Embedded Core Protocol Library

Add a C DigiDollar module under `Modules/digibytewallet-core`:

- `BRDigiDollar.h`
- `BRDigiDollar.c`
- `BRDigiDollarAddress.h`
- `BRDigiDollarAddress.c`
- `BRDigiDollarTx.h`
- `BRDigiDollarTx.c`
- `BRDigiDollarWallet.h`
- `BRDigiDollarWallet.c`

Responsibilities:

- Encode/decode DD Base58Check addresses.
- Detect DigiDollar transaction versions.
- Parse and build DD OP_RETURN metadata.
- Classify mint/transfer/redeem transactions.
- Build unsigned DD transactions from explicit UTXO inputs.
- Track DD token UTXOs and vault positions.
- Exclude DD token/vault/protocol outputs from normal DGB spend selection.
- Export stable C structs for Swift and future Kotlin/JNI wrappers.

The C boundary should not expose `BRWallet` internals as the public API.
Suggested public shapes:

```c
typedef enum {
    BRDigiDollarNetworkMainnet,
    BRDigiDollarNetworkTestnet,
    BRDigiDollarNetworkRegtest
} BRDigiDollarNetwork;

typedef enum {
    BRDigiDollarTxNone = 0,
    BRDigiDollarTxMint = 1,
    BRDigiDollarTxTransfer = 2,
    BRDigiDollarTxRedeem = 3
} BRDigiDollarTxType;

typedef struct {
    UInt256 txHash;
    uint32_t index;
    uint64_t amountCents;
    uint32_t height;
    int confirmed;
    int spent;
    UInt256 ownerKey;
} BRDigiDollarUTXO;

typedef struct {
    UInt256 positionId;
    UInt256 collateralTxHash;
    uint32_t collateralIndex;
    uint64_t ddAmountCents;
    uint64_t collateralSats;
    uint32_t lockTier;
    uint32_t unlockHeight;
    int redeemed;
} BRDigiDollarPosition;
```

### Layer 2: Taproot And Schnorr Foundation

DigiDollar cannot safely send, mint, or redeem until the mobile core can sign
Taproot correctly.

Required work:

- Upgrade or vendor a modern `libsecp256k1` with x-only pubkey and Schnorr
  support.
- Implement BIP340 Schnorr signing tests.
- Implement BIP341 key-path tweak/signing tests.
- Implement BIP341 script-path control block and sighash tests for collateral
  redemption.
- Extend `BRTransactionSign` or add DD-specific signing entry points.
- Keep regular DGB P2PKH/P2WPKH signing tests passing.

Do not ship UI send/mint/redeem actions until these tests are green.

### Layer 3: SPV And Network

Required SPV changes:

- Fix `BRMerkleBlock.c` so DigiByte multi-algo PoW verification is reachable and
  tested.
- Update embedded testnet params to testnet25 / RC41.
- Wire the Xcode `Testnet` build condition so `E.isTestnet` is reliable.
- Split database, keychain, peer, and checkpoint namespaces by network.
- Add testnet25 DNS seeds and optional fixed peer override for local QA.
- Add P2TR DD receive scripts, watched DD scripts, and DD outpoints to BIP37
  filters.
- Track confirmed vs pending DD UTXOs. Pending DD can display but cannot be
  selected for transfer/redeem.
- Add rescan/reorg handling for DD UTXOs and positions.

SPV limitation:

An SPV wallet cannot independently compute network-wide collateral health from
the full UTXO set. Mint/redeem screens need a read-only DigiDollar system status
provider for oracle price, total supply, total collateral, DCA multiplier, ERR
state, and freshness. That provider must never receive private keys and must be
treated as informational until the transaction is validated by peers/miners.

Status provider options:

- Preferred for testnet QA: local DigiByte Core RPC on testnet25.
- Production option: a public read-only DigiDollar status endpoint backed by
  full nodes.
- Offline/fail-closed behavior: allow receive and local balance display, block
  mint/redeem, and warn before send if system freshness cannot be checked.

### Layer 4: Swift Wallet Models

Add a Swift wrapper layer:

- `DigiDollarKit`
- `DigiDollarAddress`
- `DigiDollarAmount`
- `DigiDollarBalance`
- `DigiDollarTransaction`
- `DigiDollarPosition`
- `DigiDollarSystemStatus`
- `DigiDollarWalletStore`
- `DigiDollarTransactionBuilder`

Responsibilities:

- Convert C structs to Swift value models.
- Format cents as DD/USD.
- Keep DGB fees and DD amounts separate.
- Publish balance/status changes to UI.
- Route signing through the existing PIN/biometric flow.
- Persist records through existing SQLite patterns in `WalletManager`.

### Layer 5: UI

Add a new feature directory:

- `DigiByte/Source/ViewControllers/DigiDollar/`
- `DigiByte/Source/Views/DigiDollar/`
- `DigiByte/Source/Models/DigiDollar/`

Wire navigation through:

- `HamburgerMenuModal`
- `ModalPresenter`
- `AccountViewController.addDrawerMenus()`
- `Strings.swift` / `Localizable.strings`
- asset catalog icons

## Persistence

Add network-scoped SQLite tables:

- `dd_addresses`
  - address, x-only output key, derivation path/index, created time, network.
- `dd_utxos`
  - txid, vout, amount cents, address/key, height, timestamp, spent state,
    source tx type, network.
- `dd_positions`
  - position id, collateral outpoint, collateral sats, DD issued, lock tier,
    unlock height, owner key, state, network.
- `dd_transactions`
  - txid, type, amount cents, fee sats, height, timestamp, pending/confirmed,
    local/remote direction, network.
- `dd_system_status`
  - oracle price, health, DCA multiplier, ERR state, source, source height,
    fetched time, network.

No mainnet and testnet records may share the same store name.

## Key Derivation

Core currently derives DigiDollar keys through descriptor/bech32m wallet
destinations labeled `dd-owner` and `dd-address`; it does not expose a simple
fixed BIP32 path in the scanned implementation.

Mobile needs a deterministic and documented derivation contract before using
real funds. Implementation gate:

- Confirm whether Core will publish a fixed DigiDollar mobile path or descriptor
  mapping.
- Add vectors proving mobile derives the same x-only internal/output keys as
  Core for the same seed.
- Use separate chains for owner/vault keys and receive addresses.
- Never reuse normal DGB receive/change keys as DD owner keys without an
  explicit compatibility decision.

Until this is resolved, receive-address generation can be implemented behind
test fixtures, but minting real collateral should stay disabled.

## TDD Plan

### Baseline

Current embedded C test command:

```sh
cd /Users/jt/Code/digibytewallet-ios/Modules/digibytewallet-core
sh maketest.sh
```

Known baseline failures today:

- `BRKeyTests`
- `BRBIP32SequenceTests`
- `BRWalletTests`

Before DigiDollar tests become a regression gate, either fix these failures or
quarantine them so new DigiDollar failures are visible.

### Protocol Unit Tests

Add C tests to `Modules/digibytewallet-core/test.c`:

- DD version detection:
  - non-DD transaction
  - mint `0x01000770`
  - transfer `0x02000770`
  - redeem `0x03000770`
  - invalid type
  - invalid low marker
- DD address codec:
  - mainnet `DD`
  - testnet `TD`
  - regtest `RD`
  - wrong network
  - whitespace rejection
  - wrong payload length
- OP_RETURN parser:
  - valid mint
  - valid transfer
  - valid redeem
  - truncated payload
  - wrong magic
  - non-minimal or malformed pushdata
  - amount below min output
- Transaction classifiers:
  - zero-DGB DD P2TR outputs are token outputs only with valid DD metadata.
  - ordinary zero-DGB P2TR outputs do not inflate DD balance.
  - DD metadata outputs are never spendable DGB.

### Builder Tests

Use deterministic Core-generated vectors:

- Mint builder creates exact output order and version.
- Transfer builder maps OP_RETURN amounts to token outputs by order.
- Transfer builder creates DD change and DGB change separately.
- Redeem builder sets input order, sequence, locktime, collateral return, and
  optional DD change.
- Builder rejects pending DD inputs.
- Builder rejects insufficient DGB fee reserve.
- Builder rejects DD conservation mismatches.

### Taproot Signing Tests

Use BIP340/BIP341 vectors and Core-generated DigiDollar vectors:

- x-only pubkey generation.
- Taproot key tweak.
- Key-path spend signature for DD token input.
- Script-path spend signature for collateral normal redemption path.
- Control block reconstruction.
- Transaction witness serialization and txid/wtxid stability.

### Swift Unit Tests

Add tests under `digibyteTests`:

- `DigiDollarAddressTests`
- `DigiDollarAmountTests`
- `DigiDollarParserTests`
- `DigiDollarWalletStoreTests`
- `DigiDollarSystemStatusTests`
- `DigiDollarTransactionBuilderTests`

Run focused tests:

```sh
cd /Users/jt/Code/digibytewallet-ios
xcodebuild -project DigiByte.xcodeproj -scheme DigiByte \
  -configuration Debug -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  CODE_SIGNING_ALLOWED=NO \
  -only-testing:DigiByteTests/DigiDollarAddressTests \
  -only-testing:DigiByteTests/DigiDollarParserTests test
```

### UI Tests

Extend `DigiByte UI Smoke`:

- Wallet launches to home.
- Hamburger menu opens.
- DigiDollar entry opens the DigiDollar module.
- Overview renders empty-state and testnet badge.
- Receive shows a `TD...` address on testnet25.
- Send rejects DGB addresses and wrong-network DD addresses.
- Mint disables action when system status is stale.
- Redeem disables locked positions.

Run:

```sh
xcodebuild -project DigiByte.xcodeproj -scheme 'DigiByte UI Smoke' \
  -configuration Debug -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  CODE_SIGNING_ALLOWED=NO test
```

### Simulator QA

The simulator must be launched visibly for manual QA:

```sh
open -a Simulator
xcrun simctl boot F24B7821-AF76-460E-8687-ABEFA542146D || true
```

Build, install, and launch:

```sh
DERIVED=/tmp/digibytewallet-dd-qa
xcodebuild -project DigiByte.xcodeproj -scheme DigiByte \
  -configuration Debug -sdk iphonesimulator \
  -destination 'id=F24B7821-AF76-460E-8687-ABEFA542146D' \
  -derivedDataPath "$DERIVED" CODE_SIGNING_ALLOWED=NO build
xcrun simctl install F24B7821-AF76-460E-8687-ABEFA542146D \
  "$DERIVED/Build/Products/Debug-iphonesimulator/DigiByte.app"
xcrun simctl launch F24B7821-AF76-460E-8687-ABEFA542146D \
  org.digibytefoundation.DigiByte
```

Capture logs:

```sh
xcrun simctl spawn F24B7821-AF76-460E-8687-ABEFA542146D log stream \
  --style compact --predicate 'process == "DigiByte"'
```

## Implementation Phases And Commit Boundaries

Each phase should be a separate local commit with tests or a documented blocker.

1. Plan and architecture gate.
   - Add this plan.
   - No runtime behavior changes.

2. Baseline test cleanup.
   - Fix or quarantine current C test failures.
   - Document exact remaining baseline gaps.

3. Testnet25 network foundation.
   - Update embedded testnet25 params.
   - Wire `Testnet` Swift compilation condition.
   - Split testnet storage.
   - Fix multi-algo SPV PoW return path.
   - Prove simulator can attempt peers on port `12032`.

4. DigiDollar protocol parser.
   - Add DD address codec.
   - Add DD version/type helpers.
   - Add DD OP_RETURN parser.
   - Add classification tests.

5. DigiDollar wallet accounting.
   - Track DD UTXOs and vault positions.
   - Prevent normal DGB spend selection from using DD token/vault outputs.
   - Add persistence and reorg/rescan tests.

6. Taproot signing foundation.
   - Upgrade or vendor modern secp256k1 modules.
   - Add Schnorr/x-only/tweak tests.
   - Add P2TR key-path token signing.
   - Add P2TR script-path collateral signing.

7. Receive DD.
   - Implement deterministic DD receive keys once derivation is resolved.
   - Generate network-correct `DD`/`TD`/`RD` addresses.
   - Show QR and copy/share UI.
   - Add UI tests.

8. Send DD.
   - Build transfer transactions.
   - Select confirmed DD UTXOs and DGB fee UTXOs separately.
   - Sign token inputs.
   - Broadcast through SPV peer manager.
   - Add negative tests for wrong address/network/amount/pending inputs.

9. System status provider.
   - Add read-only local Core RPC provider for testnet QA.
   - Add status freshness model.
   - Add fail-closed mint/redeem gating.
   - Keep keys and seed fully local.

10. Mint DD.
    - Calculate collateral with oracle price, lock tier, DCA, and safety margin.
    - Build mint transaction and local position record.
    - Sign normal DGB funding inputs.
    - Broadcast and track pending/confirmed state.

11. Vault and redeem.
    - List positions.
    - Calculate normal/ERR burn requirement.
    - Build redeem transaction after unlock height.
    - Sign DD token inputs and collateral script-path input.
    - Track closed positions and returned collateral.

12. UI polish and manual QA.
    - Finalize tab layout.
    - Review simulator screens for text fit and clarity.
    - Run unit, UI, and live testnet25 smoke tests.
    - Record every command, commit, blocker, and remaining risk.

## Open Decisions

These must be resolved before full fund-moving support:

- Fixed DigiDollar mobile HD derivation path or descriptor compatibility vector.
- Whether production mobile uses a read-only DigiDollar status service, user
  supplied Core RPC, compact filters, or another full-node-assisted model for
  system health.
- Final mobile URI format for DD payment requests. It must not collide with
  normal `digibyte:` DGB requests.
- Exact policy for enabling DigiDollar on mainnet builds. Until the release
  branch is final, keep it gated to testnet25/debug builds.
- Whether to port the full Core transaction builder logic or maintain a smaller
  mobile builder proven by Core vector tests. The default should be a smaller C
  builder with byte-for-byte vectors.

## Initial Success Criteria

The first usable milestone is not mint/redeem. It is a safe testnet25 shell:

- Simulator launches visibly.
- App runs in network-separated testnet25 mode.
- SPV peer manager attempts RC41 peers on port `12032`.
- DigiDollar menu item opens a real module.
- Overview shows empty DD balance and testnet25 status.
- Receive shows a deterministic `TD...` address generated from tested core code.
- All DD protocol parser/address tests pass.
- Normal DGB wallet send/receive tests still pass.

The first fund-moving milestone is:

- Send DD on testnet25 using confirmed DD token UTXOs.
- DGB fee UTXOs remain separate.
- Signed transaction matches Core parser expectations.
- Peer broadcast is attempted.
- Logs show no crash, address mismatch, or protocol disconnect caused by local
  serialization/signing.

The full milestone is:

- Mint, send, receive, vault display, and redeem all work on testnet25.
- Simulator QA covers fresh wallet and restored wallet.
- Local Core RPC confirms all transaction types.
- iOS logs are clean of crashes, database/keychain errors, and protocol errors.
- Every phase is locally committed with a clear message.
