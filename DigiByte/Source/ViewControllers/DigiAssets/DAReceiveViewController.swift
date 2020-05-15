//
//  DAReceiveViewController.swift
//  digibyte
//
//  Created by Yoshi Jaeger on 29.03.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

fileprivate let qrBorder: CGFloat = 200
fileprivate let qrBorderSize: CGFloat = 16
fileprivate let qrSize: CGFloat = qrBorder - qrBorderSize * 2

fileprivate func createVerticalSpacingView(_ height: CGFloat = 16) -> UIView {
    let v = UIView()
    
    v.heightAnchor.constraint(equalToConstant: height).isActive = true
    v.backgroundColor = .clear
    
    return v
}

fileprivate func pad(_ pad: CGFloat, _ view: UIView) -> UIView {
    let v = UIView()
    
    v.addSubview(view)
    
    v.heightAnchor.constraint(equalToConstant: qrBorder).isActive = true
    v.widthAnchor.constraint(equalToConstant: qrBorder).isActive = true
    
    view.constrain([
        view.centerXAnchor.constraint(equalTo: v.centerXAnchor),
        view.centerYAnchor.constraint(equalTo: v.centerYAnchor),
    ])
    
    return v
}

class DAReceiveViewController: UIViewController {
    private var hc: NSLayoutConstraint? = nil
    private let store: BRStore
    private let wallet: BRWallet
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let header = UILabel(font: UIFont.da.customBold(size: 20), color: .white)
    let assetDropdown = DADropDown()
    let totalBalanceLabel = UILabel(font: UIFont.da.customMedium(size: 13), color: UIColor.da.secondaryGrey)
    let receivingAddressBox = DATextBox(showPasteButton: true)
    
    let qrCodeContainer = UIView()
    let qrCode = UIImageView()
    
    var selectedModel: AssetModel? = nil {
        didSet {
            modelSelected()
        }
    }
    
    init(store: BRStore, wallet: BRWallet) {
        self.store = store
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(title: "Receive", image: UIImage(named: "da-receive")?.withRenderingMode(.alwaysTemplate), tag: 0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.alwaysBounceVertical = true
        
        stackView.spacing = 9
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        
        header.text = "Receive Assets"
        header.textAlignment = .left
        
        totalBalanceLabel.text = " "
        totalBalanceLabel.textAlignment = .left
    
        assetDropdown.setContent(asset: nil)
        
        let q = pad(qrBorderSize, qrCode)
        qrCodeContainer.addSubview(q)
        q.constrain([
            q.centerXAnchor.constraint(equalTo: qrCodeContainer.centerXAnchor),
            q.topAnchor.constraint(equalTo: qrCodeContainer.topAnchor),
            q.bottomAnchor.constraint(equalTo: qrCodeContainer.bottomAnchor),
        ])
        
        qrCode.constrain([
            qrCode.widthAnchor.constraint(equalToConstant: qrSize),
            qrCode.heightAnchor.constraint(equalToConstant: qrSize),
        ])
        q.layer.borderWidth = 16
        q.layer.borderColor = UIColor.white.cgColor
        q.layer.cornerRadius = 12
        q.layer.masksToBounds = true
        
        qrCode.image = UIImage.qrCode(data: "Select an asset".data(using: .ascii)!, color: CIColor(color: .black))?.resize(CGSize(width: qrSize, height: qrSize))
        
        
        if !UserDefaults.excludeLogoInQR {
            qrCode.image = placeLogoIntoQR(qrCode.image!, width: qrSize, height: qrSize, logo: UIImage(named: "da_filled"))
        }
        
        qrCodeContainer.alpha = 0.3
        qrCode.backgroundColor = UIColor.white
        qrCode.contentMode = .scaleAspectFit
        
        stackView.addArrangedSubview(header)
        stackView.addArrangedSubview(createVerticalSpacingView())
        
        stackView.addArrangedSubview(assetDropdown)
        stackView.addArrangedSubview(totalBalanceLabel)
        stackView.addArrangedSubview(createVerticalSpacingView())
        
        stackView.addArrangedSubview(qrCodeContainer)
        stackView.addArrangedSubview(createVerticalSpacingView())
        
        stackView.addArrangedSubview(receivingAddressBox)
        stackView.addArrangedSubview(createVerticalSpacingView())
        
        stackView.addArrangedSubview(UIView())
        
        receivingAddressBox.placeholder = "Receiving Address"
        receivingAddressBox.copyMode = true
        receivingAddressBox.textBox.isEnabled = false
        receivingAddressBox.textBox.text = wallet.receiveAddress
        
        addConstraints()
        addEvents()
        
        modelSelected()
    }
    
    @objc private func assetDropdownTapped() {
        let assetSelector = DAModalAssetSelector()
        assetSelector.callback = { [weak self] asset in
            self?.selectedModel = asset
        }
        self.present(assetSelector, animated: true, completion: {
            assetSelector.tableView.reloadData()
        })
    }
    
    private func modelSelected() {
        assetDropdown.setContent(asset: selectedModel)
        
        guard let assetModel = selectedModel else {
            return
        }
        
        // Update total balance
        let balance = AssetHelper.allBalances[assetModel.assetId] ?? 0
        totalBalanceLabel.text = "\(S.Assets.totalBalance): \(balance)"
        totalBalanceLabel.textColor = UIColor(red: 248 / 255, green: 156 / 255, blue: 78 / 255, alpha: 1.0) // 248 156 78
        
        let pr = "\(wallet.receiveAddress)"
        
        qrCode.image = UIImage.qrCode(data: pr.data(using: .ascii)!, color: CIColor(color: .black))?.resize(CGSize(width: qrSize, height: qrSize))
        qrCodeContainer.alpha = 1.0
        
        if !UserDefaults.excludeLogoInQR {
            qrCode.image = placeLogoIntoQR(qrCode.image!, width: qrSize, height: qrSize, logo: UIImage(named: "da_filled"))
        }
    }
    
    private func addEvents() {
        let gr = UITapGestureRecognizer(target: self, action: #selector(assetDropdownTapped))
        assetDropdown.isUserInteractionEnabled = true
        assetDropdown.addGestureRecognizer(gr)
    }
    
    private func addConstraints() {
        let padding: CGFloat = 30
        
        scrollView.constrain(toSuperviewEdges: nil)
        stackView.constrain(toSuperviewEdges: UIEdgeInsets(top: 90, left: padding, bottom: -50, right: -padding))
        
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0, constant: -2 * padding).isActive = true
        
        let hC = stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8)
        hC.priority = .defaultLow
        hC.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.tintColor = UIColor(red: 38 / 255, green: 152 / 255, blue: 237 / 255, alpha: 1.0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
