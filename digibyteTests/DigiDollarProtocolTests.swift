//
//  DigiDollarProtocolTests.swift
//  digibyteTests
//
//  Tests for the Swift-facing DigiDollar protocol facade.
//

import XCTest
import BRCore
@testable import DigiByte

class DigiDollarProtocolTests: XCTestCase {

    private let outputKey = Array(UInt8(0)..<UInt8(32))

    func testAddressVectorsRoundTrip() {
        let mainnetAddress = DigiDollarProtocol.address(forOutputKey: outputKey, network: .mainnet)
        let testnetAddress = DigiDollarProtocol.address(forOutputKey: outputKey, network: .testnet)

        XCTAssertEqual(mainnetAddress, "DD1EtoDkrT4aJdAL7167x3tLP2fq42kCEaPVGhd8QfVtevfcNXTf")
        XCTAssertEqual(testnetAddress, "TD1Jiu7vYexR3NwqkoFreqNSn4G9Hyij99mMXQkqafotiyMEufdM")
        XCTAssertTrue(DigiDollarProtocol.isValidAddress(testnetAddress!, network: .testnet))
        XCTAssertFalse(DigiDollarProtocol.isValidAddress(testnetAddress!, network: .mainnet))

        let decoded = DigiDollarProtocol.decodeAddress(testnetAddress!)
        XCTAssertEqual(decoded?.network, .testnet)
        XCTAssertEqual(decoded?.outputKey, outputKey)
    }

    func testTransactionVersionVectors() {
        XCTAssertEqual(DigiDollarProtocol.version(for: .mint), 0x01000770)
        XCTAssertEqual(DigiDollarProtocol.version(for: .transfer), 0x02000770)
        XCTAssertEqual(DigiDollarProtocol.version(for: .redeem), 0x03000770)
        XCTAssertEqual(DigiDollarProtocol.type(forVersion: 0x0D1D0770), .none)
        XCTAssertEqual(DigiDollarProtocol.type(forVersion: 0x02030770), .transfer)
        XCTAssertEqual(DigiDollarProtocol.flags(forVersion: 0x02030770), 3)
    }

    func testMintOpReturnRoundTrip() {
        let script = DigiDollarProtocol.buildMintOpReturn(amount: 100_00,
                                                          lockHeight: 600 + 240,
                                                          lockTier: 0,
                                                          ownerXOnlyPubKey: outputKey)
        XCTAssertNotNil(script)

        let metadata = DigiDollarProtocol.parseOpReturn(script!)
        XCTAssertEqual(metadata?.type, .mint)
        XCTAssertEqual(metadata?.amounts, [100_00])
        XCTAssertEqual(metadata?.lockHeight, 840)
        XCTAssertEqual(metadata?.lockTier, 0)
        XCTAssertEqual(metadata?.ownerXOnlyPubKey, outputKey)
    }

    func testTransferAndRedeemOpReturnsRoundTrip() {
        let transfer = DigiDollarProtocol.buildTransferOpReturn(amounts: [125_00, 875_00])
        let redeem = DigiDollarProtocol.buildRedeemOpReturn(ddChange: 25_00)

        XCTAssertEqual(DigiDollarProtocol.parseOpReturn(transfer!)?.type, .transfer)
        XCTAssertEqual(DigiDollarProtocol.parseOpReturn(transfer!)?.amounts, [125_00, 875_00])
        XCTAssertEqual(DigiDollarProtocol.parseOpReturn(redeem!)?.type, .redeem)
        XCTAssertEqual(DigiDollarProtocol.parseOpReturn(redeem!)?.amounts, [25_00])
        XCTAssertNil(DigiDollarProtocol.buildRedeemOpReturn(ddChange: 0))
    }

    func testP2TRScriptPubKeyVector() {
        guard let script = DigiDollarProtocol.p2trScriptPubKey(forOutputKey: outputKey) else {
            XCTFail("Expected P2TR script")
            return
        }

        XCTAssertEqual(script.count, 34)
        XCTAssertEqual(Array(script.prefix(2)), [0x51, 0x20])
        XCTAssertEqual(Array(script.dropFirst(2)), outputKey)
    }

    func testWalletReceiveAddressUsesExternalXOnlyKey() {
        var seed = UInt128(u8: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15))
        let mpk = withUnsafePointer(to: &seed) {
            BRBIP32MasterPubKey($0, MemoryLayout<UInt128>.stride)
        }
        guard let wallet = BRWalletNew(nil, 0, mpk) else {
            XCTFail("Expected wallet")
            return
        }
        defer { BRWalletFree(wallet) }

        let address = BRWalletDigiDollarReceiveAddress(wallet).description
        let decoded = DigiDollarProtocol.decodeAddress(address)
        var pubKey = [UInt8](repeating: 0, count: Int(BRBIP32PubKey(nil, 0, mpk, UInt32(SEQUENCE_EXTERNAL_CHAIN), 0)))
        BRBIP32PubKey(&pubKey, pubKey.count, mpk, UInt32(SEQUENCE_EXTERNAL_CHAIN), 0)

        XCTAssertEqual(decoded?.network, DigiDollarProtocol.currentNetwork)
        XCTAssertEqual(decoded?.outputKey, Array(pubKey.dropFirst()))
        XCTAssertTrue(address.hasPrefix(E.isTestnet ? "TD" : "DD"))
    }

    func testWalletDigiDollarAccountingAccessors() {
        var seed = UInt128(u8: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15))
        let mpk = withUnsafePointer(to: &seed) {
            BRBIP32MasterPubKey($0, MemoryLayout<UInt128>.stride)
        }
        let receiveKey = derivedOutputKey(mpk: mpk, chain: UInt32(SEQUENCE_EXTERNAL_CHAIN), index: 0)
        let changeKey = derivedOutputKey(mpk: mpk, chain: UInt32(SEQUENCE_INTERNAL_CHAIN), index: 0)
        let externalKey = Array(UInt8(0xa0)..<UInt8(0xc0))
        let mintHash = makeHash(0x20)
        let transferHash = makeHash(0x30)
        guard let mintTx = makeMintTx(txHash: mintHash, outputKey: receiveKey),
              let transferTx = makeTransferTx(txHash: transferHash,
                                              inputHash: mintHash,
                                              externalKey: externalKey,
                                              changeKey: changeKey),
              let wallet = BRWallet(transactions: [mintTx, transferTx],
                                    masterPubKey: mpk,
                                    listener: TestWalletListener()) else {
            XCTFail("Expected wallet with DigiDollar transactions")
            return
        }

        XCTAssertEqual(wallet.digiDollarBalanceCents, 4_000)
        XCTAssertEqual(wallet.digiDollarAmountReceivedFromTx(mintTx), 10_000)
        XCTAssertEqual(wallet.digiDollarAmountSentByTx(transferTx), 10_000)
        XCTAssertEqual(wallet.digiDollarAmountReceivedFromTx(transferTx), 4_000)
        XCTAssertEqual(wallet.digiDollarBalanceAfterTx(transferTx), 4_000)
        XCTAssertEqual(wallet.digiDollarUtxos.count, 1)
        XCTAssertEqual(wallet.digiDollarUtxos[0].txHash, transferHash)
        XCTAssertEqual(wallet.digiDollarUtxos[0].index, 1)
        XCTAssertEqual(wallet.digiDollarUtxos[0].amountCents, 4_000)
        XCTAssertEqual(wallet.digiDollarUtxos[0].ownerXOnlyPubKey, changeKey)
    }

    func testAmountParserRejectsOverflow() {
        XCTAssertEqual(DigiDollarAmountParser.cents(from: "1"), 100)
        XCTAssertEqual(DigiDollarAmountParser.cents(from: "1.05"), 105)
        XCTAssertNil(DigiDollarAmountParser.cents(from: "18446744073709551615"))
        XCTAssertNil(DigiDollarAmountParser.cents(from: "1.234"))
    }

    func testLockTierSchedule() {
        XCTAssertEqual(DigiDollarProtocol.lockTiers.count, 10)
        XCTAssertEqual(DigiDollarProtocol.lockTiers[0].blocks, 240)
        XCTAssertEqual(DigiDollarProtocol.lockTiers[0].collateralRatioPercent, 1000)
        XCTAssertEqual(DigiDollarProtocol.lockTiers[9].blocks, 21_024_000)
        XCTAssertEqual(DigiDollarProtocol.lockTiers[9].collateralRatioPercent, 200)
    }

    private func makeHash(_ firstByte: UInt8) -> UInt256 {
        var hash = UInt256()
        withUnsafeMutableBytes(of: &hash) { rawHash in
            rawHash[0] = firstByte
        }
        return hash
    }

    private func derivedOutputKey(mpk: BRMasterPubKey, chain: UInt32, index: UInt32) -> [UInt8] {
        var pubKey = [UInt8](repeating: 0, count: Int(BRBIP32PubKey(nil, 0, mpk, chain, index)))
        BRBIP32PubKey(&pubKey, pubKey.count, mpk, chain, index)
        return Array(pubKey.dropFirst())
    }

    private func addSignedInput(to tx: BRTxRef, hash: UInt256, index: UInt32) {
        var script = [UInt8(OP_1)]
        var signature = [UInt8(OP_1)]
        var witness = [UInt8(OP_1)]
        script.withUnsafeBufferPointer { scriptPtr in
            signature.withUnsafeBufferPointer { signaturePtr in
                witness.withUnsafeBufferPointer { witnessPtr in
                    BRTransactionAddInput(tx, hash, index, 1,
                                          scriptPtr.baseAddress, script.count,
                                          signaturePtr.baseAddress, signature.count,
                                          witnessPtr.baseAddress, witness.count,
                                          TXIN_SEQUENCE)
                }
            }
        }
    }

    private func makeMintTx(txHash: UInt256, outputKey: [UInt8]) -> BRTxRef? {
        guard let tx = BRTransactionNew(),
              let collateralScript = DigiDollarProtocol.p2trScriptPubKey(forOutputKey: Array(repeating: 0x42, count: 32)),
              let tokenScript = DigiDollarProtocol.p2trScriptPubKey(forOutputKey: outputKey),
              let opReturn = DigiDollarProtocol.buildMintOpReturn(amount: 10_000,
                                                                   lockHeight: 340,
                                                                   lockTier: 0,
                                                                   ownerXOnlyPubKey: outputKey) else { return nil }
        tx.pointee.txHash = txHash
        tx.pointee.version = DigiDollarProtocol.version(for: .mint)
        tx.pointee.blockHeight = 100
        tx.pointee.timestamp = 1
        addSignedInput(to: tx, hash: makeHash(0x10), index: 0)
        tx.addOutput(amount: UInt64(SATOSHIS), script: Array(collateralScript))
        tx.addOutput(amount: 0, script: Array(tokenScript))
        tx.addOutput(amount: 0, script: Array(opReturn))
        return tx
    }

    private func makeTransferTx(txHash: UInt256,
                                inputHash: UInt256,
                                externalKey: [UInt8],
                                changeKey: [UInt8]) -> BRTxRef? {
        guard let tx = BRTransactionNew(),
              let externalScript = DigiDollarProtocol.p2trScriptPubKey(forOutputKey: externalKey),
              let changeScript = DigiDollarProtocol.p2trScriptPubKey(forOutputKey: changeKey),
              let opReturn = DigiDollarProtocol.buildTransferOpReturn(amounts: [6_000, 4_000]) else { return nil }
        tx.pointee.txHash = txHash
        tx.pointee.version = DigiDollarProtocol.version(for: .transfer)
        tx.pointee.blockHeight = 101
        tx.pointee.timestamp = 2
        addSignedInput(to: tx, hash: inputHash, index: 1)
        tx.addOutput(amount: 0, script: Array(externalScript))
        tx.addOutput(amount: 0, script: Array(changeScript))
        tx.addOutput(amount: 0, script: Array(opReturn))
        return tx
    }
}

private final class TestWalletListener: BRWalletListener {
    func balanceChanged(_ balance: UInt64) {}
    func txAdded(_ tx: BRTxRef) {}
    func txUpdated(_ txHashes: [UInt256], blockHeight: UInt32, timestamp: UInt32) {}
    func txDeleted(_ txHash: UInt256, notifyUser: Bool, recommendRescan: Bool) {}
}
