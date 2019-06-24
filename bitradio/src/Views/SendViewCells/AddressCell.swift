//
//  AddressCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-12-16.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

class ToCell: SendCell {
    
    init(placeholder: String) {
        super.init()
        textView.textColor = C.Colors.text
        textView.font = .customBody(size: 16.0)
        textView.returnKeyType = .done
        textView.keyboardAppearance = .dark
        self.placeholder.textColor = C.Colors.blueGrey
        self.placeholder.text = placeholder
        backgroundColor = .clear
        setupViews()
    }
    
    var text: String? {
        didSet {
            textView.text = text
        }
    }
    
    let textView = UITextView()
    let placeholder = UILabel(font: .customBody(size: 16.0), color: C.Colors.lightText)
    private func setupViews() {
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        addSubview(textView)
        textView.constrain([
            textView.constraint(.leading, toView: self, constant: 11.0),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: C.padding[2]),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30.0),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]) ])
        
        textView.addSubview(placeholder)
        placeholder.constrain([
            placeholder.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            placeholder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5.0) ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AddressCell: UIView {

    init(showAddressBookButton: Bool = false, addressBookCallback: (() -> Void)? = nil) {
        self.showAddressBookButton = showAddressBookButton
        self.didTapAddressBook = addressBookCallback
        super.init(frame: .zero)
        setupViews()
    }

    var address: String {
        return textField.textView.text
    }

    var didTapAddressBook: (() -> Void)?
    var didEdit: (() -> Void)?
    var didBeginEditing: (() -> Void)?
    var didReceivePaymentRequest: ((PaymentRequest) -> Void)?

    func setContent(_ content: String?) {
        contentLabel.text = content
        textField.text = content
        textViewDidChange(textField.textView)
    }

    var isEditable = false {
        didSet {
            gr.isEnabled = isEditable
        }
    }

    let showAddressBookButton: Bool
    let textField = ToCell(placeholder: S.Send.toLabel)
    let addressBookButton = UIButton()
    let paste = ShadowButton(title: S.Send.pasteLabel, type: .primary)
    let scan = ShadowButton(title: S.Send.scanLabel, type: .primary)
	let qrImage = ShadowButton(title: S.QRImageReader.buttonLabel, type: .primary)
    
    let toLabel = UILabel(font: .customBody(size: 16.0))
    let underLineView = UIView()

    fileprivate let contentLabel = UILabel(font: .customBody(size: 14.0), color: C.Colors.text)
    fileprivate let gr = UITapGestureRecognizer()
    fileprivate let tapView = UIView()
	
    private let border = UIView(color: .clear)
    private var pasteWidthAnchor: NSLayoutConstraint?
    private var scanWidthAnchor: NSLayoutConstraint?
    
    func hideButtons() {
        pasteWidthAnchor?.isActive = true
        scanWidthAnchor?.isActive = true
        self.setNeedsLayout()
    }
    
    func showButtons() {
        pasteWidthAnchor?.isActive = false
        scanWidthAnchor?.isActive = false
        self.setNeedsLayout()
    }
    
    private func setupViews() {
        addSubviews()
        addConstraints()
        setInitialData()
        setStyle()
    }

	override func didMoveToSuperview() {
        paste.widthAnchor.constraint(equalTo: scan.widthAnchor).isActive = true
        scan.widthAnchor.constraint(equalTo: qrImage.widthAnchor).isActive = true
        qrImage.widthAnchor.constraint(equalTo: paste.widthAnchor).isActive = true
	}

    private func addSubviews() {
        addSubview(textField)
        addSubview(addressBookButton)
        addSubview(paste)
        addSubview(scan)
		addSubview(qrImage)
    }

    private func addConstraints() {
        textField.constrain([
            textField.heightAnchor.constraint(equalToConstant: ToCell.defaultHeight),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leftAnchor.constraint(equalTo: leftAnchor),
        ])
        
        if showAddressBookButton {
            addressBookButton.constrain([
                addressBookButton.topAnchor.constraint(equalTo: textField.topAnchor, constant: 24),
                addressBookButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
                addressBookButton.widthAnchor.constraint(equalToConstant: 24),
                addressBookButton.heightAnchor.constraint(equalToConstant: 24),
            ])
            
            textField.constrain([
                textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -50)
            ])
        } else {
            textField.constrain([
                textField.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        }

		paste.constrain([
			paste.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[0]),
			paste.trailingAnchor.constraint(equalTo: scan.leadingAnchor, constant: -C.padding[1]),
            paste.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: C.padding[1]),
            paste.heightAnchor.constraint(equalToConstant: 35),
			paste.constraint(.bottom, toView: self, constant: -C.padding[1])])

        scan.constrain([
			scan.trailingAnchor.constraint(equalTo: qrImage.leadingAnchor, constant: -C.padding[1]),
            scan.centerYAnchor.constraint(equalTo: paste.centerYAnchor),
            scan.heightAnchor.constraint(equalToConstant: 35),
			scan.constraint(.bottom, toView: self, constant: -C.padding[1]) ])

		qrImage.constrain([
			qrImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[0]),
            qrImage.centerYAnchor.constraint(equalTo: paste.centerYAnchor),
            qrImage.heightAnchor.constraint(equalToConstant: 35),
			qrImage.constraint(.bottom, toView: self, constant: -C.padding[1]) ])
    }
    
    private func setStyle() {
        addressBookButton.setBackgroundImage(UIImage(named: "AddressBook"), for: .normal)
        addressBookButton.isHidden = !showAddressBookButton
    }

    private func setInitialData() {
        backgroundColor = .clear
        toLabel.text = S.Send.toLabel
		toLabel.textColor = C.Colors.blueGrey
        
        textField.textView.delegate = self
        textField.textView.returnKeyType = .done

		underLineView.backgroundColor = C.Colors.blueGrey
        
        addressBookButton.addTarget(self, action: #selector(addressBookButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addressBookButtonTapped() {
        didTapAddressBook?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddressCell : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            textView.resignFirstResponder()
            return false
        }
        
        if let request = PaymentRequest(string: text) {
            didReceivePaymentRequest?(request)
            return false
        } else {
            return true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.textField.placeholder.isHidden = textView.text != ""
        didEdit?()
    }
}
