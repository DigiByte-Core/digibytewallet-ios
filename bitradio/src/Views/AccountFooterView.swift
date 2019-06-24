//
//  AccountFooterView.swift
//  breadwallet
//
//  Created by Yoshi Jaeger on 2018-05-23.
//  Copyright © 2018 Bitradio Foundation. All rights reserved.
//

import UIKit

fileprivate let buttonSize: CGFloat = CGFloat(E.scaleFactor * 40)
fileprivate let buttonBorderWidth: CGFloat = E.scaleFactor * 4.0

fileprivate class RadialGradientViewButton: UIView {
    var highlightOnTouch = false
    var isHighlighted: Bool = false
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            self.backgroundColor = UIColor(white: 1, alpha: 0.0)
            self.isHighlighted = false
            action?()
        } else {
            print("no action")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if highlightOnTouch {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
                self.backgroundColor = UIColor(white: 1, alpha: 0.0)
            }, completion: { (b) in
                self.isHighlighted = false
            })
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard !isHighlighted else { return }
        
        if highlightOnTouch {
            isHighlighted = true
            UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
                self.backgroundColor = UIColor(white: 1, alpha: 0.2)
            })
        }
    }
}

fileprivate struct RadialGradientViewButtonModel {
    let text: String
    let icon: UIImage
    let callback: () -> Void
    
    let view: UIView
    let targetOffset: CGFloat
}

fileprivate class RadialGradientCircleBackgroundView: UIView {
    private let startColor: UIColor
    private let endColor: UIColor
    
    init(startColor: UIColor, endColor: UIColor) {
        self.startColor = startColor
        self.endColor = endColor
        
        super.init(frame: CGRect())
        
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        currentContext.saveGState()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let startColorComponents = startColor.cgColor.components else { return }
        guard let endColorComponents = endColor.cgColor.components else { return }
        
        let colorComponents: [CGFloat] = [startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3], endColorComponents[0], endColorComponents[1], endColorComponents[2], endColorComponents[3]]
        
        let locations: [CGFloat] = [0.0, 1.0]
        guard let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colorComponents, locations: locations, count: 2) else { return }
        
        let startPoint = CGPoint(x: 0, y: self.bounds.height)
        let endPoint = CGPoint(x: self.bounds.width, y: self.bounds.height)
        
        currentContext.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: UInt32(0)))
        currentContext.restoreGState()
    }
}

fileprivate class RadialGradientMenu: UIView {
    private var hasSetup: Bool = false
    private var size: CGSize = CGSize(width: buttonSize, height: buttonSize) {
        didSet {
            guard let superview = superview else { return }
            superview.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        }
    }
    
    private let buttonText = UILabel(font: .customMedium(size: 24), color: C.Colors.text)
    private var currentOffset: CGFloat = 0
    private var currentProgress: CGFloat = 0
    private var buttonModels: [RadialGradientViewButtonModel] = []
    
    private let blurView = UIVisualEffectView()
    
    override func layoutSubviews() {
        guard !hasSetup else { return }
        addSubviews()
        addConstraints()
        configure()
        
        bringButtonsToFront()
        addPanGesture()
        
        hasSetup = true
    }
    
    private func addPanGesture() {
        let gesture = UIPanGestureRecognizer()
        gesture.maximumNumberOfTouches = 1
        gesture.addTarget(self, action: #selector(handlePan(_:)))
        buttonText.addGestureRecognizer(gesture)
        
        let gestureCircle = UIPanGestureRecognizer()
        gestureCircle.maximumNumberOfTouches = 1
        gestureCircle.addTarget(self, action: #selector(handlePanCircle(_:)))
        circleView.addGestureRecognizer(gestureCircle)
        
        circleView.isUserInteractionEnabled = false
    }
    
    @objc private func handlePanCircle(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            // started
            guard currentProgress == 1 && !animating else {
                // cancel
                sender.isEnabled = false
                sender.isEnabled = true
                return
            }
            
        } else if sender.state == .changed {
            // changed
            var translationY = -sender.translation(in: sender.view?.superview).y
            if translationY > 0 {
                // move up
                // translationY = translationY
            } else {
                // move down
                // translationY *= pow(2, -translationY / 5)
            }
            
            let progress = 1 + translationY / (currentOffset+20) * 1.5
            menuAnimationStep(progress)
        } else {
            // ended
            let translationY = -sender.translation(in: sender.view?.superview).y
            
            let progress = 1 + translationY / (currentOffset+20) * 1.5
            decideToOpenOrNot(progress)
        }
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            // started
            guard currentProgress == 0 && !animating else {
                // cancel
                sender.isEnabled = false
                sender.isEnabled = true
                return
            }
            
        } else if sender.state == .changed {
            // changed
            var translationY = -sender.translation(in: sender.view).y
            if translationY < 0 {
                translationY = 0
            }
            
            let progress = translationY / (currentOffset+20) * 1.5
            menuAnimationStep(progress)
        } else {
            // ended
            let translationY = -sender.translation(in: sender.view).y
            guard translationY > 0 else { return }
            
            let progress = translationY / (currentOffset+20) * 1.5
            decideToOpenOrNot(progress)
        }
    }
    
    private func decideToOpenOrNot(_ progress: CGFloat) {
        if progress > 0.5 {
            let _ = openMenu()
        } else {
            opened = true
            let _ = closeMenu()
        }
    }
    
    private func menuAnimationStep(_ progress: CGFloat) {
        var progress = (progress < 0 ? 0 : progress)
        if progress > 1 {
            progress = sqrt(sqrt(progress))
        }
        let screenWidth = UIScreen.main.bounds.width
        let widthScale = screenWidth / size.width * 1.1
        let heightScale = 2*(currentOffset + 40) / size.height
        var scale = max(widthScale, heightScale) * progress
        scale = (scale < 1 ? 1 : scale)
        
        var buttonAlpha = (progress - 0.3) * (1 / (1 - 0.3))
        buttonAlpha = buttonAlpha < 0 ? 0 : (buttonAlpha > 1 ? 1 : buttonAlpha)
        
        self.circleView.transform = CGAffineTransform(scaleX: scale, y: scale)
        self.buttonText.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4 * progress)
        for i in 0..<self.buttonModels.count {
            let element = self.buttonModels[i]
            let view = element.view
            view.frame.origin.y = -element.targetOffset * progress
            view.alpha = buttonAlpha
        }
        
        blurView.alpha = 1 * progress
    }
    
    private func centerButtonImageAndTitle(button: UIButton) {
        let spacing: CGFloat = 5
        let titleSize = button.titleLabel!.frame.size
        let imageSize = button.imageView!.frame.size
        
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: -imageSize.width/2, bottom: 0, right: -titleSize.width)
    }
    
    private func addSubviews() {
        addSubview(blurView)
        addSubview(circleView)
        addSubview(buttonText)
    }
    
    let circleView: RadialGradientCircleBackgroundView
    var opened: Bool = false
    
    private var animating: Bool = false
    @objc func tapped() {
        if (opened) {
            let _ = closeMenu()
        } else {
            let _ = openMenu()
        }
    }
    
    private func closeMenu(_ callback: (() -> Void)? = nil) -> Bool {
        guard !animating else { return false }
        // guard opened else { return false }
        animating = true
        
        UIView.spring(0.3, animations: {
            self.menuAnimationStep(0.0)
        }) { (finished) in
            self.animating = false
            self.opened = false
            self.currentProgress = 0
            self.circleView.isUserInteractionEnabled = false
            callback?()
        }
        
        return true
    }
    
    private func openMenu(_ callback: (() -> Void)? = nil) -> Bool {
        guard !animating else { return false }
        // guard !opened else { return false }
        animating = true
        
        UIView.spring(0.3, animations: {
            self.menuAnimationStep(1.0)
        }) { (finished) in
            self.animating = false
            self.opened = true
            self.currentProgress = 1
            self.circleView.isUserInteractionEnabled = true
            callback?()
        }
        
        return true
    }
    
    private func addConstraints() {
        buttonText.constrain([
            buttonText.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonText.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1),
            buttonText.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1),
            buttonText.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
        
        circleView.constrain([
            circleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circleView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1),
            circleView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1),
            circleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
        
        if let v = window?.rootViewController?.view {
            blurView.constrain([
                blurView.topAnchor.constraint(equalTo: v.topAnchor),
                blurView.leftAnchor.constraint(equalTo: v.leftAnchor),
                blurView.bottomAnchor.constraint(equalTo: v.bottomAnchor),
                blurView.rightAnchor.constraint(equalTo: v.rightAnchor),
            ])
        } else {
            blurView.frame = CGRect.zero
        }
    }
    
    private func bringButtonsToFront() {
        for i in 0..<buttonModels.count {
            bringSubview(toFront: buttonModels[i].view)
            // centerButtonImageAndTitle(button: buttonModels[i].view)
        }
        bringSubview(toFront: buttonText)
    }
    
    @objc private func blurViewTap() {
        let _ = closeMenu()
    }
    
    private func configure() {
        // blur view
        blurView.effect = UIBlurEffect(style: .dark)
        blurView.alpha = 0.0
        blurView.isUserInteractionEnabled = true
        let gr = UITapGestureRecognizer()
        gr.addTarget(self, action: #selector(blurViewTap))
        blurView.addGestureRecognizer(gr)
        
        // circleView
        circleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        circleView.backgroundColor = UIColor(red: 0x02 / 255, green: 0x52 / 255, blue: 0xAA / 255, alpha: 1)
        circleView.layer.cornerRadius = size.width / 2
        circleView.frame = CGRect(origin: CGPoint(), size: size)
        circleView.setNeedsLayout()
        
        circleView.contentMode = UIViewContentMode.redraw
        
        buttonText.text = "+"
        buttonText.textColor = .white
        buttonText.textAlignment = .center
        
        // add tap action
        buttonText.isUserInteractionEnabled = true
        let t = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        t.numberOfTapsRequired = 1
        t.numberOfTouchesRequired = 1
        buttonText.addGestureRecognizer(t)
    }
    
    init(startColor: UIColor, endColor: UIColor) {
        circleView = RadialGradientCircleBackgroundView(startColor: startColor, endColor: endColor)
        super.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
    }
    
    func setRadius(_ r: CGFloat) {
        size = CGSize(width: r, height: r)
        circleView.layer.cornerRadius = r / 2
    }
    
    func addMenuItem(img: UIImage, text: String, onTap: @escaping () -> Void) {
        let view = RadialGradientViewButton()
        let image = UIImageView(image: img)
        //image.tintColor = C.Colors.text
        image.contentMode = .scaleAspectFit
        let label = UILabel(font: .customBody(size: 14))
        label.text = text
        label.textAlignment = .center
        label.textColor = C.Colors.text
        view.addSubview(image)
        view.addSubview(label)
        addSubview(view)
        
        image.constrain([
            image.widthAnchor.constraint(equalToConstant: 23),
            image.heightAnchor.constraint(equalToConstant: 23),
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
        ])
        
        label.constrain([
            label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        view.constrain([
            view.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            view.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            view.widthAnchor.constraint(equalToConstant: 70),
            view.heightAnchor.constraint(equalToConstant: 70),
        ])
        
        view.layer.cornerRadius = 35
        view.alpha = 0
        currentOffset += 70
        
        let model = RadialGradientViewButtonModel(
            text: text,
            icon: img,
            callback: onTap,
            view: view,
            targetOffset: currentOffset
        )
        buttonModels.append(model)
        
        view.highlightOnTouch = true
        view.addTapGestureRecognizer {
            let _ = self.closeMenu() {
                onTap()
            }
        }
        
        currentOffset += 20
        
        bringSubview(toFront: buttonText)
        // centerButtonImageAndTitle(button: view)
    }
    
    // let outside elements accept taps
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (!self.clipsToBounds && !self.isHidden && self.alpha > 0) {
            for subview in self.subviews.reversed() {
                if subview == circleView {
                    if opened {
                        // ToDo: use real circle size to determine hitTest,
                        // that is, determining scale factor, calculate circle frame, make a hittest.
                        // If that is fixed, blurView tap can be handled
                        let subPoint = circleView.layer.convert(point, from: self.layer)
                        let view = circleView.layer.hitTest(subPoint)
                        guard view == nil else { return circleView }
                    }
                } else if (subview == blurView) {
                    if opened {
                        return blurView
                    }
                } else {
                    let subPoint = subview.convert(point, from: self)
                    let view = subview.hitTest(subPoint, with: event)
                    guard view == nil else { return view }
                }
            }
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// This view just checks whether an user event was hitting the RadialGradientMenu
fileprivate class FooterBackgroundView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 0x0F / 255, green: 0x0F / 255, blue: 0x1A / 255, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view == nil else { return view }
        
        if (!self.clipsToBounds && !self.isHidden && self.alpha > 0) {
            for subview in self.subviews.reversed() {
                let subPoint = subview.convert(point, from: self)
                
                // check whether we are checking circle button
                if let subview = subview as? CircleButtonContainer {
                    // if the menu is opened, we should accept events
                    let circleButton = subview.circleButton
                    if circleButton.opened {
                        let pt = circleButton.convert(point, from: self)
                        let view = circleButton.hitTest(pt, with: event)
                        guard view == nil else { return view }
                        return circleButton
                    } else {
                        let view = subview.hitTest(subPoint, with: event)
                        guard view == nil else { return view }
                    }
                    // or any other view
                } else {
                    let view = subview.hitTest(subPoint, with: event)
                    guard view == nil else { return view }
                }
            }
        }
        return nil
    }
}

fileprivate class CircleButtonContainer: UIView {
    fileprivate let circleButton: RadialGradientMenu
    init(circleButton: RadialGradientMenu) {
        self.circleButton = circleButton
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AccountFooterView: UIView {
    
    var sendCallback: (() -> Void)?
    var receiveCallback: (() -> Void)?
    var menuCallback: (() -> Void)?
    var addressBookCallback: (() -> Void)?
//    var showAddressCallback: (() -> Void)?
    var qrScanCallback: (() -> Void)?
    var debugDigiAssetsCallback: (() -> Void)?
    
    let height: CGFloat = 73
    let menuHeightOffset = CGFloat(E.isIPhoneX ? 15 : 0)
    
    private let circleButton: RadialGradientMenu
    private let startColor = UIColor(red: 0x02 / 255, green: 0x5C / 255, blue: 0xBA / 255, alpha: 1)
    private let endColor = UIColor(red: 0x01 / 255, green: 0x36 / 255, blue: 0x74 / 255, alpha: 1)
    
    init() {
        circleButton = RadialGradientMenu(startColor: startColor, endColor: endColor)
        super.init(frame: .zero)
    }
    
    var hasSetup = false
    
    override func layoutSubviews() {
        guard !hasSetup else { return }
        setupSubViews()
        hasSetup = true
    }
    
    @objc private func circleButtonLongPress(sender: UITapGestureRecognizer) {
        if sender.state == .began {
            debugDigiAssetsCallback?()
        }
    }
    
    func setupSubViews(){
        let backgroundView = FooterBackgroundView()
        
        // add menu items
        circleButton.addMenuItem(img: UIImage(named: "AddressBook")!, text: S.AddressBook.title) {
            self.addressBookCallback?()
        }
        circleButton.addMenuItem(img: #imageLiteral(resourceName: "receiveArrow"), text: S.Receive.title) {
            self.receiveCallback?()
        }
        circleButton.addMenuItem(img: #imageLiteral(resourceName: "sendArrow"), text: S.Send.title) {
            self.sendCallback?()
        }
        
        // left button (trigger hamburger menu)
        let hamburgerButton = UIButton(type: .system)
        hamburgerButton.setImage(#imageLiteral(resourceName: "hamburgerButton").withRenderingMode(.alwaysTemplate), for: .normal)
        hamburgerButton.tintColor = .white
        hamburgerButton.contentMode = .center
        
        // right button (qr code scanner)
        let qrButton = UIButton(type: .system)
        qrButton.setImage( #imageLiteral(resourceName: "qrButtonImage").withRenderingMode(.alwaysTemplate), for: .normal)
        qrButton.tintColor = .white
        qrButton.contentMode = .center
        
        // black border around circleButton
        let circleButtonContainer = CircleButtonContainer(circleButton: circleButton)
        circleButtonContainer.addSubview(circleButton)
        circleButtonContainer.isUserInteractionEnabled = true
        circleButtonContainer.backgroundColor = UIColor(red: 0x0F / 255, green: 0x0F / 255, blue: 0x1A / 255, alpha: 1)
        circleButtonContainer.layer.cornerRadius = (buttonSize + buttonBorderWidth * 2) / 2
        
        // REMOVE
        // This is for DigiAssets
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(circleButtonLongPress(sender:)))
        longPress.minimumPressDuration = 5
        circleButtonContainer.addGestureRecognizer(longPress)
        
        // add all to view
        backgroundView.addSubview(hamburgerButton)
        backgroundView.addSubview(qrButton)
        backgroundView.addSubview(blurView)
        backgroundView.addSubview(circleButtonContainer)
        
        circleButton.constrain([
            circleButton.centerYAnchor.constraint(equalTo: circleButtonContainer.centerYAnchor),
            circleButton.centerXAnchor.constraint(equalTo: circleButtonContainer.centerXAnchor),
            circleButton.widthAnchor.constraint(equalToConstant: buttonSize),
            circleButton.heightAnchor.constraint(equalToConstant: buttonSize),
        ])
        
        circleButtonContainer.constrain([
            circleButtonContainer.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: -15),
            circleButtonContainer.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor, constant: -2.5),
            circleButtonContainer.widthAnchor.constraint(equalToConstant: buttonSize + buttonBorderWidth * 2),
            circleButtonContainer.heightAnchor.constraint(equalToConstant: buttonSize + buttonBorderWidth * 2),
        ])
        
        hamburgerButton.constrain([
            hamburgerButton.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 15),
            hamburgerButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20),
            hamburgerButton.widthAnchor.constraint(equalToConstant: 55),
            hamburgerButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        qrButton.constrain([
            qrButton.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -20),
            //qrButton.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 20),
            qrButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 15),
            qrButton.widthAnchor.constraint(equalToConstant: 40),
            qrButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        qrButton.tap = qrscan
        
        addSubview(backgroundView)
        
        backgroundView.constrain([
            backgroundView.heightAnchor.constraint(equalToConstant: height + menuHeightOffset),
            backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        // events
        hamburgerButton.tap = menuCallback
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (!self.clipsToBounds && !self.isHidden && self.alpha > 0) {
            for subview in self.subviews.reversed() {
                let subPoint = subview.convert(point, from: self)
                
                // check whether we are checking our custom FooterBackgroundView class
                if let subview = subview as? FooterBackgroundView {
                    let pt = subview.convert(point, from: self)
                    let view = subview.hitTest(pt, with: event)
                    guard view == nil else { return view }
                } else {
                    let view = subview.hitTest(subPoint, with: event)
                    guard view == nil else { return view }
                }
            }
        }
        return nil
    }
    
    @objc private func send() { sendCallback?() }
    @objc private func receive() { receiveCallback?() }
    @objc private func menu() { menuCallback?() }
    @objc private func qrscan() { qrScanCallback?() }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}
