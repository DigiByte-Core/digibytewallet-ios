//
//  State.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-24.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

struct State {
    let isStartFlowVisible: Bool
    let isLoginRequired: Bool
    let rootModal: RootModal
    let hamburgerModal: HamburgerMenuModal
    let walletState: WalletState
    let isBtcSwapped: Bool
    let currentRate: Rate?
    let rates: [Rate]
    let alert: AlertType?
    let isBiometricsEnabled: Bool
    let defaultCurrencyCode: String
    let recommendRescan: Bool
    let isLoadingTransactions: Bool
    let maxDigits: Int
    let isPushNotificationsEnabled: Bool
    let isPromptingBiometrics: Bool
    let pinLength: Int
    let fees: Fees
}

extension State {
    static var initial: State {
        return State(   isStartFlowVisible: false,
                        isLoginRequired: true,
                        rootModal: .none,
                        hamburgerModal: .none,
                        walletState: WalletState.initial,
                        isBtcSwapped: UserDefaults.isBtcSwapped,
                        currentRate: UserDefaults.currentRate,
                        rates: [],
                        alert: nil,
                        isBiometricsEnabled: UserDefaults.isBiometricsEnabled,
                        defaultCurrencyCode: UserDefaults.defaultCurrencyCode,
                        recommendRescan: false,
                        isLoadingTransactions: false,
                        maxDigits: UserDefaults.maxDigits,
                        isPushNotificationsEnabled: UserDefaults.pushToken != nil,
                        isPromptingBiometrics: false,
                        pinLength: 6,
                        fees: Fees.defaultFees)
    }
}

enum RootModal {
    case none
    case send
    case showAddress
    case showAddressBook
    case receive
    
    case loginAddress
    case loginScan
    case manageWallet
    case requestAmount
}

enum AssetMenuAction: Equatable {
    case showTx(AssetId, Transaction?)
    case send(AssetId)
    case burn(AssetId)

    static func ==(lhs: AssetMenuAction, rhs: AssetMenuAction) -> Bool {
        switch (lhs, rhs) {
        case (let .showTx(a1, t1), let .showTx(a2, t2)):
            return a1 == a2 && t1 == t2
        case (let .send(str1), let .send(str2)):
            return str1 == str2
        case (let .burn(str1), let .burn(str2)):
            return str1 == str2
        default:
            return false
        }
    }
}

enum HamburgerMenuModal: Equatable {
    case none
    case securityCenter
    case support
    case settings
    case digiAssets(AssetMenuAction? = nil)
    case digiDollar
    case lockWallet
    
    static func ==(lhs: HamburgerMenuModal, rhs: HamburgerMenuModal) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none): return true
        case (.securityCenter, .securityCenter): return true
        case (.support, .support): return true
        case (.settings, .settings): return true
        case (.digiDollar, .digiDollar): return true
        case (.lockWallet, .lockWallet): return true
        case (let .digiAssets(a1), let .digiAssets(a2)):
            return a1 == a2
        default:
            return false
        }
    }
}

enum SyncState {
    case syncing
    case connecting
    case success
}

struct WalletState {
    let isConnected: Bool
    let syncProgress: Double
    let syncState: SyncState
    let balance: UInt64?
    let transactions: [Transaction]
    let lastBlockTimestamp: UInt32
    let name: String
    let creationDate: Date
    let isRescanning: Bool
    let blockHeight: UInt32
    
    static var initial: WalletState {
        return WalletState(isConnected: false, syncProgress: 0.0, syncState: .connecting, balance: nil, transactions: [], lastBlockTimestamp: 0, name: S.AccountHeader.defaultWalletName, creationDate: Date.zeroValue(), isRescanning: false, blockHeight: 0)
    }
}

extension WalletState : Equatable {}

func ==(lhs: WalletState, rhs: WalletState) -> Bool {
    return lhs.isConnected == rhs.isConnected && lhs.syncProgress == rhs.syncProgress && lhs.syncState == rhs.syncState && lhs.balance == rhs.balance && lhs.transactions == rhs.transactions && lhs.name == rhs.name && lhs.creationDate == rhs.creationDate && lhs.isRescanning == rhs.isRescanning
}
