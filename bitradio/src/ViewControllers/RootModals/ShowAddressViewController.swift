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

// ToDo: export to external class
func placeLogoIntoQR(_ image: UIImage, width: CGFloat, height: CGFloat) -> UIImage? {
    guard !UserDefaults.excludeLogoInQR else { return image }
    let img = image.resize(CGSize(width: width, height: height))
    UIGraphicsBeginImageContext(CGSize(width: width, height: height))
    img?.draw(at: CGPoint.zero)
    let ctx = UIGraphicsGetCurrentContext()!
    
    ctx.saveGState()
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)
    
    let size = width / 3.5
    let logoSize = width / 4.0
    
    let rect = CGRect(x: width / 2 - size / 2, y: height / 2 - size / 2, width: size, height: size)
    ctx.interpolationQuality = .high
    ctx.setFillColor(UIColor.white.cgColor)
    ctx.fillEllipse(in: rect)
    
    let logo = #imageLiteral(resourceName: "DigiByteSymbol").resize(CGSize(width: logoSize, height: logoSize), interpolation: true)
    logo?.draw(at: CGPoint(x: width / 2 - logoSize / 2, y: height / 2 - logoSize / 2))
    
    ctx.restoreGState()
    
    let res = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return res
}


class ShowAddressViewController : UIViewController, Subscriber, Trackable {

    //MARK - Public
    var presentEmail: PresentShare?
    var presentText: PresentShare?

    init(wallet: BRWallet, store: Store) {
        self.wallet = wallet
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    //MARK - Private
    private let qrCode = UIImageView()
    private let address = UILabel(font: .customBody(size: 14.0))
    private let addressPopout = InViewAlert(type: .primary)
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
    private var requestTop: NSLayoutConstraint?
    private var requestBottom: NSLayoutConstraint?

    override func viewDidLoad() {
        addSubviews()
        addConstraints()
        setStyle()
        addActions()
        setupCopiedMessage()
        store.subscribe(self, selector: { $0.walletState.balance != $1.walletState.balance }, callback: {
            self.balance = $0.walletState.balance
        })
    }

    private func addSubviews() {
        view.addSubview(qrCode)
        view.addSubview(address)
        view.addSubview(share)
        view.addSubview(border)
        view.addSubview(addressButton)
        view.addSubview(sharePopout)
        view.addSubview(addressPopout)
        
        qrCode.contentMode = .scaleToFill
        qrCode.backgroundColor = .white
    }

    private func addConstraints() {
        qrCode.constrain([
//            qrCode.constraint(.width, constant: 186.0),
//            qrCode.constraint(.height, constant: 186.0),
            qrCode.constraint(.top, toView: view, constant: C.padding[4]),
            qrCode.constraint(.centerX, toView: view) ])
        
        qrCode.constrain([
            qrCode.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            qrCode.heightAnchor.constraint(equalTo: qrCode.widthAnchor, multiplier: 1.0),
        ])
        
        address.constrain([
            address.constraint(toBottom: qrCode, constant: C.padding[1]),
            address.constraint(.centerX, toView: view) ])
        addressPopout.heightConstraint = addressPopout.constraint(.height, constant: 0.0)
        addressPopout.constrain([
            addressPopout.constraint(toBottom: address, constant: 0.0),
            addressPopout.constraint(.centerX, toView: view),
            addressPopout.constraint(.width, toView: view),
            addressPopout.heightConstraint ])
        share.constrain([
            share.topAnchor.constraint(equalTo: address.bottomAnchor, constant: 25),
            share.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -76),
            
            share.constraint(.width, constant: 58),
            share.constraint(.height, constant: 58),
            share.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: E.isIPhoneX ? -C.padding[5] : -C.padding[2])
        ])
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
        addressButton.constrain([
            addressButton.leadingAnchor.constraint(equalTo: address.leadingAnchor, constant: -C.padding[1]),
            addressButton.topAnchor.constraint(equalTo: qrCode.topAnchor),
            addressButton.trailingAnchor.constraint(equalTo: address.trailingAnchor, constant: C.padding[1]),
            addressButton.bottomAnchor.constraint(equalTo: address.bottomAnchor, constant: C.padding[1]) ])
        
    
    }

    private func setStyle() {
        view.backgroundColor = .clear
        address.textColor = C.Colors.text
        sharePopout.clipsToBounds = true
        addressButton.setBackgroundImage(UIImage.imageForColor(.secondaryShadow), for: .highlighted)
        addressButton.layer.cornerRadius = 4.0
        addressButton.layer.masksToBounds = true
        setReceiveAddress()
    }

    private func setReceiveAddress() {
        address.text = wallet.receiveAddress
        
        
        
        qrCode.image = UIImage.qrCode(data: "\(address.text!)".data(using: .utf8)!, color: CIColor(color: .black))?
            .resize(CGSize(width: qrSize, height: qrSize))!
        
        .resize(CGSize(width: qrSize, height: qrSize))!
        
        
        qrCode.image = placeLogoIntoQR(qrCode.image!, width: qrSize, height: qrSize)
    }

    private func addActions() {
        addressButton.tap = { [weak self] in
            self?.addressTapped()
        }
        share.addTarget(self, action: #selector(ShowAddressViewController.shareTapped), for: .touchUpInside)
    }

    private func setupCopiedMessage() {
        let copiedMessage = UILabel(font: .customMedium(size: 14.0))
        copiedMessage.textColor = .white
        copiedMessage.text = S.Receive.copied
        copiedMessage.textAlignment = .center
        addressPopout.contentView = copiedMessage
    }

    @objc private func shareTapped() {
        if
            let qrImage = UIImage.qrCode(data: "\(address.text!)".data(using: .utf8)!, color: CIColor(color: .black))?.resize(CGSize(width: 512, height: 512)),
            let qrImageLogo = placeLogoIntoQR(qrImage, width: 512, height: 512),
            let imgData = UIImageJPEGRepresentation(qrImageLogo, 1.0),
            let jpegRep = UIImage(data: imgData),
            let address = address.text {
                let paymentURI = PaymentRequest.requestString(withAddress: address)
                let activityViewController = UIActivityViewController(activityItems: [paymentURI, jpegRep], applicationActivities: nil)
                activityViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                    guard completed else { return }
                    self.store.trigger(name: .lightWeightAlert(S.Import.success))
                }
                activityViewController.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
                present(activityViewController, animated: true, completion: {})
        }
    }

    @objc private func addressTapped() {
        guard let text = address.text else { return }
        //saveEvent("receive.copiedAddress")
        UIPasteboard.general.string = text
        toggle(alertView: addressPopout, shouldAdjustPadding: false, shouldShrinkAfter: true)
        if sharePopout.isExpanded {
            toggle(alertView: sharePopout, shouldAdjustPadding: true)
        }
    }

    private func toggle(alertView: InViewAlert, shouldAdjustPadding: Bool, shouldShrinkAfter: Bool = false) {
        share.isEnabled = false
        address.isUserInteractionEnabled = false

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
            self.address.isUserInteractionEnabled = true
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

extension ShowAddressViewController : ModalDisplayable {
    var faqArticleId: String? {
        return ArticleIds.receiveBitcoin
    }

    var modalTitle: String {
#if REBRAND
        return "Login Key"
#else
        return S.UnlockScreen.myAddress
#endif
    }
}
