//
//  DAAssetsViewController.swift
//  digibyte
//
//  Created by Yoshi Jaeger on 29.03.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

fileprivate class MainAssetHeader: UIView {
    let header = UILabel(font: UIFont.da.customBold(size: 20), color: .white)
    let searchBar = UITextField()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(header)
        addSubview(searchBar)
        
        header.constrain([
            header.leftAnchor.constraint(equalTo: leftAnchor),
            header.rightAnchor.constraint(equalTo: rightAnchor),
            header.topAnchor.constraint(equalTo: topAnchor),
            header.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        header.text = "Assets you own"
        searchBar.leftView = UIImageView(image: UIImage(named: "da-glyph-search"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PaddedCell: UITableViewCell {
    private var percentage: CGFloat = {
        // ToDo: optimize for iPhone SE and others
        return 0.9
    }()
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (n) {
            var frame = n
            let newWidth = frame.width * percentage
            let space = (frame.width - newWidth) / 2
            frame.size.width = newWidth
            frame.origin.x += space
            
            super.frame = frame
        }
    }
}

class AssetClipboardButton: UIButton {
    var key: String = "" {
        didSet {
            updateText()
        }
    }
    
    var value: String = "" {
        didSet {
            updateText()
        }
    }
    
    func updateText() {
        setTitle("\(key): \(value)", for: .normal)
        setTitleColor(.white, for: .normal)
    }
    
    @objc
    private func touch() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = value
    }
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
        super.init(frame: .zero)
        
        addTarget(self, action: #selector(touch), for: .touchUpInside)
        
        titleLabel?.font = UIFont.da.customMedium(size: 13)
        titleLabel?.lineBreakMode = .byTruncatingTail
        titleLabel?.textAlignment = .left
        contentHorizontalAlignment = .left
        
        contentEdgeInsets = UIEdgeInsets(top: 0.01, left: 0.01, bottom: 0.01, right: 0.01)
        
        updateText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AssetCell: PaddedCell {
    static let defaultImage = UIImage(named: "digiassets")
    
    let backgroundRect = UIView()
    
    let stackView = UIStackView()
    let headerView = UIView()
    let bottomView = UIView()
    
    let bottomViewInner = UIStackView()
    
    let menuButton = UIButton()
    let assetImage = UIImageView()
    let assetLabel = UILabel(font: UIFont.da.customBold(size: 14), color: .white)
    let amountLabel = UILabel(font: UIFont.da.customBold(size: 14), color: .white)
    let descriptionLabel = UILabel(font: UIFont.da.customMedium(size: 13), color: C.Colors.blueGrey)
    let issuerButton = AssetClipboardButton(key: S.Assets.issuer, value: S.Assets.unknown)
    let assetIdButton = AssetClipboardButton(key: S.Assets.assetID, value: S.Assets.unknown)
    let addressButton = AssetClipboardButton(key: S.Assets.address, value: S.Assets.unknown)
    let infoTextLabel = MarqueeLabel(font: UIFont.da.customMedium(size: 13), color: .white) // UILabel(font: UIFont.da.customMedium(size: 13), color: .white)
    
    var menuButtonTapped: ((AssetCell) -> Void)? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(backgroundRect)
        headerView.addSubview(menuButton)
        headerView.addSubview(assetImage)
        headerView.addSubview(assetLabel)
        headerView.addSubview(amountLabel)
        contentView.addSubview(stackView)
        
        bottomView.addSubview(bottomViewInner)
        bottomViewInner.constrain(toSuperviewEdges: UIEdgeInsets(top: 0, left: 16, bottom: -16, right: -16))
        bottomViewInner.alignment = .fill
        bottomViewInner.axis = .vertical
        bottomViewInner.distribution = .fill
        bottomViewInner.spacing = 4
        
        bottomViewInner.addArrangedSubview(descriptionLabel)
        bottomViewInner.addArrangedSubview(issuerButton)
        bottomViewInner.addArrangedSubview(assetIdButton)
        bottomViewInner.addArrangedSubview(addressButton)
        bottomViewInner.addArrangedSubview(infoTextLabel)
        
        infoTextLabel.type = .leftRight
        
        stackView.constrain(toSuperviewEdges: UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0))
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        
        let h1 = headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        let h2 = headerView.heightAnchor.constraint(lessThanOrEqualToConstant: 150)
        
        h1.isActive = true
        h2.isActive = true
        
        headerView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        
        // use the bottom 8/80 points to create margin
        backgroundRect.constrain(toSuperviewEdges: UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0))
        
        backgroundRect.layer.cornerRadius = 4
        backgroundRect.layer.masksToBounds = true
        backgroundRect.backgroundColor = UIColor.da.assetBackground
        backgroundColor = .clear
        selectionStyle = .none
        
        assetImage.constrain([
            assetImage.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            assetImage.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            assetImage.widthAnchor.constraint(equalToConstant: 40),
            assetImage.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        assetLabel.constrain([
            assetLabel.leadingAnchor.constraint(equalTo: assetImage.trailingAnchor, constant: 8),
            assetLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            assetLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10),
        ])
        
        assetLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        assetLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        
        amountLabel.constrain([
            amountLabel.centerYAnchor.constraint(equalTo: assetImage.centerYAnchor),
            amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            amountLabel.leadingAnchor.constraint(equalTo: assetLabel.trailingAnchor, constant: 8),
        ])
        
        menuButton.setImage(UIImage(named: "da-glyph-menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        menuButton.tintColor = UIColor.da.inactiveColor
        menuButton.constrain([
            menuButton.widthAnchor.constraint(equalToConstant: 30),
            menuButton.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 5),
            menuButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0),
            menuButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
        ])
        
        amountLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        amountLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        
        menuButton.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        
        amountLabel.text = S.Assets.unknown
        amountLabel.lineBreakMode = .byWordWrapping
        amountLabel.textAlignment = .right
        
        assetLabel.text = S.Assets.unknown
        assetLabel.numberOfLines = 0
        assetLabel.lineBreakMode = .byWordWrapping
        assetLabel.textAlignment = .left
        
        assetImage.image = AssetCell.defaultImage
        assetImage.contentMode = .scaleAspectFit
        assetImage.backgroundColor = .clear
    }

    @objc private func touchUp() {
        if #available(iOS 10.0, *) {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
        
        menuButtonTapped?(self)
    }
    
    func configure(showContent: Bool) {
        stackView.removeArrangedSubview(headerView)
        stackView.removeArrangedSubview(bottomView)
        headerView.removeFromSuperview()
        bottomView.removeFromSuperview()
        
        stackView.addArrangedSubview(headerView)
        
        if showContent {
            stackView.addArrangedSubview(bottomView)
        }
        
        assetLabel.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class CreateNewAssetCell: PaddedCell {
    
    let backgroundImage = UIImageView(image: UIImage(named: "da-new-asset-bg"))
    let headingLabel = UILabel(font: UIFont.da.customBold(size: 20), color: .white)
    let getStartedBtn = DAButton(title: "Get started".uppercased(), backgroundColor: UIColor.da.darkSkyBlue)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundView = backgroundImage
        backgroundColor = .clear
        selectionStyle = .none
        
        // add elements
        contentView.addSubview(headingLabel)
        contentView.addSubview(getStartedBtn)
        
        headingLabel.constrain([
            headingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            headingLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
        ])
        
        getStartedBtn.constrain([
            getStartedBtn.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            getStartedBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            getStartedBtn.widthAnchor.constraint(equalToConstant: 122)
        ])
        
        headingLabel.textAlignment = .right
        headingLabel.text = "Create a new asset"
        getStartedBtn.label.font = UIFont.da.customBold(size: 12)
        getStartedBtn.height = 34
        
        contentView.heightAnchor.constraint(equalToConstant: 128).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AssetContextMenuButton: UIControl {
    let label = UILabel(font: UIFont.customBold(size: 14), color: UIColor.white)
    let glyph = UIImageView()
    
    init(_ image: UIImage?, text: String, bgColor: UIColor = UIColor.da.contextMenuBackgroundColor) {
        super.init(frame: .zero)
        
        addSubview(label)
        addSubview(glyph)
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        glyph.constrain([
            glyph.centerXAnchor.constraint(equalTo: leadingAnchor, constant: 16 + 10),
            glyph.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            glyph.widthAnchor.constraint(equalToConstant: 20),
            glyph.heightAnchor.constraint(equalToConstant: 20),
        ])
        
        label.constrain([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: glyph.trailingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
        
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        glyph.image = image?.withRenderingMode(.alwaysTemplate)
        glyph.tintColor = UIColor.white
        
        backgroundColor = bgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AssetContextMenu: UIView {
    let roundedView = UIView()
    let stackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(roundedView)
        roundedView.addSubview(stackView)
        
        roundedView.layer.cornerRadius = 15
        roundedView.layer.masksToBounds = true
        
        // make the roundedview go out of visible frame
        roundedView.constrain(toSuperviewEdges: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        
        roundedView.addSubview(stackView)
        stackView.constrain(toSuperviewEdges: nil)
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        
        stackView.addArrangedSubview(AssetContextMenuButton(UIImage(named: "da-glyph-info"), text: "Transactions"))
        stackView.addArrangedSubview(AssetContextMenuButton(UIImage(named: "da-glyph-send"), text: "Send"))
//        stackView.addArrangedSubview(AssetContextMenuButton(UIImage(named: "da-glyph-receive"), text: "Receive"))
        stackView.addArrangedSubview(AssetContextMenuButton(UIImage(named: "da-glyph-burn"), text: "Burn", bgColor: UIColor.da.burnColor))
        
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DAAssetsViewController: UIViewController {
    // MARK: Private
    private let store: BRStore
    
    private var loadingAssetsModalView = DGBModalLoadingView(title: S.Assets.fetchingAssetsTitle)
    private var assetResolver: AssetResolver? = nil
    
    private let emptyImage: UIImageView = UIImageView()
    private let emptyContainer = UIView() // will be displayed when there is no asset in the wallet
    private let createNewAssetButton = DAButton(title: "Create new asset", backgroundColor: UIColor.da.darkSkyBlue)
    private let receiveAssetsButton = DAButton(title: "Receive assets", backgroundColor: UIColor.da.secondaryGrey)
    
    private let mainView = UIView()
    private let mainHeader = MainAssetHeader()
    private let tableView = UITableView(frame: .zero)
    private let contextMenu = AssetContextMenu()
    private let contextMenuUnderlay = UIView() // transparent view that closes contextmenu when tapped
    private var contextMenuConstraints = [NSLayoutConstraint]()
    private let tableViewBorder = UIView()
    
    private let emptyLabel = UILabel(font: UIFont.da.customBold(size: 22), color: .white)
    
    private var decelerate: Bool = false
    private var showTableViewBorder: Bool = false {
        willSet {
            if newValue != showTableViewBorder {
                if newValue {
                    UIView.animate(withDuration: 0.3) { [weak tableViewBorder] in
                        tableViewBorder?.alpha = 1.0
                    }
                } else {
                    UIView.animate(withDuration: 0.3, animations: { [weak tableViewBorder] in
                        tableViewBorder?.alpha = 0.0
                    }) { [weak self] _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            self?.decelerate = false
                        })
                    }
                }
            }
        }
    }
    
    init(store: BRStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(title: "Assets", image: UIImage(named: "da-assets")?.withRenderingMode(.alwaysTemplate), tag: 0)
        
        emptyImage.image = UIImage(named: "da-empty")
        
        addSubviews()
        setContent()
        addEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.tintColor = UIColor(red: 38 / 255, green: 152 / 255, blue: 237 / 255, alpha: 1.0)
        
        tableView.reloadData()
    }
    
    func showPrivacyConfirmView(for txs: [Transaction], _ callback: ((Bool) -> Void)? = nil) {
        let confirmView = DGBConfirmAlert(title: S.Assets.openAssetTitle, message: S.Assets.openAssetMessage, image: UIImage(named: "privacy"), okTitle: S.Assets.confirmAssetsResolve, cancelTitle: S.Assets.cancelAssetsResolve)
        
        let confirmCallback: () -> Void = {
            if self.assetResolver != nil { self.assetResolver!.cancel() }
            self.assetResolver = AssetHelper.resolveAssets(for: txs, callback: callback)
        }
        
        confirmView.confirmCallback = { (close: DGBCallback) in
            close()
            confirmCallback()
        }
        
        confirmView.cancelCallback = { (close: DGBCallback) in
            close()
        }
        
        guard !UserDefaults.Privacy.alwaysLoadAssets else {
            confirmCallback()
            return
        }
        
        self.present(confirmView, animated: true, completion: nil)
    }
    
    
    private func addSubviews() {
        emptyContainer.addSubview(emptyImage)
        emptyContainer.addSubview(emptyLabel)
        emptyContainer.addSubview(createNewAssetButton)
        emptyContainer.addSubview(receiveAssetsButton)
        view.addSubview(emptyContainer)
        
        /* empty view, that is shown when there are no assets created yet */
        emptyImage.constrain([
            emptyImage.widthAnchor.constraint(equalTo: emptyContainer.widthAnchor, multiplier: 1.0),
            emptyImage.centerXAnchor.constraint(equalTo: emptyContainer.centerXAnchor),
            emptyImage.topAnchor.constraint(equalTo: emptyContainer.topAnchor),
        ])
    
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = UIColor.gray
        
        emptyLabel.constrain([
            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 12),
            emptyLabel.leftAnchor.constraint(equalTo: emptyContainer.leftAnchor, constant: 0),
            emptyLabel.rightAnchor.constraint(equalTo: emptyContainer.rightAnchor, constant: 0),
        ])
        
        createNewAssetButton.constrain([
            createNewAssetButton.topAnchor.constraint(equalTo: emptyLabel.bottomAnchor, constant: 30),
            createNewAssetButton.leftAnchor.constraint(equalTo: emptyContainer.leftAnchor, constant: 0),
            createNewAssetButton.rightAnchor.constraint(equalTo: emptyContainer.rightAnchor, constant: 0),
        ])
        
        receiveAssetsButton.constrain([
            receiveAssetsButton.topAnchor.constraint(equalTo: createNewAssetButton.bottomAnchor, constant: 16),
            receiveAssetsButton.leftAnchor.constraint(equalTo: emptyContainer.leftAnchor, constant: 0),
            receiveAssetsButton.rightAnchor.constraint(equalTo: emptyContainer.rightAnchor, constant: 0),
            receiveAssetsButton.bottomAnchor.constraint(equalTo: emptyContainer.bottomAnchor, constant: 0),
        ])
        
        emptyContainer.constrain([
            emptyContainer.widthAnchor.constraint(equalToConstant: 198),
            emptyContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        /* main view, that is shown if at least one element is shown */
        view.addSubview(mainView)
        mainView.constrain(toSuperviewEdges: UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0))
        
        mainView.addSubview(mainHeader)
        mainHeader.constrain([
            mainHeader.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 58),
            mainHeader.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 32),
            mainHeader.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: 0),
            mainHeader.heightAnchor.constraint(equalToConstant: 32) /* YOSHI */
        ])
        
        mainView.addSubview(tableViewBorder)
        tableViewBorder.constrain([
            tableViewBorder.topAnchor.constraint(equalTo: mainHeader.bottomAnchor, constant: 18),
            tableViewBorder.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: -50),
            tableViewBorder.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: 50),
            tableViewBorder.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        mainView.addSubview(tableView)
        tableView.constrain([
            tableView.topAnchor.constraint(equalTo: tableViewBorder.bottomAnchor, constant: 0),
            tableView.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 0),
            tableView.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0),
        ])
        
        emptyContainer.isHidden = true /* YOSHI */
        mainView.bringSubviewToFront(tableViewBorder)
        
        mainView.addSubview(contextMenuUnderlay)
        contextMenuUnderlay.constrain(toSuperviewEdges: nil)
        contextMenuUnderlay.isHidden = true
        
        mainView.addSubview(contextMenu)
        contextMenu.isHidden = true
        contextMenu.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor = .clear
        tableView.register(AssetCell.self, forCellReuseIdentifier: "asset")
        tableView.register(CreateNewAssetCell.self, forCellReuseIdentifier: "get_started")
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    private func setContent() {
        emptyLabel.text = "Nothing found here"
        emptyLabel.text = ""
        
        createNewAssetButton.height = 46.0
        receiveAssetsButton.height = 46.0
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        
        tableViewBorder.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        tableViewBorder.alpha = 0.0
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(contextBgTapped))
        contextMenuUnderlay.isUserInteractionEnabled = true
        contextMenuUnderlay.addGestureRecognizer(gr)
    }
    
    private func addEvents() {
        // New assets stored on device
        AssetNotificationCenter.instance.addObserver(forName: AssetNotificationCenter.notifications.newAssetData, object: nil, queue: nil) { _ in
            
            self.tableView.reloadData()
        }
        
        // Fetching new assets
        AssetNotificationCenter.instance.addObserver(forName: AssetNotificationCenter.notifications.fetchingAssets, object: nil, queue: nil) { _ in
            self.present(self.loadingAssetsModalView, animated: true, completion: nil)
        }
        
        // Completed fetching new assets
        AssetNotificationCenter.instance.addObserver(forName: AssetNotificationCenter.notifications.fetchedAssets, object: nil, queue: nil) { _ in
            self.loadingAssetsModalView.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    private func contextBgTapped() {
        // hide context menu
        contextMenuUnderlay.isHidden = true
        contextMenu.isHidden = true
        
        // reset all button states
        tableView.visibleCells.forEach { (cell) in
            if let cell = cell as? AssetCell {
                cell.menuButton.tintColor = UIColor.da.inactiveColor
            }
        }
    }
    
    private func menuButtonTapped(cell: AssetCell) {
        if let idx = tableView.indexPath(for: cell) {
            let pos = tableView.rectForRow(at: idx)
            
            // get global position
            let gpos = tableView.convert(pos, to: view)
            
            // deactivate and remove each constraint
            contextMenuConstraints.forEach { c in
                c.isActive = false
                contextMenu.removeConstraint(c)
            }
            
            // set new constraints
            contextMenuConstraints = [
                contextMenu.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: gpos.origin.x + cell.menuButton.frame.origin.x + 10)
            ]
            
            if gpos.origin.y + contextMenu.frame.height > mainView.frame.height {
                // stick to bottom
                contextMenuConstraints.append(contextMenu.bottomAnchor.constraint(equalTo: view.topAnchor, constant: gpos.origin.y + gpos.height / 2))
            } else {
                // stick to top
                contextMenuConstraints.append(contextMenu.topAnchor.constraint(equalTo: view.topAnchor, constant: gpos.origin.y + gpos.height / 2))
            }
            
            // activate new constraints
            contextMenuConstraints.forEach { c in
                c.isActive = true
            }
            
            // initially scale
            contextMenu.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            // show context menu
            contextMenu.isHidden = false
            contextMenuUnderlay.isHidden = false
            mainView.bringSubviewToFront(contextMenuUnderlay)
            mainView.bringSubviewToFront(contextMenu)
            
            UIView.spring(0.3, animations: { [weak contextMenu, weak cell] in
                contextMenu?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                cell?.menuButton.tintColor = UIColor.da.darkSkyBlue
            }) { (_) in
                
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension DAAssetsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return AssetHelper.allAssets.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return get-started cell
        guard indexPath.section == 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "get_started") as! CreateNewAssetCell
            return cell
        }
        
        // return asset cell
        let assetId = AssetHelper.allAssets[indexPath.row]
        let assetModel = AssetHelper.getAssetModel(assetID: assetId) ?? AssetModel.dummy()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "asset") as! AssetCell
        cell.configure(showContent: false)
        cell.menuButtonTapped = menuButtonTapped
        cell.menuButton.tintColor = UIColor.da.inactiveColor
        
        cell.assetLabel.text = assetModel.getAssetName()
        
        let balance = AssetHelper.allBalances[assetId] ?? 0
        cell.amountLabel.text = "\(balance)"
        
        cell.assetImage.image = AssetCell.defaultImage
        cell.assetImage.kf.indicatorType = .activity
        
        if
            let urlModel = assetModel.getImage(),
            let urlStr = urlModel.url,
            let url = URL(string: urlStr)
        {
            cell.assetImage.kf.setImage(with: url)
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            showTableViewBorder = false
        } else {
//            if !decelerate {
                showTableViewBorder = true
//            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        decelerate = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.decelerate = true
//        showTableViewBorder = false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        
        let openDetailView: (AssetModel) -> Void = { assetModel in
            // ToDo: open detail view
            
        }
        
        // return asset cell
        let assetId = AssetHelper.allAssets[indexPath.row]
        if let assetModel = AssetHelper.getAssetModel(assetID: assetId) {
            openDetailView(assetModel)
        } else {
            var transactions = [Transaction]()
            
            store.state.walletState.transactions.forEach { tx in
                if let utxos = AssetHelper.getAssetUtxos(for: tx) {
                    var needsTx = false
                    
                    utxos.forEach { utxoModel in
                        guard utxoModel.assets.firstIndex(where: { $0.assetId == assetId }) != nil else { return }
                        needsTx = true
                    }
                    
                    if needsTx {
                        transactions.append(tx)
                    }
                }
            }
            
            showPrivacyConfirmView(for: transactions) { success in
                if success, let assetModel = AssetHelper.getAssetModel(assetID: assetId) {
                    // TableView will autoupdate (NotificationCenter)
                    openDetailView(assetModel)
                } else {
                    // Show error
                    print("Could not fetch dem assets")
                }
            }
        }
    }
}
