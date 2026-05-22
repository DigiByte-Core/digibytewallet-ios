//
//  NavigationDrawer.swift
//  DigiByte
//
//  Created by Yoshi Jaeger on 04.12.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

class NavigationDrawer: UIView {
    private let bgImage = UIImageView(image: UIImage(named: "hamburgerBg"))
    private var digibyteLogo = UIImageView(image: UIImage(named: "DigiByteSymbol"))
    private let walletLabel = UILabel(font: .customMedium(size: 18), color: C.Colors.text)
    private let walletVersionLabel = UILabel(font: .customMedium(size: 11), color: .gray)
    private var y: CGFloat = 0
    private var supervc: DrawerControllerProtocol? = nil
    private var scrollView = UIScrollView()
    private var scrollInner = UIStackView()
    
    private let buttonHeight: CGFloat = 78.0
    
    private let id: String
    
    private struct SideMenuButton {
        let view: UIView
        let callback: (() -> Void)
    }
    
    private var buttons: [SideMenuButton] = []
    
    init(id: String, walletTitle: String, version: String) {
        self.id = id
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
            digibyteLogo.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
        } else {
            digibyteLogo.transform = CGAffineTransform.init(scaleX: progress, y: progress)
        }
    }
    
    private func addSubviews() {
        bgImage.contentMode = .scaleAspectFill
        
        addSubview(bgImage)
        addSubview(digibyteLogo)
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
        
        digibyteLogo.constrain([
            digibyteLogo.topAnchor.constraint(equalTo: self.topAnchor, constant: 78),
            digibyteLogo.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),
            digibyteLogo.widthAnchor.constraint(equalToConstant: 90),
            digibyteLogo.heightAnchor.constraint(equalToConstant: 90),
        ])
        
        walletLabel.constrain([
            walletLabel.topAnchor.constraint(equalTo: digibyteLogo.bottomAnchor, constant: 16),
            walletLabel.centerXAnchor.constraint(equalTo: digibyteLogo.centerXAnchor),
            //walletLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            //walletLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
        
        walletVersionLabel.constrain([
            walletVersionLabel.topAnchor.constraint(equalTo: walletLabel.bottomAnchor, constant: 6),
            walletVersionLabel.centerXAnchor.constraint(equalTo: digibyteLogo.centerXAnchor),
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
        backgroundColor = .black
        
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
    
    func setCloser(supervc: DrawerControllerProtocol?) {
        self.supervc = supervc
    }
    
    @objc private func buttonTapped(button: UIButton) {
        for (_, btn) in buttons.enumerated() {
            if (btn.view == button) {
                self.supervc?.closeDrawer(with: id)
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
        
        let buttonContainer = DAHapticControl()
        buttonContainer.isUserInteractionEnabled = true
        buttonContainer.isAccessibilityElement = true
        buttonContainer.accessibilityIdentifier = "navigation-menu-\(NavigationDrawer.accessibilitySuffix(for: title))"
        buttonContainer.accessibilityLabel = title
        buttonContainer.accessibilityTraits = UIAccessibilityTraits.button
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

    private static func accessibilitySuffix(for title: String) -> String {
        return title.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }
}
