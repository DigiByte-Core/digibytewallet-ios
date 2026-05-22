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
            DigiDollarMintRedeemViewController(store: store, walletManager: walletManager)
        ]

        addSubviews()
        addConstraints()
        setStyle()
        setAccessibilityIdentifiers()

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
        tabBar.tintColor = UIColor.dd.green
        tabBar.barTintColor = UIColor.dd.tabBar
        tabBar.isTranslucent = false
        tabBar.layer.borderWidth = 0
        tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.32
        tabBar.layer.shadowRadius = 16
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        if #available(iOS 10.0, *) {
            tabBar.unselectedItemTintColor = UIColor.dd.dim
        }
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.dd.tabBar
            appearance.shadowColor = UIColor.dd.border.withAlphaComponent(0.45)
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.dd.green
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.dd.green]
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.dd.dim
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.dd.dim]
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
        header.backgroundColor = UIColor.dd.background.withAlphaComponent(0.96)
    }

    private func setAccessibilityIdentifiers() {
        tabBar.accessibilityIdentifier = "digidollar-tab-bar"
        guard let items = tabBar.items, items.count == 4 else { return }
        items[0].accessibilityIdentifier = "digidollar-tab-overview"
        items[1].accessibilityIdentifier = "digidollar-tab-send"
        items[2].accessibilityIdentifier = "digidollar-tab-receive"
        items[3].accessibilityIdentifier = "digidollar-tab-vault"
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
                                  image: DigiDollarTabIcon.image(named: imageName),
                                  tag: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.dd.background
        view.accessibilityIdentifier = "digidollar-\(tabBarItem.title?.lowercased() ?? "screen")-screen"
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.alignment = .fill
        stackView.distribution = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.constrain([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 106),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -112)
        ])

        stackView.constrain([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 18),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24)
        ])
    }

    func addHero(title: String, subtitle: String, primary: String, secondary: String, accessibilityIdentifier: String) {
        let hero = UIView()
        hero.accessibilityIdentifier = accessibilityIdentifier
        hero.backgroundColor = UIColor.dd.hero
        applyCardChrome(to: hero, accent: UIColor.dd.green, emphasized: true)

        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        inner.alignment = .fill

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 12

        let mark = DigiDollarMarkView()

        let titleStack = UIStackView()
        titleStack.axis = .vertical
        titleStack.spacing = 3
        let titleLabel = UILabel(font: UIFont.da.customBold(size: 21), color: UIColor.dd.text)
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        let subtitleLabel = UILabel(font: UIFont.da.customMedium(size: 13), color: UIColor.dd.softText)
        subtitleLabel.text = subtitle
        subtitleLabel.numberOfLines = 0
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(subtitleLabel)

        topRow.addArrangedSubview(mark)
        mark.constrain([
            mark.widthAnchor.constraint(equalToConstant: 54),
            mark.heightAnchor.constraint(equalToConstant: 54)
        ])
        topRow.addArrangedSubview(titleStack)

        let balanceLabel = UILabel(font: UIFont.da.customBold(size: 34), color: UIColor.dd.green)
        balanceLabel.text = primary
        balanceLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.minimumScaleFactor = 0.55
        balanceLabel.numberOfLines = 1

        let secondaryLabel = UILabel(font: UIFont.da.customMedium(size: 13), color: UIColor.dd.muted)
        secondaryLabel.text = secondary
        secondaryLabel.numberOfLines = 0

        hero.addSubview(inner)
        inner.addArrangedSubview(topRow)
        inner.setCustomSpacing(14, after: topRow)
        inner.addArrangedSubview(balanceLabel)
        inner.addArrangedSubview(secondaryLabel)
        inner.constrain([
            inner.topAnchor.constraint(equalTo: hero.topAnchor, constant: 20),
            inner.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 18),
            inner.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -18),
            inner.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -20)
        ])

        stackView.addArrangedSubview(hero)
    }

    func addCard(title: String,
                 subtitle: String? = nil,
                 rows: [(String, String)],
                 accessibilityIdentifier: String? = nil,
                 accent: UIColor = UIColor.dd.green,
                 action: DAButton? = nil) {
        let card = UIView()
        card.accessibilityIdentifier = accessibilityIdentifier
        card.backgroundColor = UIColor.dd.surface
        applyCardChrome(to: card, accent: accent)

        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        inner.alignment = .fill
        inner.distribution = .fill

        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 10

        let accentBar = UIView()
        accentBar.backgroundColor = accent
        accentBar.layer.cornerRadius = 2

        let titleLabel = UILabel(font: UIFont.da.customBold(size: 18), color: UIColor.dd.text)
        titleLabel.text = title
        titleLabel.numberOfLines = 0

        titleRow.addArrangedSubview(accentBar)
        accentBar.constrain([
            accentBar.widthAnchor.constraint(equalToConstant: 4),
            accentBar.heightAnchor.constraint(equalToConstant: 22)
        ])
        titleRow.addArrangedSubview(titleLabel)

        card.addSubview(inner)
        inner.addArrangedSubview(titleRow)
        if let subtitle = subtitle {
            let subtitleLabel = UILabel(font: UIFont.da.customMedium(size: 13), color: UIColor.dd.muted)
            subtitleLabel.text = subtitle
            subtitleLabel.numberOfLines = 0
            inner.addArrangedSubview(subtitleLabel)
        }
        rows.forEach { inner.addArrangedSubview(metricRow(title: $0.0, value: $0.1)) }
        if let action = action { inner.addArrangedSubview(action) }

        inner.constrain([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])

        stackView.addArrangedSubview(card)
    }

    func addAddressCard(title: String,
                        subtitle: String,
                        address: String,
                        accessibilityIdentifier: String,
                        action: DAButton) {
        let card = UIView()
        card.accessibilityIdentifier = accessibilityIdentifier
        card.backgroundColor = UIColor.dd.surface
        applyCardChrome(to: card, accent: UIColor.dd.green, emphasized: true)

        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 14
        inner.alignment = .fill

        let titleLabel = UILabel(font: UIFont.da.customBold(size: 20), color: UIColor.dd.text)
        titleLabel.text = title
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel(font: UIFont.da.customMedium(size: 13), color: UIColor.dd.muted)
        subtitleLabel.text = subtitle
        subtitleLabel.numberOfLines = 0

        let qrWrap = UIView()
        qrWrap.backgroundColor = .white
        qrWrap.layer.cornerRadius = 8
        qrWrap.layer.borderWidth = 6
        qrWrap.layer.borderColor = UIColor.dd.green.withAlphaComponent(0.26).cgColor
        qrWrap.layer.masksToBounds = true
        let qrImage = UIImageView()
        qrImage.accessibilityIdentifier = "digidollar-receive-qr-code"
        qrImage.contentMode = .scaleAspectFit
        if let data = address.data(using: .utf8),
           let image = UIImage.qrCode(data: data, color: CIColor(color: .black))?.resize(CGSize(width: 210, height: 210)) {
            qrImage.image = image
        }
        qrWrap.addSubview(qrImage)
        qrImage.constrain(toSuperviewEdges: UIEdgeInsets(top: 14, left: 14, bottom: -14, right: -14))

        let addressLabel = UILabel(font: UIFont.da.customBold(size: 15), color: UIColor.dd.text)
        addressLabel.accessibilityIdentifier = "digidollar-receive-address"
        addressLabel.text = address
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        addressLabel.lineBreakMode = .byCharWrapping

        card.addSubview(inner)
        inner.addArrangedSubview(titleLabel)
        inner.addArrangedSubview(subtitleLabel)
        inner.addArrangedSubview(qrWrap)
        qrWrap.constrain([
            qrWrap.heightAnchor.constraint(equalToConstant: 238)
        ])
        inner.addArrangedSubview(addressLabel)
        inner.addArrangedSubview(action)
        inner.constrain([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])

        stackView.addArrangedSubview(card)
    }

    func addTextField(_ textField: UITextField, placeholder: String, label: String? = nil, keyboardType: UIKeyboardType = .default) {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 7
        container.alignment = .fill

        if let label = label {
            let labelView = UILabel(font: UIFont.da.customMedium(size: 12), color: UIColor.dd.muted)
            labelView.text = label.uppercased()
            labelView.numberOfLines = 0
            container.addArrangedSubview(labelView)
        }

        textField.backgroundColor = UIColor.dd.input
        textField.textColor = UIColor.dd.text
        textField.tintColor = UIColor.dd.green
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.dd.border.cgColor
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                             attributes: [.foregroundColor: UIColor.dd.dim])
        textField.font = UIFont.da.customMedium(size: 17)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        textField.leftViewMode = .always
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        container.addArrangedSubview(textField)
        stackView.addArrangedSubview(container)
    }

    func actionButton(title: String, color: UIColor = UIColor.dd.green, action: @escaping () -> Void) -> DAButton {
        let button = DAButton(title: title.uppercased(), backgroundColor: color, height: 50, radius: 8)
        button.label.font = UIFont.da.customBold(size: 16)
        button.layer.shadowColor = color.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
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
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let valueLabel = UILabel(font: UIFont.da.customBold(size: 16), color: UIColor.dd.text)
        valueLabel.text = value
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = .byCharWrapping
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(valueLabel)
        return row
    }

    func applyCardChrome(to card: UIView, accent: UIColor, emphasized: Bool = false) {
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = accent.withAlphaComponent(emphasized ? 0.56 : 0.32).cgColor
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = emphasized ? 0.26 : 0.17
        card.layer.shadowRadius = emphasized ? 16 : 11
        card.layer.shadowOffset = CGSize(width: 0, height: emphasized ? 8 : 5)

        let topLine = UIView()
        topLine.backgroundColor = accent.withAlphaComponent(emphasized ? 0.95 : 0.72)
        topLine.layer.cornerRadius = 1.5
        card.addSubview(topLine)
        topLine.constrain([
            topLine.topAnchor.constraint(equalTo: card.topAnchor),
            topLine.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            topLine.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            topLine.heightAnchor.constraint(equalToConstant: 3)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class DigiDollarOverviewViewController: DigiDollarBaseViewController {
    init(store: BRStore, walletManager: WalletManager) {
        super.init(store: store, walletManager: walletManager, title: "Overview", imageName: "digidollar-overview")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let dgbBalance = walletManager.wallet?.balance ?? 0
        let dgbReceiveAddress = walletManager.wallet?.receiveAddress ?? "Unavailable"
        let balanceCents = walletManager.wallet?.digiDollarBalanceCents ?? 0
        let outputCount = walletManager.wallet?.digiDollarUtxos.count ?? 0
        let vaults = walletManager.wallet?.digiDollarVaults ?? []
        let lockedDGB = vaults.reduce(UInt64(0)) { $0 + $1.collateralSatoshis }
        let currentHeight = walletManager.peerManager?.lastBlockHeight ?? 0
        let estimatedHeight = walletManager.peerManager?.estimatedBlockHeight ?? 0
        let peerCount = walletManager.peerManager?.peerCount ?? 0
        let counts = walletManager.wallet?.digiDollarTransactionCounts ?? (mint: 0, transfer: 0, redeem: 0)
        let fixedPeer = ProcessInfo.processInfo.environment["DGB_FIXED_PEER"]

        addHero(title: "DigiDollar",
                subtitle: DigiDollarProtocol.currentNetwork.displayName,
                primary: formatDigiDollar(cents: balanceCents),
                secondary: "\(vaults.count) vaults / \(outputCount) spendable DD outputs",
                accessibilityIdentifier: "digidollar-overview-card")

        addCard(title: "DigiDollar Balances",
                subtitle: "Separated from your normal DGB balance and backed by RC41 testnet collateral vaults.",
                rows: [
                    ("Available", formatDigiDollar(cents: balanceCents)),
                    ("Pending", formatDigiDollar(cents: 0)),
                    ("Available Outputs", "\(outputCount)"),
                    ("Locked Collateral", "\(formatDGB(satoshis: lockedDGB)) DGB"),
                    ("Network", DigiDollarProtocol.currentNetwork.displayName)
                ],
                accessibilityIdentifier: "digidollar-balance-card")
        let feeAddressButton = actionButton(title: "Copy DGB Fee Address") { [weak self] in
            UIPasteboard.general.string = dgbReceiveAddress
            self?.showStatus("DGB address copied", message: dgbReceiveAddress)
        }
        feeAddressButton.accessibilityIdentifier = "digidollar-copy-dgb-fee-address-button"
        addCard(title: "DGB Fee Balance",
                subtitle: "DD transfers and redemptions need normal DGB for network fees. Minting also locks DGB collateral.",
                rows: [
                    ("Available", "\(formatDGB(satoshis: dgbBalance)) DGB"),
                    ("Receive", dgbReceiveAddress)
                ],
                accessibilityIdentifier: "digidollar-fee-balance-card",
                accent: UIColor.dd.gold,
                action: feeAddressButton)
        addCard(title: "Protocol",
                subtitle: "RC41 DigiDollar transaction markers used by the mobile SPV builder.",
                rows: [
                    ("DD Version", "0x0770"),
                    ("Activation", activationStatusText(currentHeight: currentHeight)),
                    ("Mint", String(format: "0x%08x", DigiDollarProtocol.version(for: .mint))),
                    ("Transfer", String(format: "0x%08x", DigiDollarProtocol.version(for: .transfer))),
                    ("Redeem", String(format: "0x%08x", DigiDollarProtocol.version(for: .redeem)))
                ],
                accessibilityIdentifier: "digidollar-protocol-card",
                accent: UIColor.dd.blue)
        addCard(title: "Activity",
                rows: [
                    ("Mint", "\(counts.mint)"),
                    ("Transfer", "\(counts.transfer)"),
                    ("Redeem", "\(counts.redeem)")
                ],
                accessibilityIdentifier: "digidollar-transactions-card",
                accent: UIColor.dd.gold)
        addCard(title: "Network Status",
                rows: [
                    ("SPV Height", currentHeight > 0 ? "\(currentHeight)" : "Connecting"),
                    ("Peer Tip", estimatedHeight > 0 ? "\(estimatedHeight)" : "Pending"),
                    ("Peers", "\(peerCount)"),
                    ("Fixed Peer", E.isDebug ? ((fixedPeer?.isEmpty == false) ? fixedPeer! : "Off") : "Release")
                ],
                accessibilityIdentifier: "digidollar-network-card",
                accent: UIColor.dd.blue)
    }
}

private final class DigiDollarSendViewController: DigiDollarBaseViewController {
    private let addressField = UITextField()
    private let amountField = UITextField()
    private var pendingTransfer: BRTxRef?

    init(store: BRStore, walletManager: WalletManager) {
        super.init(store: store, walletManager: walletManager, title: "Send", imageName: "digidollar-send")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addressField.accessibilityIdentifier = "digidollar-send-address"
        amountField.accessibilityIdentifier = "digidollar-send-amount"

        addHero(title: "Send DD",
                subtitle: "Taproot DigiDollar transfer",
                primary: formatDigiDollar(cents: walletManager.wallet?.digiDollarBalanceCents ?? 0),
                secondary: "Available on \(DigiDollarProtocol.currentNetwork.displayName)",
                accessibilityIdentifier: "digidollar-send-card")
        addCard(title: "Transfer",
                subtitle: "DD uses TD testnet addresses. Normal DGB addresses will be rejected.",
                rows: [
                    ("Network", DigiDollarProtocol.currentNetwork.displayName),
                    ("Minimum Output", "1.00 DD"),
                    ("DGB Fee Balance", "\(formatDGB(satoshis: walletManager.wallet?.balance ?? 0)) DGB")
                ],
                accessibilityIdentifier: "digidollar-send-rules-card",
                accent: UIColor.dd.blue)
        addTextField(addressField, placeholder: "TD address", label: "Recipient")
        addTextField(amountField, placeholder: "Amount DD", label: "Amount", keyboardType: .decimalPad)
        let sendButton = actionButton(title: "Send DigiDollars") { [weak self] in self?.validateSend() }
        sendButton.accessibilityIdentifier = "digidollar-send-button"
        stackView.addArrangedSubview(sendButton)
    }

    private func validateSend() {
        guard let peerManager = walletManager.peerManager,
              DigiDollarProtocol.isActivated(at: peerManager.lastBlockHeight) else {
            showStatus("DigiDollar inactive", message: activationRequiredMessage(currentHeight: walletManager.peerManager?.lastBlockHeight ?? 0))
            return
        }
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
        super.init(store: store, walletManager: walletManager, title: "Receive", imageName: "digidollar-receive")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let receiveAddress = walletManager.wallet?.digiDollarReceiveAddress ?? "Unavailable"
        let copyButton = actionButton(title: "Copy Address") { [weak self] in
            UIPasteboard.general.string = receiveAddress
            self?.showStatus("Address copied", message: receiveAddress)
        }
        copyButton.accessibilityIdentifier = "digidollar-copy-address-button"
        addAddressCard(title: "Receive DigiDollars",
                       subtitle: "\(DigiDollarProtocol.currentNetwork.displayName) / Taproot x-only address",
                       address: receiveAddress,
                       accessibilityIdentifier: "digidollar-receive-card",
                       action: copyButton)
        addCard(title: "Address Details",
                rows: [
                    ("Network", DigiDollarProtocol.currentNetwork.displayName),
                    ("Address Type", DigiDollarProtocol.currentNetwork == .testnet ? "TD" : "DD"),
                    ("Key Type", "Taproot x-only")
                ],
                accessibilityIdentifier: "digidollar-receive-details-card",
                accent: UIColor.dd.blue)
    }
}

private final class DigiDollarMintRedeemViewController: DigiDollarBaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    private let mintAmountField = UITextField()
    private let lockTierField = UITextField()
    private let oraclePriceField = UITextField()
    private let systemHealthField = UITextField()
    private let redeemVaultField = UITextField()
    private let statusLabel = DigiDollarInsetLabel(insetFont: UIFont.da.customMedium(size: 14), color: UIColor.dd.softText)
    private let lockTierPicker = UIPickerView()
    private let vaultPicker = UIPickerView()
    private var selectedLockTierIndex = 0
    private var selectedVaultIndex = 0
    private var vaults: [DigiDollarWalletVault] = []
    private var latestStatus: DigiDollarNetworkStatus?
    private var pendingMint: BRTxRef?
    private var pendingRedeem: BRTxRef?

    init(store: BRStore, walletManager: WalletManager) {
        super.init(store: store, walletManager: walletManager, title: "Vault", imageName: "digidollar-vault")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let outputCount = walletManager.wallet?.digiDollarUtxos.count ?? 0
        vaults = walletManager.wallet?.digiDollarVaults ?? []
        lockTierPicker.dataSource = self
        lockTierPicker.delegate = self
        vaultPicker.dataSource = self
        vaultPicker.delegate = self
        lockTierField.inputView = lockTierPicker
        lockTierField.inputAccessoryView = pickerAccessory()
        redeemVaultField.inputView = vaultPicker
        redeemVaultField.inputAccessoryView = pickerAccessory()
        lockTierField.tintColor = .clear
        redeemVaultField.tintColor = .clear
        lockTierField.text = tierTitle(for: selectedLockTierIndex)
        redeemVaultField.text = vaultTitle(for: selectedVaultIndex)
        mintAmountField.accessibilityIdentifier = "digidollar-mint-amount"
        lockTierField.accessibilityIdentifier = "digidollar-lock-tier"
        oraclePriceField.accessibilityIdentifier = "digidollar-oracle-price"
        systemHealthField.accessibilityIdentifier = "digidollar-system-health"
        redeemVaultField.accessibilityIdentifier = "digidollar-redeem-vault"
        oraclePriceField.text = UserDefaults.standard.string(forKey: "DigiDollarOraclePriceUSD") ?? "0.003623"
        systemHealthField.text = UserDefaults.standard.string(forKey: "DigiDollarSystemHealth") ?? "150"

        let currentHeight = walletManager.peerManager?.lastBlockHeight ?? 0
        let redeemableCount = vaults.filter { currentHeight > 0 && UInt64(currentHeight) >= $0.lockHeight }.count
        let lockedDGB = vaults.reduce(UInt64(0)) { $0 + $1.collateralSatoshis }

        addHero(title: "Vault",
                subtitle: "Mint and redeem collateral-backed DigiDollars",
                primary: "\(vaults.count) Open",
                secondary: "\(redeemableCount) redeemable / \(formatDGB(satoshis: lockedDGB)) DGB locked",
                accessibilityIdentifier: "digidollar-vault-card")
        addCard(title: "Mint",
                subtitle: "Creates a DGB collateral vault and DD token output on RC41 testnet.",
                rows: [
                    ("Minimum", "100.00 DD"),
                    ("Maximum", "100,000.00 DD"),
                    ("Default Lock", "1 hour"),
                    ("Network", DigiDollarProtocol.currentNetwork.displayName),
                    ("DGB Available", "\(formatDGB(satoshis: walletManager.wallet?.balance ?? 0)) DGB")
                ],
                accessibilityIdentifier: "digidollar-mint-card")
        addTextField(mintAmountField, placeholder: "Amount DD", label: "Mint Amount", keyboardType: .decimalPad)
        addTextField(lockTierField, placeholder: "Lock tier", label: "Collateral Tier")
        addTextField(oraclePriceField, placeholder: "DGB/USD price", label: "Oracle Price", keyboardType: .decimalPad)
        addTextField(systemHealthField, placeholder: "System health %", label: "System Health", keyboardType: .numberPad)
        addStatusPanel()
        refreshDigiDollarStatus()
        let mintButton = actionButton(title: "Mint DigiDollars") { [weak self] in self?.validateMint() }
        mintButton.accessibilityIdentifier = "digidollar-mint-button"
        stackView.addArrangedSubview(mintButton)

        addCard(title: "Redeem",
                subtitle: "Redeems a full collateral vault after its lock height. ERR burn rules apply below 100% health.",
                rows: [
                    ("Mode", "Full vault"),
                    ("ERR", "Extra DD burn below 100% health")
                ],
                accessibilityIdentifier: "digidollar-redeem-card",
                accent: UIColor.dd.gold)
        addTextField(redeemVaultField, placeholder: "Vault", label: "Vault Position")
        let redeemButton = actionButton(title: "Redeem Vault", color: UIColor.dd.green) { [weak self] in self?.validateRedeem() }
        redeemButton.accessibilityIdentifier = "digidollar-redeem-button"
        stackView.addArrangedSubview(redeemButton)

        addCard(title: "Vaults",
                rows: [
                    ("Open", "\(vaults.count)"),
                    ("Redeemable", "\(redeemableCount)"),
                    ("Token Outputs", "\(outputCount)"),
                    ("Locked DGB", "\(formatDGB(satoshis: lockedDGB)) DGB")
                ],
                accessibilityIdentifier: "digidollar-vault-summary-card",
                accent: UIColor.dd.blue)
        addCard(title: "Lock Tiers",
                rows: DigiDollarProtocol.lockTiers.map {
                    ("Tier \($0.index)", "\($0.blocks) blocks / \($0.collateralRatioPercent)%")
                },
                accessibilityIdentifier: "digidollar-lock-tiers-card",
                accent: UIColor.dd.gold)
    }

    private func validateMint() {
        guard let amountText = mintAmountField.text, let cents = DigiDollarAmountParser.cents(from: amountText) else {
            showStatus("Invalid amount", message: "Enter a DD amount.")
            return
        }
        guard let priceText = oraclePriceField.text, var oraclePrice = DigiDollarAmountParser.microUSD(fromUSD: priceText), oraclePrice > 0 else {
            showStatus("Invalid price", message: "Enter the current DGB/USD oracle price.")
            return
        }
        guard let healthText = systemHealthField.text, var systemHealth = DigiDollarAmountParser.systemHealth(from: healthText) else {
            showStatus("Invalid health", message: "Enter the current system health percentage.")
            return
        }
        if let status = latestStatus {
            guard status.mintingAvailable else {
                showStatus("Minting unavailable", message: statusUnavailableMessage(status))
                return
            }
            oraclePrice = status.oraclePriceMicroUSD
            systemHealth = status.systemHealth
        }
        guard let wallet = walletManager.wallet else {
            showStatus("Wallet unavailable", message: "The wallet is still loading.")
            return
        }
        guard let peerManager = walletManager.peerManager, peerManager.lastBlockHeight > 0 else {
            showStatus("Sync required", message: "Connect to RC41 testnet before minting.")
            return
        }
        guard DigiDollarProtocol.isActivated(at: peerManager.lastBlockHeight) else {
            showStatus("DigiDollar inactive", message: activationRequiredMessage(currentHeight: peerManager.lastBlockHeight))
            return
        }

        let lockTier = UInt32(selectedLockTierIndex)
        let currentHeight = peerManager.lastBlockHeight
        let collateral = DigiDollarProtocol.requiredCollateral(amountCents: cents,
                                                               lockTier: lockTier,
                                                               oraclePriceMicroUSD: oraclePrice,
                                                               systemHealth: systemHealth)
        let lockHeight = DigiDollarProtocol.mintLockHeight(currentBlockHeight: currentHeight, lockTier: lockTier)
        guard collateral > 0, lockHeight > 0 else {
            showStatus("Invalid mint", message: "Amount, price, health, or lock tier is outside DigiDollar protocol limits.")
            return
        }

        UserDefaults.standard.set(priceText, forKey: "DigiDollarOraclePriceUSD")
        UserDefaults.standard.set(healthText, forKey: "DigiDollarSystemHealth")

        guard let tx = wallet.createDigiDollarMint(amountCents: cents,
                                                   lockTier: lockTier,
                                                   currentBlockHeight: currentHeight,
                                                   oraclePriceMicroUSD: oraclePrice,
                                                   systemHealth: systemHealth) else {
            showStatus("Mint unavailable", message: "Need \(formatDGB(satoshis: collateral)) DGB collateral plus fees in confirmed spendable DGB outputs.")
            return
        }

        pendingMint = tx
        let fee = wallet.feeForTx(tx) ?? 0
        let message = [
            formatDigiDollar(cents: cents),
            "Tier \(selectedLockTierIndex): \(tierTitle(for: selectedLockTierIndex))",
            "Unlock height \(lockHeight)",
            "Collateral \(formatDGB(satoshis: collateral)) DGB",
            "Fee \(formatDGB(satoshis: fee)) DGB"
        ].joined(separator: "\n")
        let alert = UIAlertController(title: "Mint DigiDollars", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.Button.cancel, style: .cancel) { [weak self] _ in
            self?.releasePendingMint()
        })
        alert.addAction(UIAlertAction(title: "Mint", style: .default) { [weak self] _ in
            self?.presentPinForPendingMint()
        })
        present(alert, animated: true, completion: nil)
    }

    private func validateRedeem() {
        guard let wallet = walletManager.wallet else {
            showStatus("Wallet unavailable", message: "The wallet is still loading.")
            return
        }
        guard !vaults.isEmpty, vaults.indices.contains(selectedVaultIndex) else {
            showStatus("No vaults", message: "Minted DigiDollar collateral vaults will appear here after they confirm.")
            return
        }
        guard let peerManager = walletManager.peerManager, peerManager.lastBlockHeight > 0 else {
            showStatus("Sync required", message: "Connect to RC41 testnet before redeeming.")
            return
        }
        guard DigiDollarProtocol.isActivated(at: peerManager.lastBlockHeight) else {
            showStatus("DigiDollar inactive", message: activationRequiredMessage(currentHeight: peerManager.lastBlockHeight))
            return
        }
        guard let healthText = systemHealthField.text, let systemHealth = DigiDollarAmountParser.systemHealth(from: healthText) else {
            showStatus("Invalid health", message: "Enter the current system health percentage.")
            return
        }

        let vault = vaults[selectedVaultIndex]
        let currentHeight = peerManager.lastBlockHeight
        guard UInt64(currentHeight) >= vault.lockHeight else {
            showStatus("Vault locked", message: "Unlock height \(vault.lockHeight). Current height \(currentHeight).")
            return
        }

        UserDefaults.standard.set(healthText, forKey: "DigiDollarSystemHealth")
        let burnCents = DigiDollarProtocol.errRequiredBurn(originalAmountCents: vault.amountCents, systemHealth: systemHealth)
        guard burnCents > 0 else {
            showStatus("Redeem unavailable", message: "System health is outside DigiDollar protocol limits.")
            return
        }

        guard let tx = wallet.createDigiDollarRedeem(collateralHash: vault.txHash,
                                                    collateralIndex: vault.index,
                                                    currentBlockHeight: currentHeight,
                                                    systemHealth: systemHealth) else {
            let required = formatDigiDollar(cents: burnCents)
            showStatus("Redeem unavailable", message: "Need \(required) in confirmed DD outputs plus enough DGB for the fee.")
            return
        }

        pendingRedeem = tx
        let fee = wallet.feeForTx(tx) ?? 0
        let mode = systemHealth >= 100 ? "Normal" : "ERR \(DigiDollarProtocol.errRatioBps(systemHealth: systemHealth)) bps"
        let message = [
            "Vault \(selectedVaultIndex + 1) of \(vaults.count)",
            "Mode \(mode)",
            "Burn \(formatDigiDollar(cents: burnCents))",
            "Return \(formatDGB(satoshis: vault.collateralSatoshis)) DGB",
            "Fee \(formatDGB(satoshis: fee)) DGB"
        ].joined(separator: "\n")
        let alert = UIAlertController(title: "Redeem DigiDollar Vault", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.Button.cancel, style: .cancel) { [weak self] _ in
            self?.releasePendingRedeem()
        })
        alert.addAction(UIAlertAction(title: "Redeem", style: .default) { [weak self] _ in
            self?.presentPinForPendingRedeem()
        })
        present(alert, animated: true, completion: nil)
    }

    private func addStatusPanel() {
        let card = UIView()
        card.accessibilityIdentifier = "digidollar-status-card"
        card.backgroundColor = UIColor.dd.surface
        applyCardChrome(to: card, accent: UIColor.dd.blue)

        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 10
        inner.alignment = .fill

        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 10

        let pulse = UIView()
        pulse.backgroundColor = UIColor.dd.green
        pulse.layer.cornerRadius = 5
        pulse.layer.shadowColor = UIColor.dd.green.cgColor
        pulse.layer.shadowOpacity = 0.5
        pulse.layer.shadowRadius = 6
        pulse.layer.shadowOffset = .zero

        let titleLabel = UILabel(font: UIFont.da.customBold(size: 16), color: UIColor.dd.text)
        titleLabel.text = "RC41 Status"
        titleLabel.numberOfLines = 0
        let sourceLabel = UILabel(font: UIFont.da.customMedium(size: 12), color: UIColor.dd.green)
        sourceLabel.text = "CORE ORACLE"
        sourceLabel.textAlignment = .right
        sourceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        statusLabel.accessibilityIdentifier = "digidollar-status-summary"
        statusLabel.text = "Manual status until a Core RPC bridge is configured."
        statusLabel.numberOfLines = 0
        statusLabel.backgroundColor = UIColor.dd.input.withAlphaComponent(0.72)
        statusLabel.layer.cornerRadius = 8
        statusLabel.layer.masksToBounds = true

        card.addSubview(inner)
        titleRow.addArrangedSubview(pulse)
        pulse.constrain([
            pulse.widthAnchor.constraint(equalToConstant: 10),
            pulse.heightAnchor.constraint(equalToConstant: 10)
        ])
        titleRow.addArrangedSubview(titleLabel)
        titleRow.addArrangedSubview(sourceLabel)
        inner.addArrangedSubview(titleRow)
        inner.addArrangedSubview(statusLabel)
        inner.constrain([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        stackView.addArrangedSubview(card)
    }

    private func refreshDigiDollarStatus() {
        DigiDollarStatusService.shared.load { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let status = status else {
                    self.statusLabel.text = "Manual status. Launch with DGB_DIGIDOLLAR_RPC_URL to auto-fill Core oracle health."
                    return
                }

                self.latestStatus = status
                self.oraclePriceField.text = status.priceUSDString
                self.systemHealthField.text = "\(status.systemHealth)"

                if status.mintingAvailable {
                    self.statusLabel.text = "Core RPC: oracle \(status.oracleStatus), price $\(status.priceUSDString), health \(status.systemHealth)%."
                } else {
                    self.statusLabel.text = self.statusUnavailableMessage(status)
                }
            }
        }
    }

    private func statusUnavailableMessage(_ status: DigiDollarNetworkStatus) -> String {
        if let reason = status.mintingRestrictedReason, !reason.isEmpty {
            return "Core RPC: minting restricted (\(reason)). Oracle \(status.oracleStatus), price $\(status.priceUSDString), health \(status.systemHealth)%."
        }
        return "Core RPC: oracle \(status.oracleStatus), price $\(status.priceUSDString), health \(status.systemHealth)%."
    }

    private func presentPinForPendingMint() {
        guard pendingMint != nil else { return }

        let verify = VerifyPinViewController(bodyText: S.VerifyPin.authorize,
                                             pinLength: store.state.pinLength) { [weak self] pin, vc in
            guard let self = self, let tx = self.pendingMint else { return false }
            var success = false
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.walletQueue.async {
                success = self.walletManager.signTransaction(tx, pin: pin)
                group.leave()
            }
            guard group.wait(timeout: .now() + 30.0) != .timedOut, success else { return false }
            vc.dismiss(animated: true) {
                self.publishPendingMint()
            }
            return true
        }

        verify.modalPresentationStyle = .overFullScreen
        verify.modalPresentationCapturesStatusBarAppearance = true
        present(verify, animated: true, completion: nil)
    }

    private func publishPendingMint() {
        guard let tx = pendingMint else { return }
        pendingMint = nil
        let txHash = tx.pointee.txHash.description
        guard let peerManager = walletManager.peerManager else {
            BRTransactionFree(tx)
            showStatus("Network unavailable", message: "Peer manager is not ready.")
            return
        }

        peerManager.publishTx(tx) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.showStatus("DigiDollars minted", message: txHash)
                } else {
                    self?.showStatus("Broadcast failed", message: error?.localizedDescription ?? "Peer broadcast failed.")
                }
            }
        }
    }

    private func presentPinForPendingRedeem() {
        guard pendingRedeem != nil else { return }

        let verify = VerifyPinViewController(bodyText: S.VerifyPin.authorize,
                                             pinLength: store.state.pinLength) { [weak self] pin, vc in
            guard let self = self, let tx = self.pendingRedeem else { return false }
            var success = false
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.walletQueue.async {
                success = self.walletManager.signTransaction(tx, pin: pin)
                group.leave()
            }
            guard group.wait(timeout: .now() + 30.0) != .timedOut, success else { return false }
            vc.dismiss(animated: true) {
                self.publishPendingRedeem()
            }
            return true
        }

        verify.modalPresentationStyle = .overFullScreen
        verify.modalPresentationCapturesStatusBarAppearance = true
        present(verify, animated: true, completion: nil)
    }

    private func publishPendingRedeem() {
        guard let tx = pendingRedeem else { return }
        pendingRedeem = nil
        let txHash = tx.pointee.txHash.description
        guard let peerManager = walletManager.peerManager else {
            BRTransactionFree(tx)
            showStatus("Network unavailable", message: "Peer manager is not ready.")
            return
        }

        peerManager.publishTx(tx) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.showStatus("DigiDollar vault redeemed", message: txHash)
                } else {
                    self?.showStatus("Broadcast failed", message: error?.localizedDescription ?? "Peer broadcast failed.")
                }
            }
        }
    }

    private func releasePendingMint() {
        if let tx = pendingMint { BRTransactionFree(tx) }
        pendingMint = nil
    }

    private func releasePendingRedeem() {
        if let tx = pendingRedeem { BRTransactionFree(tx) }
        pendingRedeem = nil
    }

    private func pickerAccessory() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePickingTier))
        ]
        return toolbar
    }

    @objc private func donePickingTier() {
        view.endEditing(true)
    }

    private func tierTitle(for index: Int) -> String {
        guard DigiDollarProtocol.lockTiers.indices.contains(index) else { return "Unavailable" }
        let tier = DigiDollarProtocol.lockTiers[index]
        let duration: String
        if tier.blocks == 240 {
            duration = "1 hour"
        } else {
            let days = tier.blocks / 5_760
            duration = days >= 365 ? "\(days / 365)y" : "\(days)d"
        }
        return "\(duration) / \(tier.collateralRatioPercent)%"
    }

    private func vaultTitle(for index: Int) -> String {
        guard vaults.indices.contains(index) else { return "No vaults" }
        let vault = vaults[index]
        return "\(formatDigiDollar(cents: vault.amountCents)) / unlock \(vault.lockHeight)"
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === vaultPicker {
            return max(vaults.count, 1)
        }
        return DigiDollarProtocol.lockTiers.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === vaultPicker {
            return vaultTitle(for: row)
        }
        return "Tier \(row): \(tierTitle(for: row))"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === vaultPicker {
            selectedVaultIndex = min(row, max(vaults.count - 1, 0))
            redeemVaultField.text = vaultTitle(for: selectedVaultIndex)
            return
        }
        selectedLockTierIndex = row
        lockTierField.text = tierTitle(for: row)
    }

    deinit {
        releasePendingMint()
        releasePendingRedeem()
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

private enum DigiDollarTabIcon {
    static func image(named imageName: String?) -> UIImage? {
        guard let imageName = imageName else { return nil }
        switch imageName {
        case "digidollar-overview":
            return render { drawCoin(in: $0); drawOverviewLines(in: $0) }.withRenderingMode(.alwaysTemplate)
        case "digidollar-send":
            return render { drawCoin(in: $0); drawArrow(in: $0, incoming: false) }.withRenderingMode(.alwaysTemplate)
        case "digidollar-receive":
            return render { drawCoin(in: $0); drawArrow(in: $0, incoming: true) }.withRenderingMode(.alwaysTemplate)
        case "digidollar-vault":
            return render { drawVault(in: $0) }.withRenderingMode(.alwaysTemplate)
        default:
            return UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        }
    }

    private static func render(_ draw: (CGRect) -> Void) -> UIImage {
        let size = CGSize(width: 28, height: 28)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        UIColor.black.setStroke()
        UIColor.black.setFill()
        draw(CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    private static func drawCoin(in rect: CGRect) {
        let dPath = UIBezierPath()
        dPath.lineWidth = 2.2
        dPath.lineCapStyle = .round
        dPath.lineJoinStyle = .round
        dPath.move(to: CGPoint(x: rect.minX + 12, y: rect.minY + 6))
        dPath.addLine(to: CGPoint(x: rect.minX + 12, y: rect.minY + 22))
        dPath.addCurve(to: CGPoint(x: rect.minX + 24, y: rect.minY + 14),
                       controlPoint1: CGPoint(x: 22, y: 6),
                       controlPoint2: CGPoint(x: 22, y: 22))
        dPath.addCurve(to: CGPoint(x: rect.minX + 12, y: rect.minY + 6),
                       controlPoint1: CGPoint(x: 22, y: 6),
                       controlPoint2: CGPoint(x: 18, y: 6))
        dPath.stroke()
    }

    private static func drawOverviewLines(in rect: CGRect) {
        for y in [8.0, 14.0, 20.0] {
            let line = UIBezierPath()
            line.lineWidth = 2.2
            line.lineCapStyle = .round
            line.move(to: CGPoint(x: rect.minX + 4, y: rect.minY + CGFloat(y)))
            line.addLine(to: CGPoint(x: rect.minX + 9, y: rect.minY + CGFloat(y)))
            line.stroke()
        }
    }

    private static func drawArrow(in rect: CGRect, incoming: Bool) {
        let line = UIBezierPath()
        line.lineWidth = 2.4
        line.lineCapStyle = .round
        line.lineJoinStyle = .round
        if incoming {
            line.move(to: CGPoint(x: rect.minX + 22, y: rect.minY + 7))
            line.addLine(to: CGPoint(x: rect.minX + 8, y: rect.minY + 21))
            line.move(to: CGPoint(x: rect.minX + 8, y: rect.minY + 21))
            line.addLine(to: CGPoint(x: rect.minX + 8, y: rect.minY + 13))
            line.move(to: CGPoint(x: rect.minX + 8, y: rect.minY + 21))
            line.addLine(to: CGPoint(x: rect.minX + 16, y: rect.minY + 21))
        } else {
            line.move(to: CGPoint(x: rect.minX + 7, y: rect.minY + 21))
            line.addLine(to: CGPoint(x: rect.minX + 21, y: rect.minY + 7))
            line.move(to: CGPoint(x: rect.minX + 21, y: rect.minY + 7))
            line.addLine(to: CGPoint(x: rect.minX + 21, y: rect.minY + 15))
            line.move(to: CGPoint(x: rect.minX + 21, y: rect.minY + 7))
            line.addLine(to: CGPoint(x: rect.minX + 13, y: rect.minY + 7))
        }
        line.stroke()
    }

    private static func drawVault(in rect: CGRect) {
        let shackle = UIBezierPath()
        shackle.lineWidth = 2.2
        shackle.lineCapStyle = .round
        shackle.addArc(withCenter: CGPoint(x: rect.minX + 14, y: rect.minY + 12),
                       radius: 6,
                       startAngle: CGFloat.pi,
                       endAngle: 0,
                       clockwise: true)
        shackle.stroke()

        let body = UIBezierPath(roundedRect: CGRect(x: rect.minX + 5, y: rect.minY + 12, width: 18, height: 12),
                                cornerRadius: 3)
        body.lineWidth = 2.2
        body.stroke()

        let dial = UIBezierPath(ovalIn: CGRect(x: rect.minX + 11, y: rect.minY + 16, width: 6, height: 6))
        dial.lineWidth = 2
        dial.stroke()
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

private func activationStatusText(currentHeight: UInt32) -> String {
    guard let activationHeight = DigiDollarProtocol.activationHeight() else { return "Unavailable" }
    guard currentHeight > 0 else { return "Connect to check \(activationHeight)" }
    if DigiDollarProtocol.isActivated(at: currentHeight) { return "Active at \(activationHeight)" }
    return "Waiting \(currentHeight)/\(activationHeight)"
}

private func activationRequiredMessage(currentHeight: UInt32) -> String {
    guard let activationHeight = DigiDollarProtocol.activationHeight() else {
        return "DigiDollar is currently enabled only for RC41 Testnet25."
    }
    guard currentHeight > 0 else {
        return "Connect to RC41 Testnet25 to check DigiDollar activation at height \(activationHeight)."
    }
    return "Sync to RC41 Testnet25 height \(activationHeight) before building DigiDollar transactions. Current SPV height \(currentHeight)."
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

    static func microUSD(fromUSD string: String) -> UInt64? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")
        guard !trimmed.isEmpty else { return nil }

        let parts = trimmed.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 2, let whole = UInt64(String(parts[0])) else { return nil }

        let multiplied = whole.multipliedReportingOverflow(by: 1_000_000)
        guard !multiplied.overflow else { return nil }
        var microUSD = multiplied.partialValue
        if parts.count == 2 {
            let fraction = String(parts[1])
            guard fraction.count <= 6,
                  let fractionValue = UInt64(fraction.padding(toLength: 6, withPad: "0", startingAt: 0)) else { return nil }
            let added = microUSD.addingReportingOverflow(fractionValue)
            guard !added.overflow else { return nil }
            microUSD = added.partialValue
        }
        return microUSD
    }

    static func systemHealth(from string: String) -> Int32? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "%", with: "")
        guard let value = Int32(trimmed), value >= 0 else { return nil }
        return value
    }
}

private final class DigiDollarMarkView: UIView {
    private let coin = UIView()
    private let ring = UIView()
    private let mark = UILabel(font: UIFont.da.customBold(size: 18), color: UIColor.dd.text)

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear

        coin.backgroundColor = UIColor.dd.green
        coin.layer.borderWidth = 1
        coin.layer.borderColor = UIColor.white.withAlphaComponent(0.32).cgColor
        ring.backgroundColor = UIColor.dd.surface.withAlphaComponent(0.28)
        ring.layer.borderWidth = 1
        ring.layer.borderColor = UIColor.white.withAlphaComponent(0.24).cgColor
        mark.text = "DD"
        mark.textAlignment = .center
        mark.adjustsFontSizeToFitWidth = true
        mark.minimumScaleFactor = 0.6

        addSubview(coin)
        addSubview(ring)
        addSubview(mark)

        coin.constrain(toSuperviewEdges: nil)
        ring.constrain(toSuperviewEdges: UIEdgeInsets(top: 7, left: 7, bottom: -7, right: -7))
        mark.constrain([
            mark.centerXAnchor.constraint(equalTo: centerXAnchor),
            mark.centerYAnchor.constraint(equalTo: centerYAnchor),
            mark.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 9),
            mark.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -9)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        coin.layer.cornerRadius = min(coin.bounds.width, coin.bounds.height) / 2
        ring.layer.cornerRadius = min(ring.bounds.width, ring.bounds.height) / 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class DigiDollarInsetLabel: UILabel {
    private let insets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    init(insetFont: UIFont, color: UIColor) {
        super.init(frame: .zero)
        self.font = insetFont
        self.textColor = color
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = bounds.inset(by: insets)
        let textRect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        return textRect.inset(by: UIEdgeInsets(top: -insets.top,
                                               left: -insets.left,
                                               bottom: -insets.bottom,
                                               right: -insets.right))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension UIColor {
    enum dd {
        static let background = UIColor(red: 0x07 / 255, green: 0x12 / 255, blue: 0x14 / 255, alpha: 1.0)
        static let tabBar = UIColor(red: 0x08 / 255, green: 0x17 / 255, blue: 0x19 / 255, alpha: 1.0)
        static let hero = UIColor(red: 0x0A / 255, green: 0x30 / 255, blue: 0x25 / 255, alpha: 1.0)
        static let surface = UIColor(red: 0x0D / 255, green: 0x26 / 255, blue: 0x22 / 255, alpha: 1.0)
        static let input = UIColor(red: 0x12 / 255, green: 0x33 / 255, blue: 0x2F / 255, alpha: 1.0)
        static let border = UIColor(red: 0x1D / 255, green: 0x66 / 255, blue: 0x4E / 255, alpha: 1.0)
        static let green = UIColor(red: 0x26 / 255, green: 0xD7 / 255, blue: 0x85 / 255, alpha: 1.0)
        static let blue = UIColor(red: 0x2A / 255, green: 0x97 / 255, blue: 0xE8 / 255, alpha: 1.0)
        static let gold = UIColor(red: 0xE2 / 255, green: 0xB9 / 255, blue: 0x54 / 255, alpha: 1.0)
        static let text = UIColor(red: 0xF4 / 255, green: 0xFF / 255, blue: 0xF7 / 255, alpha: 1.0)
        static let softText = UIColor(red: 0xC8 / 255, green: 0xDA / 255, blue: 0xD0 / 255, alpha: 1.0)
        static let muted = UIColor(red: 0x99 / 255, green: 0xB2 / 255, blue: 0xAA / 255, alpha: 1.0)
        static let dim = UIColor(red: 0x5F / 255, green: 0x79 / 255, blue: 0x70 / 255, alpha: 1.0)
        static let accent = green
    }
}
