//
//  StartViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-22.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

class DigiBackgroundView: UIView {
    private let designAdditionalImage1: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "LoginBackground1"))
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let designAdditionalImage2: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "LoginBackground2"))
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    init() {
        super.init(frame: CGRect())
        addSubviews()
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(designAdditionalImage1)
        addSubview(designAdditionalImage2)
    }
    
    private func addConstraints() {
        designAdditionalImage1.constrain([
            designAdditionalImage1.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0),
            designAdditionalImage1.topAnchor.constraint(equalTo: topAnchor, constant: 6.0),
            designAdditionalImage1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.38),
        ])
        
        designAdditionalImage2.constrain([
            designAdditionalImage2.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0),
            designAdditionalImage2.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
            designAdditionalImage2.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.72),
        ])
    }
}

class StartViewController : UIViewController {

    //MARK: - Public
    init(store: Store, didTapCreate: @escaping () -> Void, didTapRecover: @escaping () -> Void) {
        self.store = store
        self.didTapRecover = didTapRecover
        self.didTapCreate = didTapCreate
        self.faq = UIButton.buildFaqButton(store: store, articleId: ArticleIds.startView)
        super.init(nibName: nil, bundle: nil)
    }

    //MARK: - Private

    private let logo: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "DigiLogo"))
        image.contentMode = .scaleAspectFit
        image.tintColor = UIColor.whiteTint
        return image
    }()
    
    private let message = UILabel(font: .customMedium(size: 18.0), color: .whiteTint)
    // private let create = ShadowButton(title: S.StartViewController.createButton, type: .primary)
    // private let recover = ShadowButton(title: S.StartViewController.recoverButton, type: .secondary)
    
    private let create: UIButton = {
        let button = UIButton()
        let gradient = CAGradientLayer()
        button.setTitle(S.StartViewController.createButton.uppercased(), for: .normal)
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
    
    private let recover: UIButton = {
        let button = UIButton()
        button.setTitle(S.StartViewController.recoverButton, for: .normal)
        button.backgroundColor = UIColor(white: 1, alpha: 0.0)
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 13)
        button.titleLabel?.setCharacterSpacing(1.0)
        return button
    }()
    
    private let store: Store
    private let didTapRecover: () -> Void
    private let didTapCreate: () -> Void
    // private let background = LoginBackgroundView()
    private let background: UIView = {
        let view = DigiBackgroundView()
        view.backgroundColor = C.Colors.background
        return view
    }()
    
    private var faq: UIButton
    
    override func viewDidLoad() {
        view.backgroundColor = C.Colors.background
        setData()
        addSubviews()
        addConstraints()
        addButtonActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 20, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.logo.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        }) { (_) in
            
        }
        super.viewDidAppear(animated)
    }

    private func setData() {
        message.text = S.StartViewController.message
        message.lineBreakMode = .byWordWrapping
        message.numberOfLines = 0
        message.textAlignment = .center
        faq.tintColor = .whiteTint
    }

    private func addSubviews() {
        view.addSubview(background)
        view.addSubview(logo)
        view.addSubview(message)
        view.addSubview(create)
        view.addSubview(recover)
        view.addSubview(faq)
        
        faq.isHidden = true // TODO: Writeup support/FAQ documentation for bitradio wallet
        logo.transform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
    }
    
    override func viewDidLayoutSubviews() {
        // update the gradient frame
        if create.layer.sublayers != nil {
            create.layer.sublayers!.first!.frame = create.bounds
        }
    }

    private func addConstraints() {
        background.constrain(toSuperviewEdges: nil)
        
        let centerConstraint = logo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
        centerConstraint.priority = .init(600)
        
        logo.constrain([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            centerConstraint,
            logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: C.Sizes.logoWidthPercentage)
        ])
        
        message.constrain([
            message.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            message.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 32),
            message.bottomAnchor.constraint(equalTo: create.topAnchor, constant: -32),
            message.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            message.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]) ])
        
        recover.constrain([
            recover.constraint(.leading, toView: view, constant: 40.0),
            recover.constraint(.bottom, toView: view, constant: -48.0),
            recover.constraint(.trailing, toView: view, constant: -40.0),
            recover.constraint(.height, constant: 30.0) ])
        create.constrain([
            create.constraint(toTop: recover, constant: -12),
            create.constraint(.centerX, toView: recover, constant: nil),
            create.constraint(.width, toView: recover, constant: nil),
            create.constraint(.height, constant: C.Sizes.buttonHeight) ])
        faq.constrain([
            faq.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: C.padding[2]),
            faq.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
            faq.widthAnchor.constraint(equalToConstant: 44.0),
            faq.heightAnchor.constraint(equalToConstant: 44.0) ])
    }

    private func addButtonActions() {
        recover.tap = didTapRecover
        create.tap = didTapCreate
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
