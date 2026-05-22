//
//  DigiDollarMainViewController.swift
//  DigiByte
//
//  DigiDollar wallet surface for testnet protocol bring-up.
//

import UIKit
import BRCore

class DigiDollarMainViewController: UITabBarController {
    private let header = ModalHeaderView(title: S.MenuButton.digiDollar, style: .light)
    private let store: BRStore
    private let walletManager: WalletManager

    init(store: BRStore, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager

        super.init(nibName: nil, bundle: nil)

        viewControllers = [
            DigiDollarOverviewViewController(store: store, walletManager: walletManager),
            DigiDollarSendViewController(store: store, walletManager: walletManager),
            DigiDollarReceiveViewController(store: store, walletManager: walletManager),
            DigiDollarMintRedeemViewController(store: store, walletManager: walletManager),
            DigiDollarTransactionsViewController(store: store, walletManager: walletManager)
        ]

        addSubviews()
        addConstraints()
        setStyle()

        header.close.tap = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func addSubviews() {
        view.addSubview(header)
    }

    private func addConstraints() {
        header.constrain([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 96)
        ])
    }

    private func setStyle() {
        view.backgroundColor = UIColor.dd.background
        tabBar.tintColor = UIColor.dd.accent
        tabBar.barTintColor = UIColor.dd.surface
        tabBar.isTranslucent = false
        if #available(iOS 10.0, *) {
            tabBar.unselectedItemTintColor = UIColor.dd.muted
        }
        header.backgroundColor = UIColor.dd.background.withAlphaComponent(0.92)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class DigiDollarBaseViewController: UIViewController {
    let store: BRStore
    let walletManager: WalletManager
    let stackView = UIStackView()
    private let scrollView = UIScrollView()

    init(store: BRStore, walletManager: WalletManager, title: String, imageName: String?) {
        self.store = store
        self.walletManager = walletManager
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: title,
                                  image: UIImage(named: imageName ?? "")?.withRenderingMode(.alwaysTemplate),
                                  tag: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.dd.background
        scrollView.alwaysBounceVertical = true
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.alignment = .fill
        stackView.distribution = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.constrain([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 106),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stackView.constrain([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 18),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24)
        ])
    }

    func addCard(title: String, rows: [(String, String)], action: DAButton? = nil) {
        let card = UIView()
        card.backgroundColor = UIColor.dd.surface
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.dd.border.cgColor

        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        inner.alignment = .fill
        inner.distribution = .fill

        let titleLabel = UILabel(font: UIFont.da.customBold(size: 18), color: .white)
        titleLabel.text = title
        titleLabel.numberOfLines = 0

        card.addSubview(inner)
        inner.addArrangedSubview(titleLabel)
        rows.forEach { inner.addArrangedSubview(metricRow(title: $0.0, value: $0.1)) }
        if let action = action { inner.addArrangedSubview(action) }

        inner.constrain([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        stackView.addArrangedSubview(card)
    }

    func addTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default) {
        textField.backgroundColor = UIColor.dd.input
        textField.textColor = .white
        textField.tintColor = UIColor.dd.accent
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.layer.cornerRadius = 6
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.dd.border.cgColor
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                             attributes: [.foregroundColor: UIColor.dd.muted])
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        textField.leftViewMode = .always
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        stackView.addArrangedSubview(textField)
    }

    func actionButton(title: String, color: UIColor = UIColor.dd.accent, action: @escaping () -> Void) -> DAButton {
        let button = DAButton(title: title.uppercased(), backgroundColor: color, height: 46)
        button.touchUpInside = action
        return button
    }

    func showStatus(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.Button.ok, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func metricRow(title: String, value: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .firstBaseline
        row.spacing = 10

        let titleLabel = UILabel(font: UIFont.da.customMedium(size: 13), color: UIColor.dd.muted)
        titleLabel.text = title
        titleLabel.numberOfLines = 0

        let valueLabel = UILabel(font: UIFont.da.customBold(size: 16), color: .white)
        valueLabel.text = value
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(valueLabel)
        return row
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class DigiDollarOverviewViewController: DigiDollarBaseViewController {
    init(store: BRStore, walletManager: WalletManager) {
        super.init(store: store, walletManager: walletManager, title: "Overview", imageName: "digiassets_small")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let balanceCents = walletManager.wallet?.digiDollarBalanceCents ?? 0
        let outputCount = walletManager.wallet?.digiDollarUtxos.count ?? 0

        addCard(title: "DigiDollar Balances",
                rows: [
                    ("Available", formatDigiDollar(cents: balanceCents)),
                    ("Pending", formatDigiDollar(cents: 0)),
                    ("Available Outputs", "\(outputCount)"),
                    ("Locked Collateral", "0.00000000 DGB"),
                    ("Network", DigiDollarProtocol.currentNetwork.displayName)
                ])
        addCard(title: "Protocol",
                rows: [
                    ("DD Version", "0x0770"),
                    ("Mint", String(format: "0x%08x", DigiDollarProtocol.version(for: .mint))),
                    ("Transfer", String(format: "0x%08x", DigiDollarProtocol.version(for: .transfer))),
                    ("Redeem", String(format: "0x%08x", DigiDollarProtocol.version(for: .redeem)))
                ])
        addCard(title: "System",
                rows: [
                    ("Health", "Awaiting headers"),
                    ("DCA", "Pending"),
                    ("ERR", "Pending")
                ])
    }
}

private final class DigiDollarSendViewController: DigiDollarBaseViewController {
    private let addressField = UITextField()
    private let amountField = UITextField()
    private var pendingTransfer: BRTxRef?

    init(store: BRStore, walletManager: WalletManager) {
        super.init(store: store, walletManager: walletManager, title: "Send", imageName: "da-send")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCard(title: "Send DigiDollars",
                rows: [("Network", DigiDollarProtocol.currentNetwork.displayName)])
        addTextField(addressField, placeholder: "TD address")
        addTextField(amountField, placeholder: "Amount DD", keyboardType: .decimalPad)
        stackView.addArrangedSubview(actionButton(title: "Send DigiDollars") { [weak self] in self?.validateSend() })
    }

    private func validateSend() {
        guard let address = addressField.text, DigiDollarProtocol.isValidAddress(address, network: DigiDollarProtocol.currentNetwork) else {
            showStatus("Invalid address", message: "Use a DigiDollar address for \(DigiDollarProtocol.currentNetwork.displayName).")
            return
        }
        guard let amountText = amountField.text, let cents = DigiDollarAmountParser.cents(from: amountText), cents >= 100 else {
            showStatus("Invalid amount", message: "Minimum output is 1.00 DD.")
            return
        }
        guard let wallet = walletManager.wallet else {
            showStatus("Wallet unavailable", message: "The wallet is still loading.")
            return
        }
        guard let tx = wallet.createDigiDollarTransfer(amountCents: cents, toAddress: address) else {
            showStatus("Transfer unavailable", message: "Insufficient DD, confirmed DD outputs, or DGB fee balance.")
            return
        }

        pendingTransfer = tx
        let fee = wallet.feeForTx(tx) ?? 0
        let message = "\(formatDigiDollar(cents: cents))\nFee \(formatDGB(satoshis: fee)) DGB"
        let alert = UIAlertController(title: "Send DigiDollars", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.Button.cancel, style: .cancel) { [weak self] _ in
            self?.releasePendingTransfer()
        })
        alert.addAction(UIAlertAction(title: S.Confirmation.send, style: .default) { [weak self] _ in
            self?.presentPinForPendingTransfer()
        })
        present(alert, animated: true, completion: nil)
    }

    private func presentPinForPendingTransfer() {
        guard pendingTransfer != nil else { return }

        let verify = VerifyPinViewController(bodyText: S.VerifyPin.authorize,
                                             pinLength: store.state.pinLength) { [weak self] pin, vc in
            guard let self = self, let tx = self.pendingTransfer else { return false }
            var success = false
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.walletQueue.async {
                success = self.walletManager.signTransaction(tx, pin: pin)
                group.leave()
            }
            guard group.wait(timeout: .now() + 30.0) != .timedOut, success else { return false }
            vc.dismiss(animated: true) {
                self.publishPendingTransfer()
            }
            return true
        }

        verify.modalPresentationStyle = .overFullScreen
        verify.modalPresentationCapturesStatusBarAppearance = true
        present(verify, animated: true, completion: nil)
    }

    private func publishPendingTransfer() {
        guard let tx = pendingTransfer else { return }
        pendingTransfer = nil
        let txHash = tx.pointee.txHash.description
        guard let peerManager = walletManager.peerManager else {
            BRTransactionFree(tx)
            showStatus("Network unavailable", message: "Peer manager is not ready.")
            return
        }

        peerManager.publishTx(tx) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.showStatus("DigiDollars sent", message: txHash)
                } else {
                    self?.showStatus("Broadcast failed", message: error?.localizedDescription ?? "Peer broadcast failed.")
                }
            }
        }
    }

    private func releasePendingTransfer() {
        if let tx = pendingTransfer { BRTransactionFree(tx) }
        pendingTransfer = nil
    }

    deinit {
        releasePendingTransfer()
    }
}

private final class DigiDollarReceiveViewController: DigiDollarBaseViewController {
    init(store: BRStore, walletManager: WalletManager) {
        super.init(store: store, walletManager: walletManager, title: "Receive", imageName: "da-receive")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let receiveAddress = walletManager.wallet?.digiDollarReceiveAddress ?? "Unavailable"
        addCard(title: "Receive DigiDollars",
                rows: [
                    ("Network", DigiDollarProtocol.currentNetwork.displayName),
                    ("Address Type", DigiDollarProtocol.currentNetwork == .testnet ? "TD" : "DD"),
                    ("Key Type", "Taproot x-only"),
                    ("Address", receiveAddress)
                ],
                action: actionButton(title: "Copy Address") { [weak self] in
                    UIPasteboard.general.string = receiveAddress
                    self?.showStatus("Address copied", message: receiveAddress)
                })
    }
}

private final class DigiDollarMintRedeemViewController: DigiDollarBaseViewController {
    private let mintAmountField = UITextField()
    private let redeemAmountField = UITextField()

    init(store: BRStore, walletManager: WalletManager) {
        super.init(store: store, walletManager: walletManager, title: "Vault", imageName: "da-create")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let outputCount = walletManager.wallet?.digiDollarUtxos.count ?? 0

        addCard(title: "Mint",
                rows: [
                    ("Minimum", "100.00 DD"),
                    ("Maximum", "100,000.00 DD"),
                    ("Default Lock", "1 hour")
                ])
        addTextField(mintAmountField, placeholder: "Amount DD", keyboardType: .decimalPad)
        stackView.addArrangedSubview(actionButton(title: "Validate Mint") { [weak self] in self?.validateMint() })

        addCard(title: "Redeem",
                rows: [
                    ("Mode", "Timelock"),
                    ("ERR", "Extra DD burn")
                ])
        addTextField(redeemAmountField, placeholder: "DD change", keyboardType: .decimalPad)
        stackView.addArrangedSubview(actionButton(title: "Validate Redeem", color: UIColor.dd.green) { [weak self] in self?.validateRedeem() })
        
        addCard(title: "Vaults",
                rows: [
                    ("Open", "0"),
                    ("Redeemable", "0"),
                    ("Token Outputs", "\(outputCount)"),
                    ("Locked DGB", "0.00000000")
                ])
        addCard(title: "Lock Tiers",
                rows: DigiDollarProtocol.lockTiers.map {
                    ("Tier \($0.index)", "\($0.blocks) blocks / \($0.collateralRatioPercent)%")
                })
    }

    private func validateMint() {
        guard let amountText = mintAmountField.text, let cents = DigiDollarAmountParser.cents(from: amountText) else {
            showStatus("Invalid amount", message: "Enter a DD amount.")
            return
        }

        let ownerKey = Array(UInt8(0)..<UInt8(32))
        guard DigiDollarProtocol.buildMintOpReturn(amount: cents, lockHeight: 840, lockTier: 0, ownerXOnlyPubKey: ownerKey) != nil else {
            showStatus("Invalid mint", message: "Mint amount must match DigiDollar protocol limits.")
            return
        }
        showStatus("Mint metadata ready", message: "Mint OP_RETURN is valid. Collateral vault building and Taproot signing are the next wallet-core step.")
    }

    private func validateRedeem() {
        guard let amountText = redeemAmountField.text, let cents = DigiDollarAmountParser.cents(from: amountText) else {
            showStatus("Invalid amount", message: "Enter a DD change amount.")
            return
        }
        guard DigiDollarProtocol.buildRedeemOpReturn(ddChange: cents) != nil else {
            showStatus("No change", message: "Exact-burn redeems do not carry a redeem OP_RETURN.")
            return
        }
        showStatus("Redeem metadata ready", message: "Redeem OP_RETURN is valid. Vault spend signing is the next wallet-core step.")
    }
}

private final class DigiDollarTransactionsViewController: DigiDollarBaseViewController {
    init(store: BRStore, walletManager: WalletManager) {
        super.init(store: store, walletManager: walletManager, title: "Txns", imageName: "transfer")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let counts = walletManager.wallet?.digiDollarTransactionCounts ?? (mint: 0, transfer: 0, redeem: 0)

        addCard(title: "DigiDollar Transactions",
                rows: [
                    ("Mint", "\(counts.mint)"),
                    ("Transfer", "\(counts.transfer)"),
                    ("Redeem", "\(counts.redeem)")
                ])
    }
}

private extension BRWallet {
    var digiDollarTransactionCounts: (mint: Int, transfer: Int, redeem: Int) {
        var counts = (mint: 0, transfer: 0, redeem: 0)

        transactions.forEach { tx in
            guard let tx = tx else { return }
            switch DigiDollarProtocol.type(forVersion: tx.pointee.version) {
            case .mint: counts.mint += 1
            case .transfer: counts.transfer += 1
            case .redeem: counts.redeem += 1
            case .none: break
            }
        }

        return counts
    }
}

private func formatDigiDollar(cents: UInt64) -> String {
    return "\(cents / 100).\(String(format: "%02llu", cents % 100)) DD"
}

private func formatDGB(satoshis: UInt64) -> String {
    let whole = satoshis / 100_000_000
    let fractional = satoshis % 100_000_000
    return "\(whole).\(String(format: "%08llu", fractional))"
}

enum DigiDollarAmountParser {
    static func cents(from string: String) -> UInt64? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let parts = trimmed.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 2, let whole = UInt64(String(parts[0])) else { return nil }

        let multiplied = whole.multipliedReportingOverflow(by: 100)
        guard !multiplied.overflow else { return nil }
        var cents = multiplied.partialValue
        if parts.count == 2 {
            let fraction = String(parts[1])
            guard fraction.count <= 2, let fractionValue = UInt64(fraction.padding(toLength: 2, withPad: "0", startingAt: 0)) else { return nil }
            let added = cents.addingReportingOverflow(fractionValue)
            guard !added.overflow else { return nil }
            cents = added.partialValue
        }
        return cents
    }
}

private extension UIColor {
    enum dd {
        static let background = UIColor(red: 0x10 / 255, green: 0x14 / 255, blue: 0x24 / 255, alpha: 1.0)
        static let surface = UIColor(red: 0x18 / 255, green: 0x32 / 255, blue: 0x3A / 255, alpha: 1.0)
        static let input = UIColor(red: 0x22 / 255, green: 0x39 / 255, blue: 0x45 / 255, alpha: 1.0)
        static let border = UIColor(red: 0x2C / 255, green: 0x66 / 255, blue: 0x78 / 255, alpha: 1.0)
        static let accent = UIColor(red: 0x27 / 255, green: 0x9F / 255, blue: 0xE8 / 255, alpha: 1.0)
        static let green = UIColor(red: 0x22 / 255, green: 0xBF / 255, blue: 0x74 / 255, alpha: 1.0)
        static let muted = UIColor(red: 0xA7 / 255, green: 0xB6 / 255, blue: 0xC2 / 255, alpha: 1.0)
    }
}
