//
//  ReceiveViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-30.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

private let qrSize: CGFloat = 512.0
private let smallButtonHeight: CGFloat = 32.0
private let buttonPadding: CGFloat = 20.0
private let smallSharePadding: CGFloat = 12.0
private let largeSharePadding: CGFloat = 20.0

typealias PresentShare = (String, UIImage) -> Void

class ReceiveViewController : UIViewController, Subscriber, Trackable {

    //MARK - Public
    var presentEmail: PresentShare?
    var presentText: PresentShare?

    init(wallet: BRWallet, store: Store, isRequestAmountVisible: Bool) {
        self.wallet = wallet
        self.isRequestAmountVisible = isRequestAmountVisible
        self.amountView = AmountViewController(store: store, isPinPadExpandedAtLaunch: true, scrollDownOnTap: true, isRequesting: true, hideMaxButton: true)
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    //MARK - Private
    private let amountView: AmountViewController
    private let qrCode = UIImageView()
    private let requestString = UILabel(font: .customBody(size: 14.0))
    private let descriptionLabel = UILabel(font: .customBody(size: 14.0), color: C.Colors.text)
    private let addressPopout = InViewAlert(type: .primary)
    
    private let segwitSwitch: UISwitch = {
        let v = UISwitch()
        v.isOn = true
        return v
    }()
    
    private let share: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .clear
        btn.setBackgroundImage(#imageLiteral(resourceName: "shareButton"), for: .normal)
        return btn
    }()
    private let sharePopout = InViewAlert(type: .secondary)
    private let border = UIView()
    private let addressButton = UIButton(type: .system)
    private var topSharePopoutConstraint: NSLayoutConstraint?
    private let wallet: BRWallet
    private let store: Store
    
    private var balance: UInt64? = nil {
        didSet {
            if let newValue = balance, let oldValue = oldValue {
                if newValue > oldValue {
                    setReceiveAddress()
                }
            }
        }
    }
    fileprivate let isRequestAmountVisible: Bool
    private var requestTop: NSLayoutConstraint?
    private var requestBottom: NSLayoutConstraint?
    private var address: String?
    
    private var amount: Satoshis? {
        didSet {
            let address = self.address!
            if let amount = amount, amount > 0 {
                addressButton.isUserInteractionEnabled = true
                qrCode.layer.opacity = 1
                requestString.layer.opacity = 1
                share.isUserInteractionEnabled = true
                share.layer.opacity = 1
                descriptionLabel.alpha = 0
                let amountStr: CGFloat = CGFloat(amount.rawValue) / 100000000.0
                requestString.text = "Receive \(amountStr) \(C.btcCurrencyCode) \(S.Confirmation.to.lowercased())\n\(address)"
                setQrCode()
            } else {
                addressButton.isUserInteractionEnabled = true
                qrCode.layer.opacity = 1.0
                share.layer.opacity = 1.0
                requestString.layer.opacity = 1.0
                descriptionLabel.alpha = 1
                share.isUserInteractionEnabled = true
                requestString.text = "Receive to\n\(address)" // ToDo: Export language
                setReceiveAddress()
            }
        }
    }

    override func viewDidLoad() {
        addSubviews()
        addConstraints()
        setStyle()
        addActions()
        setupCopiedMessage()
        
        qrCode.contentMode = .scaleToFill
        
        store.subscribe(self, selector: { $0.walletState.balance != $1.walletState.balance }, callback: {
            self.balance = $0.walletState.balance
        })
    }

    private func addSubviews() {
        view.addSubview(qrCode)
        view.addSubview(descriptionLabel)
        view.addSubview(requestString)
        view.addSubview(share)
        view.addSubview(addressPopout)
        view.addSubview(sharePopout)
        view.addSubview(border)
        view.addSubview(addressButton)
        view.addSubview(segwitSwitch)
    }

    private func addConstraints() {
        qrCode.constrain([
//            qrCode.constraint(.width, toView: view, multiplier: 0.7),
//            qrCode.constraint(.height, toView: view, multiplier: 0.7),
            qrCode.constraint(.top, toView: view, constant: C.padding[4]),
            qrCode.constraint(.centerX, toView: view) ])
        
        qrCode.constrain([
            qrCode.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            qrCode.heightAnchor.constraint(equalTo: qrCode.widthAnchor, multiplier: 1.0),
        ])
        
        descriptionLabel.constrain([
            descriptionLabel.centerXAnchor.constraint(equalTo: qrCode.centerXAnchor),
            descriptionLabel.centerYAnchor.constraint(equalTo: qrCode.centerYAnchor),
        ])
        requestString.constrain([
            requestString.constraint(toBottom: qrCode, constant: C.padding[1]),
            requestString.constraint(.leading, toView: view, constant: 30),
            requestString.constraint(.trailing, toView: view, constant: -30)
        ])
        addressPopout.heightConstraint = addressPopout.constraint(.height, constant: 0.0)
        addressPopout.constrain([
            addressPopout.constraint(toBottom: requestString, constant: 0.0),
            addressPopout.constraint(.centerX, toView: view),
            addressPopout.constraint(.width, toView: view),
            addressPopout.heightConstraint ])
        share.constrain([
            share.topAnchor.constraint(equalTo: requestString.bottomAnchor, constant: 25),
            share.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -76),
            share.constraint(.width, constant: 58),
            share.constraint(.height, constant: 58) ])
        sharePopout.heightConstraint = sharePopout.constraint(.height, constant: 0.0)
        topSharePopoutConstraint = sharePopout.constraint(toBottom: share, constant: largeSharePadding)
        sharePopout.constrain([
            topSharePopoutConstraint,
            sharePopout.constraint(.centerX, toView: view),
            sharePopout.constraint(.width, toView: view),
            sharePopout.heightConstraint ])
        border.constrain([
            border.constraint(.width, toView: view),
            border.constraint(toBottom: sharePopout, constant: 0.0),
            border.constraint(.centerX, toView: view),
            border.constraint(.height, constant: 1.0) ])

        addChildViewController(amountView, layout: {
            amountView.view.constrain([
                amountView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                amountView.view.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20),
                amountView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                amountView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: E.isIPhoneXOrGreater ? -C.padding[5] : -C.padding[2])
                ])
            // amountView.closePinPad()
        })
        
        addressButton.constrain([
            addressButton.leadingAnchor.constraint(equalTo: requestString.leadingAnchor, constant: -C.padding[1]),
            addressButton.topAnchor.constraint(equalTo: qrCode.topAnchor),
            addressButton.trailingAnchor.constraint(equalTo: requestString.trailingAnchor, constant: C.padding[1]),
            addressButton.bottomAnchor.constraint(equalTo: requestString.bottomAnchor, constant: C.padding[1]) ])
        
        segwitSwitch.constrain([
            segwitSwitch.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            segwitSwitch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
        ])
    }

    private func setStyle() {
        view.backgroundColor = .clear
        requestString.textColor = C.Colors.text
        requestString.numberOfLines = 3
        requestString.text = "\n\n"
        requestString.textAlignment = .center
        requestString.lineBreakMode = .byCharWrapping
        share.isUserInteractionEnabled = true
        share.layer.opacity = 1.0
        sharePopout.clipsToBounds = true
        addressButton.setBackgroundImage(UIImage.imageForColor(.secondaryShadow), for: .highlighted)
        addressButton.layer.cornerRadius = 4.0
        addressButton.layer.masksToBounds = true
        
        qrCode.layer.opacity = 1.0
        qrCode.backgroundColor = .white
        addressButton.isUserInteractionEnabled = true
        
        descriptionLabel.alpha = 1.0
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = ""
        
        setReceiveAddress()
        amount = nil
        
        segwitSwitch.addTarget(self, action: #selector(segwitSwitchTapped), for: .valueChanged)
    }
    
    @objc
    private func segwitSwitchTapped() {
        let addr = wallet.getReceiveAddress(useSegwit: segwitSwitch.isOn)
        address = addr
        
        self.amount = { self.amount }() // triggers setReceiveAddress
    }
    
    private func setQrCode(){
        guard let amount = amount else { return }
        let addr = wallet.getReceiveAddress(useSegwit: segwitSwitch.isOn)
        let request = PaymentRequest.requestString(withAddress: addr, forAmount: amount.rawValue)
        qrCode.image = UIImage.qrCode(data: request.data(using: .utf8)!, color: CIColor(color: .black))?
            .resize(CGSize(width: qrSize, height: qrSize))!
        
        guard !UserDefaults.excludeLogoInQR else { return }
        qrCode.image = placeLogoIntoQR(qrCode.image!, width: qrSize, height: qrSize)
    }

    private func setReceiveAddress() {
        let addr = wallet.getReceiveAddress(useSegwit: segwitSwitch.isOn)
        address = addr
        
        qrCode.image = UIImage.qrCode(data: "\(addr)".data(using: .utf8)!, color: CIColor(color: .black))?
            .resize(CGSize(width: qrSize, height: qrSize))!
        
        guard !UserDefaults.excludeLogoInQR else { return }
        qrCode.image = placeLogoIntoQR(qrCode.image!, width: qrSize, height: qrSize)
    }

    private func addActions() {
        addressButton.tap = { [weak self] in
            self?.addressTapped()
        }
        
        share.addTarget(self, action: #selector(ReceiveViewController.shareTapped), for: .touchUpInside)
        
        amountView.didUpdateAmount = { [weak self] amount in
            self?.amount = amount
        }
    }
    
    @objc private func shareTapped() {
        let addr = wallet.getReceiveAddress(useSegwit: segwitSwitch.isOn)
        
        let request =
            amount != nil ? PaymentRequest.requestString(withAddress: addr, forAmount: amount!.rawValue) : PaymentRequest.requestString(withAddress: addr)
        
        if
            let qrImage = UIImage.qrCode(data: request.data(using: .utf8)!, color: CIColor(color: .black))?.resize(CGSize(width: 512, height: 512)),
            let qrImageLogo = UserDefaults.excludeLogoInQR ? qrImage : placeLogoIntoQR(qrImage, width: 512, height: 512),
            let imgData = UIImageJPEGRepresentation(qrImageLogo, 1.0),
            let jpegRep = UIImage(data: imgData) {
                let activityViewController = UIActivityViewController(activityItems: [request, jpegRep], applicationActivities: nil)
                activityViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                    guard completed else { return }
                    self.store.trigger(name: .lightWeightAlert(S.Import.success))
                }
                activityViewController.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
                present(activityViewController, animated: true, completion: {})
        }
    }

    private func setupCopiedMessage() {
        let copiedMessage = UILabel(font: .customMedium(size: 14.0))
        copiedMessage.textColor = .white
        copiedMessage.text = S.Receive.copied
        copiedMessage.textAlignment = .center
        addressPopout.contentView = copiedMessage
    }

    @objc private func addressTapped() {
        let addr = wallet.getReceiveAddress(useSegwit: segwitSwitch.isOn)
        
        if let amount = amount {
            let req = PaymentRequest.requestString(withAddress: addr, forAmount: amount.rawValue)
            UIPasteboard.general.string = req
            toggle(alertView: addressPopout, shouldAdjustPadding: false, shouldShrinkAfter: true)
            if sharePopout.isExpanded {
                toggle(alertView: sharePopout, shouldAdjustPadding: true)
            }
        } else {
            UIPasteboard.general.string = addr
            toggle(alertView: addressPopout, shouldAdjustPadding: false, shouldShrinkAfter: true)
            if sharePopout.isExpanded {
                toggle(alertView: sharePopout, shouldAdjustPadding: true)
            }
        }
    }

    private func toggle(alertView: InViewAlert, shouldAdjustPadding: Bool, shouldShrinkAfter: Bool = false) {
        share.isEnabled = false
        requestString.isUserInteractionEnabled = false

        var deltaY = alertView.isExpanded ? -alertView.height : alertView.height
        if shouldAdjustPadding {
            if deltaY > 0 {
                deltaY -= (largeSharePadding - smallSharePadding)
            } else {
                deltaY += (largeSharePadding - smallSharePadding)
            }
        }

        if alertView.isExpanded {
            alertView.contentView?.isHidden = true
        }

        UIView.spring(C.animationDuration, animations: {
            if shouldAdjustPadding {
                let newPadding = self.sharePopout.isExpanded ? largeSharePadding : smallSharePadding
                self.topSharePopoutConstraint?.constant = newPadding
            }
            alertView.toggle()
            self.parent?.view.layoutIfNeeded()
        }, completion: { _ in
            alertView.isExpanded = !alertView.isExpanded
            self.share.isEnabled = true
            self.requestString.isUserInteractionEnabled = true
            alertView.contentView?.isHidden = false
            if shouldShrinkAfter {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    if alertView.isExpanded {
                        self.toggle(alertView: alertView, shouldAdjustPadding: shouldAdjustPadding)
                    }
                })
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReceiveViewController : ModalDisplayable {
    var faqArticleId: String? {
        return ArticleIds.receiveBitcoin
    }

    var modalTitle: String {
#if REBRAND
        return "Login Key"
#else
        return S.Receive.title
#endif
    }
}
