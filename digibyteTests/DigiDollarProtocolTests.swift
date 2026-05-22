//
//  DigiDollarProtocolTests.swift
//  digibyteTests
//
//  Tests for the Swift-facing DigiDollar protocol facade.
//

import XCTest
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

    func testLockTierSchedule() {
        XCTAssertEqual(DigiDollarProtocol.lockTiers.count, 10)
        XCTAssertEqual(DigiDollarProtocol.lockTiers[0].blocks, 240)
        XCTAssertEqual(DigiDollarProtocol.lockTiers[0].collateralRatioPercent, 1000)
        XCTAssertEqual(DigiDollarProtocol.lockTiers[9].blocks, 21_024_000)
        XCTAssertEqual(DigiDollarProtocol.lockTiers[9].collateralRatioPercent, 200)
    }
}
