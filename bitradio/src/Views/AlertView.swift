//
//  AlertView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-22.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

enum AlertType {
    case pinSet(callback: () -> Void)
    case paperKeySet(callback: () -> Void)
    case sendSuccess
    case addressesCopied
    case sweepSuccess(callback: () -> Void)

    var header: String {
        switch self {
        case .pinSet:
            return S.Alerts.pinSet
        case .paperKeySet:
            return S.Alerts.paperKeySet
        case .sendSuccess:
            return S.Alerts.sendSuccess
        case .addressesCopied:
            return S.Alerts.copiedAddressesHeader
        case .sweepSuccess:
            return S.Import.success
        }
    }

    var subheader: String {
        switch self {
        case .pinSet:
            return ""
        case .paperKeySet:
            return S.Alerts.paperKeySetSubheader
        case .sendSuccess:
            return S.Alerts.sendSuccessSubheader
        case .addressesCopied:
            return S.Alerts.copiedAddressesSubheader
        case .sweepSuccess:
            return S.Import.successBody
        }
    }

    var icon: UIView {
        return CheckView(120)
    }
}

extension AlertType : Equatable {}

func ==(lhs: AlertType, rhs: AlertType) -> Bool {
    switch (lhs, rhs) {
    case (.pinSet(_), .pinSet(_)):
        return true
    case (.paperKeySet(_), .paperKeySet(_)):
        return true
    case (.sendSuccess, .sendSuccess):
        return true
    case (.addressesCopied, .addressesCopied):
        return true
    case (.sweepSuccess(_), .sweepSuccess(_)):
        return true
    default:
        return false
    }
}

class AlertView : UIView {

    private let type: AlertType
    private let header = UILabel()
    private let subheader = UILabel()
    private let icon: UIView
    private var confettiLeft: UIImageView
    private var confettiRight: UIImageView
    private let iconSize: CGFloat = 120

    init(type: AlertType) {
        self.type = type
        self.icon = type.icon
        confettiLeft = UIImageView(image: #imageLiteral(resourceName: "confetti_left"))
        confettiRight = UIImageView(image: #imageLiteral(resourceName: "confetti_left"))
        
        icon.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        super.init(frame: .zero)
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        setupSubviews()
    }

    func animate() {
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 15, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.icon.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { _ in
            guard let animatableIcon = self.icon as? AnimatableIcon else { return }
            animatableIcon.animate()
        })
        
//        (0.4, animations: {
//            self.icon.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        }, completion: { _ in
//            guard let animatableIcon = self.icon as? AnimatableIcon else { return }
//            animatableIcon.animate()
//        })
    }

    private func setupSubviews() {
        confettiLeft.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        addSubview(header)
        addSubview(subheader)
        addSubview(icon)
        
        addSubview(confettiLeft)
        addSubview(confettiRight)
        
        setData()
        addConstraints()
    }

    private func setData() {
        self.backgroundColor = C.Colors.dark2
        
        header.text = type.header
        header.textAlignment = .center
        header.font = UIFont.customBold(size: 14.0)
        header.textColor = .white

        icon.backgroundColor = .clear

        subheader.text = type.subheader
        subheader.textAlignment = .center
        subheader.font = UIFont.customBody(size: 12.0)
        subheader.textColor = C.Colors.greyBlue
    }

    private func addConstraints() {

        //NB - In this alert view, constraints shouldn't be pinned to the bottom
        //of the view because the bottom actually extends off the bottom of the screen a bit.
        //It extends so that it still covers up the underlying view when it bounces on screen.
        
        icon.constrain([
            icon.constraint(.centerX, toView: self, constant: nil),
            icon.topAnchor.constraint(equalTo: self.topAnchor, constant: 80),
            icon.constraint(.width, constant: iconSize),
            icon.constraint(.height, constant: iconSize) ])
        
        confettiLeft.constrain([
            confettiLeft.trailingAnchor.constraint(equalTo: icon.leadingAnchor, constant: -20),
            confettiLeft.heightAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 0.8),
            confettiLeft.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
        ])
        
        confettiRight.constrain([
            confettiRight.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 20),
            confettiRight.heightAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 0.8),
            confettiRight.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
        ])
        
        header.constrain([
            header.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 60),
            header.constraint(.leading, toView: self, constant: C.padding[2]),
            header.constraint(.trailing, toView: self, constant: -C.padding[2]),
        ])
        
        subheader.constrain([
            subheader.constraint(.leading, toView: self, constant: C.padding[2]),
            subheader.constraint(.trailing, toView: self, constant: -C.padding[2]),
            subheader.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
