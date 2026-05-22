//
//  DigiDollarProtocol.swift
//  DigiByte
//
//  Swift facade over BRDigiDollar protocol primitives.
//

import Foundation
import BRCore

enum DigiDollarNetwork: Equatable {
    case mainnet
    case testnet
    case regtest

    fileprivate var cValue: BRDigiDollarNetwork {
        switch self {
        case .mainnet: return BRDigiDollarMainNet
        case .testnet: return BRDigiDollarTestNet
        case .regtest: return BRDigiDollarRegTest
        }
    }

    fileprivate init?(_ cValue: BRDigiDollarNetwork) {
        switch cValue {
        case BRDigiDollarMainNet: self = .mainnet
        case BRDigiDollarTestNet: self = .testnet
        case BRDigiDollarRegTest: self = .regtest
        default: return nil
        }
    }

    var displayName: String {
        switch self {
        case .mainnet: return "Mainnet"
        case .testnet: return "RC41 Testnet25"
        case .regtest: return "Regtest"
        }
    }
}

enum DigiDollarTransactionType: Equatable {
    case none
    case mint
    case transfer
    case redeem

    fileprivate var cValue: BRDigiDollarTxType {
        switch self {
        case .none: return BRDigiDollarTxNone
        case .mint: return BRDigiDollarTxMint
        case .transfer: return BRDigiDollarTxTransfer
        case .redeem: return BRDigiDollarTxRedeem
        }
    }

    fileprivate init(_ cValue: BRDigiDollarTxType) {
        switch cValue {
        case BRDigiDollarTxMint: self = .mint
        case BRDigiDollarTxTransfer: self = .transfer
        case BRDigiDollarTxRedeem: self = .redeem
        default: self = .none
        }
    }
}

struct DigiDollarOpReturnMetadata: Equatable {
    let type: DigiDollarTransactionType
    let amounts: [UInt64]
    let lockHeight: UInt64
    let lockTier: UInt32
    let ownerXOnlyPubKey: [UInt8]?
}

struct DigiDollarLockTier: Equatable {
    let index: Int
    let blocks: UInt64
    let collateralRatioPercent: UInt32
}

enum DigiDollarProtocol {
    static let outputKeyLength = 32
    static let currentNetwork: DigiDollarNetwork = E.isTestnet ? .testnet : .mainnet

    static func version(for type: DigiDollarTransactionType, flags: UInt8 = 0) -> UInt32 {
        return BRDigiDollarMakeVersion(type.cValue, flags)
    }

    static func type(forVersion version: UInt32) -> DigiDollarTransactionType {
        return DigiDollarTransactionType(BRDigiDollarTypeForVersion(version))
    }

    static func flags(forVersion version: UInt32) -> UInt8 {
        return BRDigiDollarFlagsForVersion(version)
    }

    static func address(forOutputKey outputKey: [UInt8], network: DigiDollarNetwork = currentNetwork) -> String? {
        guard outputKey.count == outputKeyLength else { return nil }

        var key = outputKey
        var address = [CChar](repeating: 0, count: 96)
        let written = key.withUnsafeBufferPointer { keyPtr -> Int in
            guard let base = keyPtr.baseAddress else { return 0 }
            return BRDigiDollarAddressEncode(&address, address.count, network.cValue, base)
        }

        guard written > 0 else { return nil }
        return String(cString: address)
    }

    static func decodeAddress(_ address: String) -> (network: DigiDollarNetwork, outputKey: [UInt8])? {
        var key = [UInt8](repeating: 0, count: outputKeyLength)
        var network = BRDigiDollarMainNet
        let decoded = address.withCString {
            BRDigiDollarAddressDecode(&key, &network, $0)
        }

        guard decoded != 0, let swiftNetwork = DigiDollarNetwork(network) else { return nil }
        return (swiftNetwork, key)
    }

    static func isValidAddress(_ address: String, network: DigiDollarNetwork? = nil) -> Bool {
        return address.withCString { cAddress in
            if let network = network {
                return BRDigiDollarAddressIsValidForNetwork(cAddress, network.cValue) != 0
            }
            return BRDigiDollarAddressIsValid(cAddress) != 0
        }
    }

    static func p2trScriptPubKey(forOutputKey outputKey: [UInt8]) -> Data? {
        guard outputKey.count == outputKeyLength else { return nil }

        var key = outputKey
        var script = [UInt8](repeating: 0, count: 34)
        let written = key.withUnsafeBufferPointer { keyPtr -> Int in
            guard let base = keyPtr.baseAddress else { return 0 }
            return BRDigiDollarP2TRScriptPubKey(&script, script.count, base)
        }

        guard written > 0 else { return nil }
        return Data(script.prefix(written))
    }

    static func buildMintOpReturn(amount: UInt64, lockHeight: UInt64, lockTier: UInt32, ownerXOnlyPubKey: [UInt8]) -> Data? {
        guard ownerXOnlyPubKey.count == outputKeyLength else { return nil }

        var ownerKey = ownerXOnlyPubKey
        var script = [UInt8](repeating: 0, count: 96)
        let written = ownerKey.withUnsafeBufferPointer { keyPtr -> Int in
            guard let base = keyPtr.baseAddress else { return 0 }
            return BRDigiDollarBuildMintOpReturn(&script, script.count, amount, lockHeight, lockTier, base)
        }

        guard written > 0 else { return nil }
        return Data(script.prefix(written))
    }

    static func buildTransferOpReturn(amounts: [UInt64]) -> Data? {
        guard !amounts.isEmpty else { return nil }

        var transferAmounts = amounts
        var script = [UInt8](repeating: 0, count: 128)
        let written = transferAmounts.withUnsafeBufferPointer { amountPtr -> Int in
            guard let base = amountPtr.baseAddress else { return 0 }
            return BRDigiDollarBuildTransferOpReturn(&script, script.count, base, transferAmounts.count)
        }

        guard written > 0 else { return nil }
        return Data(script.prefix(written))
    }

    static func buildRedeemOpReturn(ddChange: UInt64) -> Data? {
        var script = [UInt8](repeating: 0, count: 64)
        let written = BRDigiDollarBuildRedeemOpReturn(&script, script.count, ddChange)
        guard written > 0 else { return nil }
        return Data(script.prefix(written))
    }

    static func parseOpReturn(_ script: Data) -> DigiDollarOpReturnMetadata? {
        var metadata = BRDigiDollarOpReturn()
        let parsed = script.withUnsafeBytes { bytes -> Int32 in
            guard let base = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
            return BRDigiDollarParseOpReturn(&metadata, base, script.count)
        }

        guard parsed != 0 else { return nil }

        var amounts: [UInt64] = []
        withUnsafeBytes(of: &metadata.amounts) { rawAmounts in
            let typedAmounts = rawAmounts.bindMemory(to: UInt64.self)
            amounts = Array(typedAmounts.prefix(Int(metadata.amountCount)))
        }

        var ownerKey: [UInt8]? = nil
        if metadata.hasOwnerXOnlyPubKey != 0 {
            withUnsafeBytes(of: &metadata.ownerXOnlyPubKey) { rawKey in
                ownerKey = Array(rawKey.bindMemory(to: UInt8.self).prefix(outputKeyLength))
            }
        }

        return DigiDollarOpReturnMetadata(type: DigiDollarTransactionType(metadata.type),
                                          amounts: amounts,
                                          lockHeight: metadata.lockHeight,
                                          lockTier: metadata.lockTier,
                                          ownerXOnlyPubKey: ownerKey)
    }

    static var lockTiers: [DigiDollarLockTier] {
        let count = BRDigiDollarLockTierCount()
        return (0..<count).map { index in
            DigiDollarLockTier(index: index,
                               blocks: BRDigiDollarLockTierBlocks(index),
                               collateralRatioPercent: BRDigiDollarCollateralRatioForLockTier(index))
        }
    }

    static func dcaMultiplierBps(systemHealth: Int32) -> UInt32 {
        return BRDigiDollarDCAMultiplierBps(systemHealth)
    }

    static func errRatioBps(systemHealth: Int32) -> UInt32 {
        return BRDigiDollarERRRatioBps(systemHealth)
    }

    static func errRequiredBurn(originalAmountCents: UInt64, systemHealth: Int32) -> UInt64 {
        return BRDigiDollarERRRequiredBurn(originalAmountCents, systemHealth)
    }

    static func effectiveCollateralRatio(baseRatio: UInt32, systemHealth: Int32) -> UInt32 {
        return BRDigiDollarEffectiveCollateralRatio(baseRatio, systemHealth)
    }

    static func requiredCollateral(amountCents: UInt64,
                                   lockTier: UInt32,
                                   oraclePriceMicroUSD: UInt64,
                                   systemHealth: Int32,
                                   includeSafetyMargin: Bool = true) -> UInt64 {
        if includeSafetyMargin {
            return BRDigiDollarRequiredCollateralWithSafetyMargin(amountCents,
                                                                 lockTier,
                                                                 oraclePriceMicroUSD,
                                                                 systemHealth)
        } else {
            return BRDigiDollarRequiredCollateral(amountCents,
                                                 lockTier,
                                                 oraclePriceMicroUSD,
                                                 systemHealth)
        }
    }

    static func mintLockHeight(currentBlockHeight: UInt32, lockTier: UInt32) -> UInt64 {
        return BRDigiDollarMintLockHeight(currentBlockHeight, lockTier)
    }
}
