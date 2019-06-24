//
//  AccountViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit
import BRCore
import MachO
import QuartzCore

let accountHeaderHeight: CGFloat = 136.0
private let transactionsLoadingViewHeightConstant: CGFloat = 48.0

fileprivate let balanceHeaderLabelTopVisible: CGFloat = 12
fileprivate let currencyLabelTopVisible: CGFloat = 12
fileprivate let balanceHeaderLabelTopHidden: CGFloat = -20
fileprivate let currencyLabelTopHidden: CGFloat = -20

fileprivate enum ViewMode {
    case normal
    case small
}

fileprivate class BalanceView: UIView, Subscriber {
    private let balanceHeaderLabel = UILabel(font: .customMedium(size: 12))
    private var balanceLabel: UpdatingLabel
    private var currencyLabel: UpdatingLabel
    
    private var currencyLabelTop: NSLayoutConstraint? = nil
    private var balanceHeaderLabelTop: NSLayoutConstraint? = nil
    
    private let grUp: UISwipeGestureRecognizer = {
       let g = UISwipeGestureRecognizer()
        g.direction = .up
        return g
    }()
    
    private let grDown: UISwipeGestureRecognizer = {
        let g = UISwipeGestureRecognizer()
        g.direction = .down
        return g
    }()
    
    private let store: Store
    private var isBtcSwapped: Bool {
        didSet { updateBalancesAnimated() }
    }
    private var exchangeRate: Rate? {
        didSet { updateBalances() }
    }
    private var balance: UInt64 = 0 {
        didSet { updateBalances() }
    }
    
    private var viewMode: ViewMode = .normal {
        didSet {
            self.resizeView(viewMode)
        }
    }
    
    init(store: Store) {
        self.store = store
        isBtcSwapped = store.state.isBtcSwapped
        exchangeRate = store.state.currentRate
        if let rate = exchangeRate {
            let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: store.state.maxDigits)
            balanceLabel = UpdatingLabel(formatter: placeholderAmount.btcFormat)
            currencyLabel = UpdatingLabel(formatter: placeholderAmount.localFormat)
        } else {
            balanceLabel = UpdatingLabel(formatter: NumberFormatter())
            currencyLabel = UpdatingLabel(formatter: NumberFormatter())
        }
        
        super.init(frame: CGRect())
        
        addSubviews()
        addConstraints()
        addStyles()
        
        addGestureRecognizers()
        
        addSubscriptions()
        
        if UserDefaults.balanceViewCollapsed {
            viewMode = .small
            closeView()
        } else {
            viewMode = .normal
        }
    }
    
    private func resizeView(_ viewMode: ViewMode) {
        switch (viewMode) {
            case .normal:
                openView()
            case .small:
                closeView()
        }
    }
    
    private var viewOpen: Bool = true
    private var animating: Bool = false
    
    private func openView() {
        //guard !viewOpen else { return }
        guard !animating else { return }
        animating = true
        
        UIView.spring(0.4, animations: {
            self.balanceHeaderLabelTop?.constant = balanceHeaderLabelTopVisible
            self.currencyLabelTop?.constant = currencyLabelTopVisible
            
            self.balanceHeaderLabel.alpha = 1
            self.currencyLabel.alpha = 1
            
            self.currencyLabel.layoutIfNeeded()
            self.balanceHeaderLabel.layoutIfNeeded()
            self.balanceLabel.layoutIfNeeded()
            self.layoutIfNeeded()
            
            self.superview?.layoutIfNeeded()
        }) { (c) in
            self.animating = false
            self.viewOpen = true
            UserDefaults.balanceViewCollapsed = false
        }
    }
    
    private func closeView() {
        //guard viewOpen else { return }
        guard !animating else { return }
        animating = true
        
        UIView.spring(0.4, animations: {
            self.balanceHeaderLabelTop?.constant = balanceHeaderLabelTopHidden
            self.currencyLabelTop?.constant = currencyLabelTopHidden
            
            self.balanceHeaderLabel.alpha = 0
            self.currencyLabel.alpha = 0
            
            self.currencyLabel.layoutIfNeeded()
            self.balanceHeaderLabel.layoutIfNeeded()
            self.balanceLabel.layoutIfNeeded()
            self.layoutIfNeeded()
            
            self.superview?.layoutIfNeeded()
        }) { (c) in
            self.animating = false
            self.viewOpen = false
            UserDefaults.balanceViewCollapsed = true
        }
    }
    
    @objc private func balanceViewTapped() {
        guard !animating else { return }
        animating = true
        
        self.store.perform(action: CurrencyChange.toggle())
    }
    
    @objc private func balanceViewSwipeUp() {
        viewMode = .small
    }
    
    @objc private func balanceViewSwipeDown() {
        viewMode = .normal
    }
    
    private func addGestureRecognizers() {
        grUp.addTarget(self, action: #selector(balanceViewSwipeUp))
        grDown.addTarget(self, action: #selector(balanceViewSwipeDown))
        
        let gr = UITapGestureRecognizer()
        gr.addTarget(self, action: #selector(balanceViewTapped))
    
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(grUp)
        self.addGestureRecognizer(grDown)
        self.addGestureRecognizer(gr)
    }
    
    private func addSubscriptions() {
        store.lazySubscribe(self,
                            selector: { $0.isBtcSwapped != $1.isBtcSwapped },
                            callback: { self.isBtcSwapped = $0.isBtcSwapped })
        store.lazySubscribe(self,
                            selector: { $0.currentRate != $1.currentRate},
                            callback: {
                                if let rate = $0.currentRate {
                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
                                    self.currencyLabel.formatter = placeholderAmount.localFormat
                                    self.balanceLabel.formatter = placeholderAmount.btcFormat
                                }
                                self.exchangeRate = $0.currentRate
        })
        
        store.lazySubscribe(self,
                            selector: { $0.maxDigits != $1.maxDigits},
                            callback: {
                                if let rate = $0.currentRate {
                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
                                    self.currencyLabel.formatter = placeholderAmount.localFormat
                                    self.balanceLabel.formatter = placeholderAmount.btcFormat
                                    self.updateBalances()
                                }
        })
        store.subscribe(self,
                        selector: {$0.walletState.balance != $1.walletState.balance },
                        callback: { state in
                            if let balance = state.walletState.balance {
                                self.balance = balance
                            } })
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private func addSubviews() {
        addSubview(balanceHeaderLabel)
        addSubview(balanceLabel)
        addSubview(currencyLabel)
    }
    
    private func addConstraints() {
        balanceHeaderLabelTop = balanceHeaderLabel.topAnchor.constraint(equalTo: topAnchor, constant: balanceHeaderLabelTopVisible)
        balanceHeaderLabel.constrain([
            balanceHeaderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            balanceHeaderLabelTop
        ])
        
        balanceLabel.constrain([
            balanceLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            balanceLabel.topAnchor.constraint(equalTo: balanceHeaderLabel.bottomAnchor, constant: 12),
        ])
        
        currencyLabelTop = currencyLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: currencyLabelTopVisible)
        currencyLabel.constrain([
            currencyLabelTop,
            currencyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            currencyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25)
        ])
    }
    
    private func addStyles() {
        balanceLabel.font = .customMedium(size: 32)
        balanceLabel.textColor = C.Colors.text
        balanceLabel.textAlignment = .center
        
        currencyLabel.font = .customMedium(size: 16)
        currencyLabel.textColor = .gray
        currencyLabel.textAlignment = .center
        
        balanceHeaderLabel.numberOfLines = 2
        balanceHeaderLabel.textColor = .gray
        balanceHeaderLabel.text = S.Balance.header.uppercased()
        balanceHeaderLabel.textAlignment = .center
        
        //balanceLabel.text = "D 132 293.787"
        //currencyLabel.text = "$USD 3988.33"
        backgroundColor = .clear
    }
    
    private func updateBalances(animatedValue: Bool = true) {
        guard let rate = exchangeRate else { return }
        let amount = Amount(amount: balance, rate: rate, maxDigits: store.state.maxDigits)
        
        var balanceValue: Double = 0
        var currencyValue: Double = 0
        
        if isBtcSwapped {
            self.currencyLabel.formatter = amount.btcFormat
            self.balanceLabel.formatter = amount.localFormat
            balanceValue = amount.localAmount
            currencyValue = amount.amountForBtcFormat
        } else {
            self.currencyLabel.formatter = amount.localFormat
            self.balanceLabel.formatter = amount.btcFormat
            balanceValue = amount.amountForBtcFormat
            currencyValue = amount.localAmount
        }
        
        if animatedValue {
            balanceLabel.setValueAnimated(balanceValue) {}
            currencyLabel.setValueAnimated(currencyValue) {}
        } else {
            balanceLabel.setValue(balanceValue)
            currencyLabel.setValue(currencyValue)
        }
    }
    
    private func updateBalancesAnimated() {
        UIView.animate(withDuration: 0.2, animations: {
            self.balanceLabel.alpha = 0
            self.currencyLabel.alpha = 0
        }) { (c) in
            self.updateBalances(animatedValue: false)
            UIView.animate(withDuration: 0.2, animations: {
                self.balanceLabel.alpha = 1
                
                if self.viewMode == .normal {
                    self.currencyLabel.alpha = 1
                }
            }, completion: { (c) in
                self.animating = false
            })
        }
    }
}

fileprivate class CustomSegmentedControl: UIControl {
    
    private var padding: CGFloat = 7.0
    
    var buttons = [UIButton]()
    
    var buttonTemplates: [String] = []
    
    var backgroundRect: UIView!
    
    var selectedSegmentIdx = 0 {
        didSet {
            //updateSegmentedControlSegs(index: selectedSegmentIdx)
        }
    }
    
    var numberOfSegments: Int = 0
    
    var callback: ((Int, Int) -> Void)? = nil
    var scrollToTopCallback: ((Int) -> Void)? = nil
    
    var animating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleView()
        update()
    }
    
    func update() {
        updateView()
    }
    
    private func styleView() {
        backgroundColor = C.Colors.background
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateView() {
        buttons.removeAll()
        
        subviews.forEach { (v) in
            v.removeFromSuperview()
        }
        
        guard buttonTemplates.count > 0 else { return }
        numberOfSegments = buttonTemplates.count
        
        let selectorWidth = (frame.width - 2 * padding) / CGFloat(numberOfSegments)

        backgroundRect = UIView()
        backgroundRect.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        backgroundRect.layer.cornerRadius = 4
        
        let buttonTitles = buttonTemplates
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.titleLabel?.font = UIFont.customBody(size: 14)
            button.setTitleColor(C.Colors.text, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            button.backgroundColor = .clear
            button.titleLabel?.lineBreakMode = .byCharWrapping
            button.titleLabel?.textAlignment = .center
            buttons.append(button)
        }
        
        // background Rect
        addSubview(backgroundRect)
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0.0
        stackView.backgroundColor = .clear
        addSubview(stackView)
        
        stackView.constrain([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: padding),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -padding),
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false

//        backgroundRect.constrain([
//            backgroundRect.topAnchor.constraint(equalTo: topAnchor, constant: padding),
//            backgroundRect.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
//            backgroundRect.widthAnchor.constraint(equalToConstant: selectorWidth),
//            backgroundRect.leftAnchor.constraint(equalTo: leftAnchor, constant: padding)
//        ])
        
        backgroundRect.frame = CGRect(x: padding, y: padding, width: selectorWidth, height: self.frame.height - 2*padding)
        
        backgroundColor = UIColor(red: 0x23 / 255, green: 0x24 / 255, blue: 0x37 / 255, alpha: 1.0)
        layer.cornerRadius = 4
    }
    
    @objc func buttonTapped(button: UIButton) {
        var selectorStartPosition: CGFloat!
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(C.Colors.text, for: .normal)
            
            if (btn == button) {
                guard !animating else { return }
                
                guard selectedSegmentIdx != buttonIndex else {
                    scrollToTopCallback?(buttonIndex)
                    return
                }
                
                animating = true
                callback?(selectedSegmentIdx, buttonIndex)
                selectedSegmentIdx = buttonIndex
                selectorStartPosition = padding + (frame.width - 2 * padding) / CGFloat(buttons.count) * CGFloat(buttonIndex)
                
                UIView.spring(0.2, animations: {
                    self.backgroundRect.frame.origin.x = selectorStartPosition
                }) { (done) in
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1, execute: {
                        self.animating = false
                    })
                }
            }
        }
    }
    
    func animationStep(progress: CGFloat) {
        guard !animating else { return }
    
        let progress = (progress > 1 ? 1 : (progress < -1 ? -1 : progress))
        let singleWidth = (frame.width - 2*padding) / CGFloat(buttons.count)
        let maxIndex = CGFloat(buttons.count) - 1
        var index = CGFloat(selectedSegmentIdx) + progress
        index = (index > maxIndex ? maxIndex : index)
        index = (index < 0 ? 0 : index)
        
        // calculate new position
        let posX = padding + singleWidth * CGFloat(index)
        let newPos: CGFloat = posX
        
        backgroundRect.frame.origin.x = newPos
    }
    
    @objc private func stopped() {
        self.selectedSegmentIdx  = nextIndex
    }
    
    private var nextIndex: Int = 0
    
    func updateSegmentedControlSegs(index: Int) {
        var selectorStartPosition: CGFloat!
        selectorStartPosition = padding + (frame.width - 2*padding) / CGFloat(buttons.count) * CGFloat(index)
        
        selectedSegmentIdx = index

        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: [ .allowUserInteraction, .curveLinear ], animations: {
            self.backgroundRect.frame.origin.x = selectorStartPosition
        }) { (done) in
            // 
        }
    }
}

fileprivate class HamburgerViewMenu: UIView {
    private let bgImage = UIImageView(image: #imageLiteral(resourceName: "hamburgerBg"))
    private var bitradioLogo = UIImageView(image: #imageLiteral(resourceName: "DigiByteSymbol"))
    private let walletLabel = UILabel(font: .customMedium(size: 18), color: C.Colors.text)
    private let walletVersionLabel = UILabel(font: .customMedium(size: 11), color: .gray)
    private var y: CGFloat = 0
    private var supervc: HamburgerViewMenuProtocol? = nil
    private var scrollView = UIScrollView()
    private var scrollInner = UIStackView()
    
    private let buttonHeight: CGFloat = 78.0
    
    private struct SideMenuButton {
        let view: UIView
        let callback: (() -> Void)
    }
    
    private var buttons: [SideMenuButton] = []
    
    init(walletTitle: String, version: String) {
        super.init(frame: CGRect())
        
        walletLabel.text = walletTitle
        walletVersionLabel.text = version
        
        addSubviews()
        addConstraints()
        setStyles()
    }
    
    func animationStep(progress: CGFloat) {
        let progress = progress < 0 ? 0 : (progress > 1 ? 1 : progress)
        
        if progress < 0.3 {
            bitradioLogo.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
        } else {
            bitradioLogo.transform = CGAffineTransform.init(scaleX: progress, y: progress)
        }
    }
    
    private func addSubviews() {
        bgImage.contentMode = .scaleAspectFill
        
        addSubview(bgImage)
        addSubview(bitradioLogo)
        addSubview(walletLabel)
        addSubview(walletVersionLabel)
        addSubview(scrollView)
        
        scrollView.addSubview(scrollInner)
    }
    
    private func addConstraints() {
        bgImage.constrain([
            bgImage.topAnchor.constraint(equalTo: self.topAnchor),
            bgImage.leftAnchor.constraint(equalTo: self.leftAnchor),
            bgImage.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
        
        bitradioLogo.constrain([
            bitradioLogo.topAnchor.constraint(equalTo: self.topAnchor, constant: 78),
            bitradioLogo.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),
            bitradioLogo.widthAnchor.constraint(equalToConstant: 90),
            bitradioLogo.heightAnchor.constraint(equalToConstant: 90),
        ])
        
        walletLabel.constrain([
            walletLabel.topAnchor.constraint(equalTo: bitradioLogo.bottomAnchor, constant: 16),
            walletLabel.centerXAnchor.constraint(equalTo: bitradioLogo.centerXAnchor),
            //walletLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            //walletLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
        
        walletVersionLabel.constrain([
            walletVersionLabel.topAnchor.constraint(equalTo: walletLabel.bottomAnchor, constant: 6),
            walletVersionLabel.centerXAnchor.constraint(equalTo: bitradioLogo.centerXAnchor),
            //walletVersionLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            //walletVersionLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            walletVersionLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
        
        scrollView.constrain([
            scrollView.topAnchor.constraint(equalTo: walletVersionLabel.bottomAnchor, constant: 30),
            scrollView.leftAnchor.constraint(equalTo: self.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: self.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        scrollInner.constrain([
            scrollInner.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollInner.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            scrollInner.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            scrollInner.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollInner.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    private func setStyles() {
        backgroundColor = C.Colors.background
        
        walletLabel.textAlignment = .center
        walletVersionLabel.textAlignment = .center
        
        scrollInner.axis = .vertical
        scrollInner.alignment = .top
        scrollInner.distribution = .equalSpacing
        scrollInner.spacing = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("HamburgerViewMenu aDecoder has not been implemented")
    }
    
    func setCloser(supervc: HamburgerViewMenuProtocol?) {
        self.supervc = supervc
    }
    
    @objc private func buttonTapped(button: UIButton) {
        for (_, btn) in buttons.enumerated() {
            if (btn.view == button) {
                self.supervc?.closeHamburgerMenu()
                self.buttonUp(button: button)
                btn.callback()
            }
        }
    }
    
    @objc private func buttonDown(button: UIButton) {
        button.backgroundColor = UIColor(white: 1, alpha: 0.2)
    }
    
    @objc private func buttonUp(button: UIButton) {
        button.backgroundColor = UIColor.clear
    }
    
    func addButton(title: String, icon: UIImage, callback: @escaping (() -> Void)) {
        
        let buttonImage = UIImageView(image: icon.withRenderingMode(.alwaysTemplate))
        buttonImage.tintColor = C.Colors.text
        buttonImage.contentMode = .scaleAspectFit
        
        let buttonText = UILabel(font: .customBody(size: 18), color: C.Colors.text)
        buttonText.text = title
        buttonText.lineBreakMode = .byWordWrapping
        buttonText.numberOfLines = 0
        
        let buttonContainer = UIControl()
        buttonContainer.isUserInteractionEnabled = true
        buttonContainer.addSubview(buttonImage)
        buttonContainer.addSubview(buttonText)
        
        scrollInner.addArrangedSubview(buttonContainer)
        
        buttonImage.constrain([
            buttonImage.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: 40),
            buttonImage.widthAnchor.constraint(equalToConstant: 40),
            buttonImage.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
        ])
        
        buttonText.constrain([
            buttonText.leadingAnchor.constraint(equalTo: buttonImage.trailingAnchor, constant: 10),
            buttonText.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: 10),
            buttonText.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
        ])
        
        buttonContainer.constrain([
            buttonContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1),
            buttonContainer.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        buttonContainer.addTarget(self, action: #selector(buttonDown(button:)), for: .touchDown)
        buttonContainer.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        buttonContainer.addTarget(self, action: #selector(buttonUp(button:)), for: .touchUpOutside)
        buttonContainer.addTarget(self, action: #selector(buttonUp(button:)), for: .touchCancel)
        
        buttons.append(SideMenuButton(view: buttonContainer, callback: callback))
        y += buttonHeight
    }
}

fileprivate protocol HamburgerViewMenuProtocol {
    func closeHamburgerMenu()
}

class AccountViewController: UIViewController, Subscriber, UIPageViewControllerDataSource, UIPageViewControllerDelegate, HamburgerViewMenuProtocol, UIScrollViewDelegate {

    //MARK: - Public
    var sendCallback: (() -> Void)? {
        didSet { footerView.sendCallback = sendCallback }
    }
    var receiveCallback: (() -> Void)? {
        didSet { footerView.receiveCallback = receiveCallback }
    }
    var menuCallback: (() -> Void)? {
        didSet { footerView.menuCallback = menuCallback }
    }
    
    var scanCallback: (() -> Void)? {
        didSet {
            footerView.qrScanCallback = scanCallback
        }
    }
    
    var showAddressBookCallback: (() -> Void)? {
        didSet {
            footerView.addressBookCallback = showAddressBookCallback
        }
    }

    var walletManager: WalletManager? {
        didSet {
            guard let walletManager = walletManager else { return }
            if !walletManager.noWallet {
                loginView.walletManager = walletManager
                loginView.transitioningDelegate = loginTransitionDelegate
                loginView.modalPresentationStyle = .overFullScreen
                loginView.modalPresentationCapturesStatusBarAppearance = true
                loginView.shouldSelfDismiss = true
                
                self.present(self.loginView, animated: false, completion: {
                    self.tempView.removeFromSuperview()
                    self.tempLoginView.remove()
                    //self.attemptShowWelcomeView()
                })
                
                let pin = UpdatePinViewController(store: store, walletManager: walletManager, type: .update, showsBackButton: false, phrase: "Enter your PIN")
                pin.transitioningDelegate = loginTransitionDelegate
                pin.modalPresentationStyle = .overFullScreen
                pin.modalPresentationCapturesStatusBarAppearance = true
                self.present(pin, animated: false, completion: {
                    self.tempView.removeFromSuperview()
                    self.tempLoginView.remove()
                })
                
            }
            transactionsTableView.walletManager = walletManager
            transactionsTableViewForSentTransactions.walletManager = walletManager
            transactionsTableViewForReceivedTransactions.walletManager = walletManager
        }
    }

    init(store: Store, didSelectTransaction: @escaping ([Transaction], Int) -> Void) {
        self.store = store
        self.syncViewController = SyncViewController(store: store)
        
        self.transactionsTableView = TransactionsTableViewController(store: store, didSelectTransaction: didSelectTransaction)
        self.transactionsTableViewForSentTransactions = TransactionsTableViewController(store: store, didSelectTransaction: didSelectTransaction, kvStore: nil, filterMode: .showOutgoing)
        self.transactionsTableViewForReceivedTransactions = TransactionsTableViewController(store: store, didSelectTransaction: didSelectTransaction, kvStore: nil, filterMode: .showIncoming)
        
        self.loginView = LoginViewController(store: store, isPresentedForLock: false)
        self.tempLoginView = LoginViewController(store: store, isPresentedForLock: false)
        self.balanceView = BalanceView(store: store)
        
        self.edgeGesture = UIScreenEdgePanGestureRecognizer()
        super.init(nibName: nil, bundle: nil)
        
        footerView.debugDigiAssetsCallback = { [unowned self] in
            guard let w = self.walletManager else { return }
            let vc = BRDigiAssetsTestViewController(wallet: w)
            self.present(vc, animated: true, completion: nil)
        }
    }

    //MARK: - Private
    private let store: Store
    private let footerView = AccountFooterView()
    private let syncViewController: SyncViewController
    private let transactionsLoadingView = LoadingProgressView()
    private let transactionsTableView: TransactionsTableViewController
    private let transactionsTableViewForSentTransactions: TransactionsTableViewController
    private let transactionsTableViewForReceivedTransactions: TransactionsTableViewController
    
    private let tempView = UIView(color: C.Colors.background)
    
    private let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private var pages = [UIViewController]()
    
    private let hamburgerMenuView = HamburgerViewMenu(walletTitle: C.applicationTitle, version: C.version)
    private let fadeView: UIView = {
        let view = BlurView()
        view.isUserInteractionEnabled = true
        return view
    }()
    private var hamburgerMenuViewIsAnimating = false
    private let edgeGesture: UIScreenEdgePanGestureRecognizer
    private var menuLeftConstraint: NSLayoutConstraint?
    private var menuWidthConstraint: NSLayoutConstraint?
    
    private let footerHeight: CGFloat = 56.0
    private var transactionsLoadingViewTop: NSLayoutConstraint?
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private var isLoginRequired = false
    private let loginView: LoginViewController
    private let tempLoginView: LoginViewController
    private let loginTransitionDelegate = LoginTransitionDelegate()
    private let welcomeTransitingDelegate = PinTransitioningDelegate()
    
    private var balanceView: BalanceView
    private let menu = CustomSegmentedControl(frame: .zero)

    private let searchHeaderview: SearchHeaderView = {
        let view = SearchHeaderView()
        view.isHidden = true
        return view
    }()
    private let headerContainer = UIView()
    private var loadingTimer: Timer?
    private var shouldShowStatusBar: Bool = true {
        didSet {
            if oldValue != shouldShowStatusBar {
                UIView.animate(withDuration: C.animationDuration) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }
    private var didEndLoading = false

    private func showActivity(_ view: UIView) {
        let act = UIActivityIndicatorView()
        act.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        act.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(act)
        act.constrain([
            act.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            act.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        act.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // detect jailbreak so we can throw up an idiot warning, in viewDidLoad so it can't easily be swizzled out
        if !E.isSimulator {
            var s = stat()
            var isJailbroken = (stat("/bin/sh", &s) == 0) ? true : false
            for i in 0..<_dyld_image_count() {
                guard !isJailbroken else { break }
                // some anti-jailbreak detection tools re-sandbox apps, so do a secondary check for any MobileSubstrate dyld images
                if strstr(_dyld_get_image_name(i), "MobileSubstrate") != nil {
                    isJailbroken = true
                }
            }
            NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: nil) { note in
                self.showJailbreakWarnings(isJailbroken: isJailbroken)
            }
            showJailbreakWarnings(isJailbroken: isJailbroken)
        }

        view.backgroundColor = UIColor(red: 0x19 / 255, green: 0x1b / 255, blue: 0x2a / 255, alpha: 1)
        
        addBalanceView()
        addSegmentedView()
        addTransactionsView()
        addSubviews()
        addHamburgerMenu()
        addConstraints()
        addSubscriptions()
        addAppLifecycleNotificationEvents()
        addTemporaryStartupViews()
        setInitialData()
        
        for subview in pageController.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    private let MENUBACKGROUND_OPACITY_END: CGFloat = 0.8
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        let percentageComplete: CGFloat = (point.x - view.frame.size.width) / view.frame.size.width
        
        if percentageComplete != 0 {
            menu.animationStep(progress: percentageComplete)
        }
    }
    
    @objc private func gestureScreenEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        guard let menuLeftConstraint = menuLeftConstraint else { return }
        let width = hamburgerMenuView.frame.width
        
        if sender.state == .began {
            fadeView.isHidden = false
            fadeView.alpha = 0
        } else if (sender.state == .changed) {
            let translationX = sender.translation(in: sender.view).x
            
            if -width + translationX > 0 {
                menuLeftConstraint.constant = -15
                fadeView.alpha = MENUBACKGROUND_OPACITY_END
            } else if translationX < 0 {
                // fully dragged in
                menuLeftConstraint.constant = -width
                fadeView.alpha = 0
            } else {
                // viewMenu is being dragged somewhere between min and max amount
                menuLeftConstraint.constant = -width + translationX - 15
                
                let ratio = translationX / width
                let alphaValue = ratio * MENUBACKGROUND_OPACITY_END
                fadeView.alpha = alphaValue
            }
        } else {
            // if the menu was dragged less than half of it's width, close it. Otherwise, open it.
            if menuLeftConstraint.constant < -width / 2 {
                self.closeHamburgerMenu()
            } else {
                self.openHamburgerMenu()
            }
        }
    }
    
    @objc private func gesturePan(_ sender: UIPanGestureRecognizer) {
        guard let menuLeftConstraint = menuLeftConstraint else { return }

        let width = hamburgerMenuView.frame.width
        
        if sender.state == UIGestureRecognizerState.began {
            // do nothing
        } else if sender.state == UIGestureRecognizerState.changed {
            let translationX = sender.translation(in: sender.view).x
            if translationX > 0 {
                menuLeftConstraint.constant = -15 + sqrt(translationX)
                hamburgerMenuView.animationStep(progress: 1)
                fadeView.alpha = MENUBACKGROUND_OPACITY_END
            } else if translationX < -width - 15 {
                menuLeftConstraint.constant = -width
                hamburgerMenuView.animationStep(progress: 0)
                fadeView.alpha = 0
            } else {
                menuLeftConstraint.constant = translationX - 15
                
                let ratio = (width + translationX - 15) / width
                let alphaValue = ratio
                fadeView.alpha = alphaValue * MENUBACKGROUND_OPACITY_END
                hamburgerMenuView.animationStep(progress: ratio)
            }
            view.layoutIfNeeded()
        } else {
            if menuLeftConstraint.constant < -width / 2 {
                self.closeHamburgerMenu()
            } else {
                self.openHamburgerMenu()
            }
        }
    }

    
    private func addHamburgerMenu() {
        // set closer delegate
        hamburgerMenuView.setCloser(supervc: self)
        
        hamburgerMenuView.addButton(title: S.MenuButton.security, icon: #imageLiteral(resourceName: "hamburger_002Shield")) {
            self.store.perform(action: HamburgerActions.Present(modal: .securityCenter))
        }
//        hamburgerMenuView.addButton(title: S.MenuButton.support, icon: #imageLiteral(resourceName: "hamburger_001Info")) {
//            self.store.perform(action: HamburgerActions.Present(modal: .support))
//        }
        hamburgerMenuView.addButton(title: S.MenuButton.settings, icon: #imageLiteral(resourceName: "hamburger_003Settings")) {
            self.store.perform(action: HamburgerActions.Present(modal: .settings))
        }
        hamburgerMenuView.addButton(title: S.MenuButton.lock, icon: #imageLiteral(resourceName: "hamburger_004Locked")) {
            self.store.perform(action: HamburgerActions.Present(modal: .lockWallet))
        }
        
        view.addSubview(fadeView)
        view.addSubview(hamburgerMenuView)
        
        menuLeftConstraint = hamburgerMenuView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        menuWidthConstraint = hamburgerMenuView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        
        hamburgerMenuView.constrain([
            menuLeftConstraint,
            menuWidthConstraint,
            hamburgerMenuView.topAnchor.constraint(equalTo: view.topAnchor),
            hamburgerMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        hamburgerMenuView.backgroundColor = .black
        
        let tapper = UITapGestureRecognizer()
        tapper.numberOfTapsRequired = 1
        tapper.numberOfTouchesRequired = 1
        tapper.addTarget(self, action: #selector(fadeViewTap))
        fadeView.addGestureRecognizer(tapper)
        
        let panner = UIPanGestureRecognizer()
        panner.addTarget(self, action: #selector(gesturePan(_:)))
        fadeView.addGestureRecognizer(panner)
        
        edgeGesture.addTarget(self, action: #selector(gestureScreenEdgePan))
        edgeGesture.edges = .left
        view.addGestureRecognizer(edgeGesture)
        
        fadeView.constrain(toSuperviewEdges: nil)
        footerView.menuCallback = { () -> Void in
            self.openHamburgerMenu()
        }
    }
    
    @objc private func fadeViewTap() {
        closeHamburgerMenu()
    }
    
    func openHamburgerMenu() {
        guard !hamburgerMenuViewIsAnimating else { return }
        hamburgerMenuViewIsAnimating = true
        
        menuLeftConstraint?.constant = -15
        // fadeView.alpha = 0
        fadeView.isHidden = false
        
        UIView.spring(0.3, animations: {
            self.view.layoutIfNeeded()
            self.fadeView.alpha = self.MENUBACKGROUND_OPACITY_END
            self.hamburgerMenuView.animationStep(progress: 1.0)
        }, completion: { (finished) in
            self.edgeGesture.isEnabled = false
            self.hamburgerMenuViewIsAnimating = false
        })
    }
    
    func closeHamburgerMenu() {
        guard !hamburgerMenuViewIsAnimating else { return }
        hamburgerMenuViewIsAnimating = true
        menuLeftConstraint?.constant = -hamburgerMenuView.frame.width
        
        UIView.spring(0.3, animations: {
        // UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.fadeView.alpha = 0.0
            self.hamburgerMenuView.animationStep(progress: 0)
        }) { (finished) in
            self.edgeGesture.isEnabled = true
            self.fadeView.isHidden = true
            self.hamburgerMenuViewIsAnimating = false
        }
    }
    
    private func addBalanceView() {
        view.addSubview(balanceView)
    }
    
    private func addSegmentedView() {
        view.addSubview(menu)
        menu.buttonTemplates = [
            S.TransactionView.all.uppercased(),
            S.TransactionView.sent.uppercased(),
            S.TransactionView.received.uppercased()
        ]
        menu.callback = { (oldIdx, idx) -> () in
            let forward = (idx > oldIdx)
            self.pageController.setViewControllers([self.pages[idx]], direction: forward ? .forward : .reverse, animated: true, completion: nil)
        }
        menu.scrollToTopCallback = { (idx) -> () in
            switch(idx) {
            case 0:
                self.transactionsTableView.tableView.setContentOffset(CGPoint.zero, animated: true)
                break
            case 1:
                self.transactionsTableViewForSentTransactions.tableView.setContentOffset(CGPoint.zero, animated: true)
                break
            case 2:
                self.transactionsTableViewForReceivedTransactions.tableView.setContentOffset(CGPoint.zero, animated: true)
                break
            default:
                break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldShowStatusBar = true

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        menu.update()
        
        menuLeftConstraint?.constant = -hamburgerMenuView.frame.width
        hamburgerMenuView.layoutIfNeeded()
        fadeView.alpha = 0
        fadeView.isHidden = true
    }
    
    private func addSubviews() {
#if REBRAND
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Click the Digi-ID logo to launch the scanner"
        descriptionLabel.textColor = UIColor.gray
        
        view.backgroundColor = .white
        view.addSubview(descriptionLabel)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let scale: CGFloat = 0.7
        let imageViewHeight = scale * view.frame.width / image.size.width * image.size.height
        
        descriptionLabel.lineBreakMode = .byWordWrapping
        //descriptionLabel.layer.borderColor = UIColor.red.cgColor
        //descriptionLabel.layer.borderWidth = 1.0
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 70.0)
        ])
#else
        view.addSubview(balanceView)
        view.addSubview(headerContainer)
#endif
        
        addChildViewController(syncViewController)
        view.addSubview(syncViewController.view)

        view.addSubview(footerView)
        headerContainer.addSubview(searchHeaderview)
    }

    private func addConstraints() {
        balanceView.constrain([
            balanceView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            balanceView.leftAnchor.constraint(equalTo: view.leftAnchor),
            balanceView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        menu.constrain([
            menu.topAnchor.constraint(equalTo: balanceView.bottomAnchor),
            menu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            menu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            menu.heightAnchor.constraint(equalToConstant: 60)
        ])

        footerView.constrainBottomCorners(sidePadding: 0, bottomPadding: 0)
        footerView.constrain([
            footerView.constraint(.height, constant: E.isIPhoneX ? footerHeight + 19.0 : footerHeight)
        ])
        searchHeaderview.constrain(toSuperviewEdges: nil)
        
        syncViewController.view.constrain(toSuperviewEdges: nil)
    }
    
    var kvStore: BRReplicatedKVStore? = nil {
        didSet {
            guard kvStore != nil else { return }
            transactionsTableView.kvStore = kvStore
            transactionsTableViewForSentTransactions.kvStore = kvStore
            transactionsTableViewForReceivedTransactions.kvStore = kvStore
        }
    }

    private func addSubscriptions() {
        store.subscribe(self, selector: { $0.walletState.syncProgress != $1.walletState.syncProgress }, callback: { state in
            
            self.syncViewController.updateSyncState(
                state: nil,
                percentage: state.walletState.syncProgress * 100.0,
                blockHeight: state.walletState.blockHeight,
                date: Date(timeIntervalSince1970: TimeInterval(state.walletState.lastBlockTimestamp))
            )
        })
        
        store.lazySubscribe(self, selector: { $0.walletState.syncState != $1.walletState.syncState }, callback: { state in
            guard let peerManager = self.walletManager?.peerManager else { return }
            
            self.syncViewController.updateSyncState(
                state: state.walletState.syncState,
                percentage: state.walletState.syncProgress * 100.0,
                blockHeight: state.walletState.blockHeight,
                date: Date(timeIntervalSince1970: TimeInterval(exactly: state.walletState.lastBlockTimestamp)!)
            )
            
            if state.walletState.syncState == .success {
                self.syncViewController.view.isHidden = true
				self.syncViewController.hideProgress()
            } else if peerManager.shouldShowSyncingView {
                self.syncViewController.view.isHidden = false
				self.syncViewController.showUpProgress()
            } else {
                self.syncViewController.view.isHidden = true
				self.syncViewController.hideProgress()
            }
        })

        store.subscribe(self, selector: { $0.isLoadingTransactions != $1.isLoadingTransactions }, callback: {
            if $0.isLoadingTransactions {
                self.loadingDidStart()
            } else {
                self.hideLoadingView()
            }
        })
        store.subscribe(self, selector: { $0.isLoginRequired != $1.isLoginRequired }, callback: { self.isLoginRequired = $0.isLoginRequired })
        store.subscribe(self, name: .showStatusBar, callback: { _ in
            self.shouldShowStatusBar = true
        })
        store.subscribe(self, name: .hideStatusBar, callback: { _ in
            self.shouldShowStatusBar = false
        })
    }

    private func setInitialData() {
//        searchHeaderview.didChangeFilters = { [weak self] filters in
//            self?.transactionsTableView.filters = filters
//        }
    }

    private func loadingDidStart() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            if !self.didEndLoading {
                self.showLoadingView()
            }
        })
    }

    private func showLoadingView() {
        view.insertSubview(transactionsLoadingView, belowSubview: headerContainer)
        transactionsLoadingViewTop = transactionsLoadingView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -transactionsLoadingViewHeightConstant)
        transactionsLoadingView.constrain([
            transactionsLoadingViewTop,
            transactionsLoadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            transactionsLoadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            transactionsLoadingView.heightAnchor.constraint(equalToConstant: transactionsLoadingViewHeightConstant) ])
        transactionsLoadingView.progress = 0.01
        view.layoutIfNeeded()
        UIView.animate(withDuration: C.animationDuration, animations: {
            self.transactionsTableView.tableView.verticallyOffsetContent(transactionsLoadingViewHeightConstant)
            self.transactionsLoadingViewTop?.constant = 0.0
            self.view.layoutIfNeeded()
        }) { completed in
            //This view needs to be brought to the front so that it's above the headerview shadow. It looks weird if it's below.
            self.view.insertSubview(self.transactionsLoadingView, aboveSubview: self.headerContainer)
        }
        loadingTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateLoadingProgress), userInfo: nil, repeats: true)
    }
    
    private func hideLoadingView() {
        didEndLoading = true
        guard self.transactionsLoadingViewTop?.constant == 0.0 else { return } //Should skip hide if it's not shown
        loadingTimer?.invalidate()
        loadingTimer = nil
        transactionsLoadingView.progress = 1.0
        view.insertSubview(transactionsLoadingView, belowSubview: headerContainer)
        if transactionsLoadingView.superview != nil {
            UIView.animate(withDuration: C.animationDuration, animations: {
                self.transactionsTableView.tableView.verticallyOffsetContent(-transactionsLoadingViewHeightConstant)
                self.transactionsLoadingViewTop?.constant = -transactionsLoadingViewHeightConstant
                self.view.layoutIfNeeded()
            }) { completed in
                self.transactionsLoadingView.removeFromSuperview()
            }
        }
    }

    @objc private func updateLoadingProgress() {
        transactionsLoadingView.progress = transactionsLoadingView.progress + (1.0 - transactionsLoadingView.progress)/8.0
    }

    private func addTemporaryStartupViews() {
        view.addSubview(tempView)
        tempView.constrain(toSuperviewEdges: nil)
        showActivity(tempView)
        
        guardProtected(queue: DispatchQueue.main) {
            if !WalletManager.staticNoWallet {
                self.addChildViewController(self.tempLoginView, layout: {
                    self.tempLoginView.view.constrain(toSuperviewEdges: nil)
                })
            } else {
                self.tempView.removeFromSuperview()
                
                let startView = StartViewController(
                    store: self.store,
                    didTapCreate: {},
                    didTapRecover: {}
                )
                self.addChildViewController(startView, layout: {
                    startView.view.constrain(toSuperviewEdges: nil)
                    startView.view.isUserInteractionEnabled = false
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    startView.remove()
                })
            }
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex != 0 {
                // go to previous page in array
                return self.pages[viewControllerIndex - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex < self.pages.count - 1 {
                // go to next page in array
                return self.pages[viewControllerIndex + 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        if let viewControllers = pageViewController.viewControllers {
            if let viewControllerIndex = self.pages.index(of: viewControllers[0]) {
                menu.updateSegmentedControlSegs(index: viewControllerIndex)
            }
        }
    }
    
    private func addTransactionsView() {
        addChildViewController(pageController, layout: {
            pageController.view.constrain([
                pageController.view.topAnchor.constraint(equalTo: menu.bottomAnchor),
                pageController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                pageController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                pageController.view.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
            ])
        })
        
        let insets = UIEdgeInsets(
            top: 15,
            left: 0,
            bottom: E.isIPhoneX ? footerHeight + C.padding[2] + 19 : footerHeight + C.padding[2],
            right: 0
        )
        
        transactionsTableView.tableView.contentInset = insets
        transactionsTableViewForSentTransactions.tableView.contentInset = insets
        transactionsTableViewForReceivedTransactions.tableView.contentInset = insets
        
        pageController.dataSource = self
        pageController.delegate = self
        pages.append(transactionsTableView)
        pages.append(transactionsTableViewForSentTransactions)
        pages.append(transactionsTableViewForReceivedTransactions)
        pageController.setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }

    private func addAppLifecycleNotificationEvents() {
        NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { note in
            UIView.animate(withDuration: 0.1, animations: {
                self.blurView.alpha = 0.0
            }, completion: { _ in
                self.blurView.removeFromSuperview()
            })
        }
        NotificationCenter.default.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil) { note in
            if !self.isLoginRequired && !self.store.state.isPromptingBiometrics {
                self.blurView.alpha = 1.0
                self.view.addSubview(self.blurView)
                self.blurView.constrain(toSuperviewEdges: nil)
            }
        }
    }

    private func showJailbreakWarnings(isJailbroken: Bool) {
        guard isJailbroken else { return }
        let totalSent = walletManager?.wallet?.totalSent ?? 0
        let message = totalSent > 0 ? S.JailbreakWarnings.messageWithBalance : S.JailbreakWarnings.messageWithBalance
        let alert = UIAlertController(title: S.JailbreakWarnings.title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.JailbreakWarnings.ignore, style: .default, handler: nil))
        if totalSent > 0 {
            alert.addAction(UIAlertAction(title: S.JailbreakWarnings.wipe, style: .default, handler: nil)) //TODO - implement wipe
        } else {
            alert.addAction(UIAlertAction(title: S.JailbreakWarnings.close, style: .default, handler: { _ in
                exit(0)
            }))
        }
        present(alert, animated: true, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return searchHeaderview.isHidden ? .lightContent : .default
    }

    override var prefersStatusBarHidden: Bool {
        return !shouldShowStatusBar
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


