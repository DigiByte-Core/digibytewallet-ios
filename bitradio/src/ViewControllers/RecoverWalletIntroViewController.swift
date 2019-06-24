//
//  RecoverWalletIntroViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-02-23.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

class RecoverWalletIntroViewController : UIViewController {

    //MARK: - Public
    init(didTapNext: @escaping () -> Void) {
        self.didTapNext = didTapNext
        super.init(nibName: nil, bundle: nil)
    }

    //MARK: - Private
    private let didTapNext: () -> Void
    private let header = RadialGradientView(backgroundColor: C.Colors.background)
    
    // private let nextButton = ShadowButton(title: S.RecoverWallet.next, type: .primary)
    private let nextButton: UIButton = {
        let button = UIButton()
        let gradient = CAGradientLayer()
        button.setTitle(S.RecoverWallet.next.uppercased(), for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 13)
        button.titleLabel?.setCharacterSpacing(1.0)
        
        gradient.frame = button.bounds
        gradient.colors = [
            UIColor(red: 0x00 / 255, green: 0x66 / 255, blue: 0xCC / 255, alpha: 1).cgColor, // 0066cc
            UIColor(red: 0x00 / 255, green: 0x23 / 255, blue: 0x52 / 255, alpha: 1).cgColor, // 002352
        ]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.locations = [0.0, 1.0]
        button.layer.insertSublayer(gradient, at: 0)
        button.layer.cornerRadius = 3.0
        button.layer.masksToBounds = true
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return button
    }()
    private let label = UILabel(font: .customBody(size: 16.0))
    private let illustration = UIImageView(image: #imageLiteral(resourceName: "RecoverWalletIllustration"))

    override func viewDidLoad() {
        addSubviews()
        addConstraints()
        setData()
    }

    private func addSubviews() {
        view.addSubview(header)
        header.addSubview(illustration)
        view.addSubview(nextButton)
        view.addSubview(label)
    }

    private func addConstraints() {
        header.constrainTopCorners(sidePadding: 0.0, topPadding: 0.0)
        header.constrain([header.heightAnchor.constraint(equalToConstant: C.Sizes.largeHeaderHeight)])
        illustration.constrain([
            illustration.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            illustration.centerYAnchor.constraint(equalTo: header.centerYAnchor, constant: E.isIPhoneX ? C.padding[4] : C.padding[2]) ])
        label.constrain([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            label.topAnchor.constraint(equalTo: header.bottomAnchor, constant: C.padding[2]),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]) ])
        nextButton.constrain([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -C.padding[3]),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
            nextButton.heightAnchor.constraint(equalToConstant: C.Sizes.buttonHeight) ])
    }

    private func setData() {
        view.backgroundColor = C.Colors.background
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = S.RecoverWallet.intro
        label.textColor = C.Colors.text
        nextButton.tap = didTapNext
        title = S.RecoverWallet.header
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
