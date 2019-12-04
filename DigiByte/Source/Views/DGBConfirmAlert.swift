//
//  DGBConfirmAlert.swift
//  DigiByte
//
//  Created by Julian Jäger on 01.12.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

fileprivate class ConfirmButton: DGBHapticButton {
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? backgroundColor!.withAlphaComponent(0.8) : backgroundColor!.withAlphaComponent(1.0)
        }
    }
}

class DGBModalWindow: UIViewController {
    private let headerTitle: String
    private let titleView = UIView()
    private let titleLabel = UILabel()
    
    let containerView = UIView()
    let stackView = UIStackView()
    
    init(title: String) {
        self.headerTitle = title
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self

        addSubviews()
        addConstraints()
        setStyle()
    }
    
    private func addSubviews() {
        view.addSubview(containerView)
        
        titleView.addSubview(titleLabel)
        containerView.addSubview(titleView)
        containerView.addSubview(stackView)
    }
    
    private func addConstraints() {
        containerView.constrainToCenter()
        
        containerView.constrain([
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.8),
        ])
        
        titleView.constrain([
            titleView.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            titleView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
        ])
        
        let padding: CGFloat = 8.0
        
        stackView.constrain([
            stackView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: padding),
            stackView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: padding),
            stackView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -padding),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
        ])
        titleLabel.constrain(toSuperviewEdges: UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding))
    }
    
    private func setStyle() {
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.white
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        titleView.backgroundColor = UIColor.da.darkSkyBlue
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.text = headerTitle
        titleLabel.font = UIFont.da.customBold(size: 18)
        titleLabel.lineBreakMode = .byWordWrapping
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DGBModalWindow: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DGBModalAnimationController(false)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DGBModalAnimationController(true)
    }
}

class DGBModalAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    
    init(_ presenting: Bool) {
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.15
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let vc = transitionContext.viewController(forKey: presenting ? .to : .from)!
        let containerView = transitionContext.containerView
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        vc.view.alpha = presenting ? 0.0 : 1.0
        vc.view.transform = presenting ? CGAffineTransform(scaleX: 0.9, y: 0.9) : CGAffineTransform.identity
        
        containerView.addSubview(vc.view)
        
        UIView.animate(withDuration: animationDuration, animations: {
            vc.view.alpha = self.presenting ? 1.0 : 0.0
            vc.view.transform = self.presenting ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}

typealias DGBCallback = (() -> Void)

class DGBModalLoadingView: DGBModalWindow {
    let ai: UIActivityIndicatorView
    
    override init(title: String) {
        ai = UIActivityIndicatorView(style: .gray)
        super.init(title: title)
        
        ai.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stackView.addArrangedSubview(ai)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ai.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ai.stopAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DGBConfirmAlert: DGBModalWindow {
    let message: String
    let image: UIImage?
    let okTitle: String
    let cancelTitle: String
    
    var confirmCallback: ((DGBCallback) -> Void)? = nil
    var cancelCallback: ((DGBCallback) -> Void)? = nil
    
    private let contentLabel = UILabel()
    
    private let buttonsView = UIStackView()
    
    private var imageContainer = UIView()
    private var imageView: UIImageView!
    private var okButton: ConfirmButton!
    private var cancelButton: ConfirmButton!
    
    init(title: String, message: String, image: UIImage?, okTitle: String = S.Alerts.defaultConfirmOkCaption, cancelTitle: String = S.Alerts.defaultConfirmCancelCaption) {
        
        self.message = message
        self.image = image
        self.okTitle = okTitle
        self.cancelTitle = cancelTitle
        
        super.init(title: title)
        
        imageView = UIImageView(image: image)
        
        okButton = ConfirmButton()
        cancelButton = ConfirmButton()
        
        addSubviews()
        addConstraints()
        setStyle()
        addEvents()
    }
    
    private func addSubviews() {
        // add buttons
        buttonsView.addArrangedSubview(okButton)
        buttonsView.addArrangedSubview(cancelButton)
        
        // add vertical views
        if image != nil {
            imageContainer.addSubview(imageView)
            stackView.addArrangedSubview(imageContainer)
        }
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(buttonsView)
    }
    
    private func addConstraints() {
        imageView.constrain([
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 0),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 180),
            imageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
        ])
        
        okButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor, multiplier: 1.0).isActive = true
        okButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor, multiplier: 1.0).isActive = true
        okButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    private func setStyle() {
        stackView.spacing = 16
        
        imageView.contentMode = .scaleAspectFit
        
        buttonsView.axis = .horizontal
        buttonsView.alignment = .fill
        buttonsView.distribution = .fill
        buttonsView.spacing = 8
        
        contentLabel.textAlignment = .left
        contentLabel.numberOfLines = 0
        contentLabel.text = message
        contentLabel.font = UIFont.da.customBody(size: 16)
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.textColor = UIColor.black
        
        okButton.setTitle(okTitle, for: .normal)
        cancelButton.setTitle(cancelTitle, for: .normal)
        okButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        okButton.titleLabel?.font = UIFont.da.customBody(size: 16)
        cancelButton.titleLabel?.font = UIFont.da.customBody(size: 16)
        
        okButton.backgroundColor = UIColor.da.darkSkyBlue
        okButton.layer.cornerRadius = 8
        okButton.layer.masksToBounds = true
        
        cancelButton.backgroundColor = UIColor(red: 228/255, green: 229/255, blue: 228/255, alpha: 1.0) // grey
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.masksToBounds = true
    }
    
    private func addEvents() {
        okButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    private lazy var closeCallback: DGBCallback = { () in
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func confirmTapped() {
        // User is responsible to call the close callback.
        confirmCallback?(closeCallback)
    }
    
    @objc
    private func cancelTapped() {
        cancelCallback?(closeCallback)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
