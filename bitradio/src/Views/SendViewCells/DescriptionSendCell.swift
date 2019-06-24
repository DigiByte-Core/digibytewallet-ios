//
//  DescriptionSendCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-12-16.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

class DescriptionSendCell : SendCell {

    init(placeholder: String) {
        super.init()
        textView.delegate = self
        textView.textColor = C.Colors.text
        textView.font = .customBody(size: 20.0)
        textView.returnKeyType = .done
        textView.keyboardAppearance = .dark
        self.placeholder.textColor = C.Colors.blueGrey
        self.placeholder.text = placeholder
        backgroundColor = .clear
        setupViews()
    }

    var didBeginEditing: (() -> Void)?
    var didReturn: ((UITextView) -> Void)?
    var didChange: ((String) -> Void)?
    var content: String? {
        didSet {
            textView.text = content
            textViewDidChange(textView)
        }
    }

    let textView = UITextView()
    fileprivate let placeholder = UILabel(font: .customBody(size: 16.0), color: C.Colors.lightText)
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

extension DescriptionSendCell : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditing?()
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = textView.text.utf8.count > 0
        if let text = textView.text {
            didChange?(text)
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            textView.resignFirstResponder()
            return false
        }

        let count = (textView.text ?? "").utf8.count + text.utf8.count
        return count <= C.maxMemoLength
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        didReturn?(textView)
    }
}
