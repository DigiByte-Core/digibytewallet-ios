//
//  DigiDollarProtocol.swift
//  DigiByte
//
//  Swift facade over BRDigiDollar protocol primitives.
//

import Foundation
import BRCore

struct DigiDollarNetworkStatus: Equatable {
    let oraclePriceMicroUSD: UInt64
    let systemHealth: Int32
    let oracleAvailable: Bool
    let oracleStatus: String
    let mintingRestrictedReason: String?
    let source: String

    var priceUSDString: String {
        let whole = oraclePriceMicroUSD / 1_000_000
        let fraction = oraclePriceMicroUSD % 1_000_000
        return "\(whole).\(String(format: "%06llu", fraction))"
    }

    var mintingAvailable: Bool {
        return oracleAvailable && oraclePriceMicroUSD > 0 && mintingRestrictedReason == nil
    }

    static func parse(json data: Data, source: String = "DigiByte Core RPC") -> DigiDollarNetworkStatus? {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
              let dictionary = object as? [String: Any] else { return nil }

        let result = (dictionary["result"] as? [String: Any]) ?? dictionary
        guard let oraclePrice = uint64Value(result["oracle_price_micro_usd"]),
              let health = int32Value(result["health_percentage"] ?? result["system_collateral_ratio"]) else { return nil }

        return DigiDollarNetworkStatus(oraclePriceMicroUSD: oraclePrice,
                                       systemHealth: health,
                                       oracleAvailable: boolValue(result["oracle_available"]) ?? (oraclePrice > 0),
                                       oracleStatus: stringValue(result["oracle_status"]) ?? stringValue(result["status"]) ?? "unknown",
                                       mintingRestrictedReason: restrictionValue(result["minting_restricted_reason"]),
                                       source: source)
    }

    private static func stringValue(_ value: Any?) -> String? {
        if let value = value as? String, !value.isEmpty { return value }
        return nil
    }

    private static func restrictionValue(_ value: Any?) -> String? {
        guard let value = stringValue(value)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else { return nil }

        switch value.lowercased() {
        case "none", "null", "no", "false", "0":
            return nil
        default:
            return value
        }
    }

    private static func uint64Value(_ value: Any?) -> UInt64? {
        if let value = value as? UInt64 { return value }
        if let value = value as? Int, value >= 0 { return UInt64(value) }
        if let value = value as? NSNumber, value.int64Value >= 0 { return UInt64(value.int64Value) }
        if let value = value as? String { return UInt64(value) }
        return nil
    }

    private static func int32Value(_ value: Any?) -> Int32? {
        if let value = value as? Int, value >= Int(Int32.min), value <= Int(Int32.max) { return Int32(value) }
        if let value = value as? NSNumber, value.int64Value >= Int64(Int32.min), value.int64Value <= Int64(Int32.max) {
            return Int32(value.int64Value)
        }
        if let value = value as? String { return Int32(value) }
        return nil
    }

    private static func boolValue(_ value: Any?) -> Bool? {
        if let value = value as? Bool { return value }
        if let value = value as? NSNumber { return value.boolValue }
        if let value = value as? String {
            switch value.lowercased() {
            case "true", "yes", "1": return true
            case "false", "no", "0": return false
            default: return nil
            }
        }
        return nil
    }
}

final class DigiDollarStatusService {
    static let shared = DigiDollarStatusService()

    private let session: URLSession
    private let environment: [String: String]

    init(session: URLSession = .shared, environment: [String: String] = ProcessInfo.processInfo.environment) {
        self.session = session
        self.environment = environment
    }

    func load(completion: @escaping (DigiDollarNetworkStatus?) -> Void) {
        guard let request = rpcRequest(method: "getdigidollarstats") else {
            completion(nil)
            return
        }

        session.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(DigiDollarNetworkStatus.parse(json: data))
        }.resume()
    }

    private func rpcRequest(method: String) -> URLRequest? {
        guard E.isDebug,
              let urlString = environment["DGB_DIGIDOLLAR_RPC_URL"],
              let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 8.0
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let user = environment["DGB_DIGIDOLLAR_RPC_USER"],
           let password = environment["DGB_DIGIDOLLAR_RPC_PASSWORD"],
           let credentials = "\(user):\(password)".data(using: .utf8)?.base64EncodedString() {
            request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        }
        let body: [String: Any] = ["jsonrpc": "1.0", "id": "digibytewallet-ios", "method": method, "params": []]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        return request
    }
}

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

    var displayName: String {
        switch self {
        case .none: return "DigiDollar"
        case .mint: return "DigiDollar Mint"
        case .transfer: return "DigiDollar Transfer"
        case .redeem: return "DigiDollar Redeem"
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
    static let testnet25ActivationHeight: UInt32 = 600

    static func version(for type: DigiDollarTransactionType, flags: UInt8 = 0) -> UInt32 {
        return BRDigiDollarMakeVersion(type.cValue, flags)
    }

    static func activationHeight(for network: DigiDollarNetwork = currentNetwork) -> UInt32? {
        switch network {
        case .testnet: return testnet25ActivationHeight
        case .regtest: return 0
        case .mainnet: return nil
        }
    }

    static func isActivated(at height: UInt32, network: DigiDollarNetwork = currentNetwork) -> Bool {
        guard let activationHeight = activationHeight(for: network) else { return false }
        return height >= activationHeight
    }

    static func type(forVersion version: UInt32) -> DigiDollarTransactionType {
        return DigiDollarTransactionType(BRDigiDollarTypeForVersion(version))
    }

    static func flags(forVersion version: UInt32) -> UInt8 {
        return BRDigiDollarFlagsForVersion(version)
    }

    static func formattedAmount(cents: UInt64) -> String {
        return "\(cents / 100).\(String(format: "%02llu", cents % 100)) DD"
    }

    static func netAmountText(receivedCents: UInt64, sentCents: UInt64) -> String {
        if sentCents > receivedCents {
            return "-\(formattedAmount(cents: sentCents - receivedCents))"
        }

        return "+\(formattedAmount(cents: receivedCents - sentCents))"
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
