//
//  ModalHeaderView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-12-01.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

enum ModalHeaderViewStyle {
    case light
    case dark
}

class ModalHeaderView : UIView {

    //MARK - Public
    var closeCallback: (() -> Void)? {
        didSet { close.tap = closeCallback }
    }

    init(title: String, style: ModalHeaderViewStyle, faqInfo: (Store, String)? = nil) {
        self.title.text = title.uppercased()
        self.style = style

        if let faqInfo = faqInfo {
            self.faq = UIButton.buildFaqButton(store: faqInfo.0, articleId: faqInfo.1)
        }

        super.init(frame: .zero)
        setupSubviews()
        addFaqButton()
    }

    var faqInfo: (Store, String)? {
        didSet {
            if oldValue == nil {
                guard let faqInfo = faqInfo else { return }
                faq = UIButton.buildFaqButton(store: faqInfo.0, articleId: faqInfo.1)
                addFaqButton()
            }
        }
    }

    //MARK - Private
    private let title = UILabel(font: .customBody(size: 17.0), color: C.Colors.text)
    private let close = UIButton.close
    private var faq: UIButton? = nil
    private let border = UIView()
    private let buttonSize: CGFloat = 44.0
    private let style: ModalHeaderViewStyle

    private func setupSubviews() {
        addSubview(title)
        addSubview(close)
        close.constrain([
            close.constraint(.leading, toView: self, constant: 0.0),
            close.constraint(.centerY, toView: self, constant: 0.0),
            close.constraint(.height, constant: buttonSize),
            close.constraint(.width, constant: buttonSize) ])
        title.constrain([
            title.constraint(.centerX, toView: self, constant: 0.0),
            title.constraint(.centerY, toView: self, constant: 0.0) ])
        
        backgroundColor = .clear

        setColors()
    }

    private func addFaqButton() {
        guard let faq = faq else { return }
        addSubview(faq)
        faq.constrain([
            faq.constraint(.trailing, toView: self, constant: 0.0),
            faq.constraint(.centerY, toView: self, constant: 0.0),
            faq.constraint(.height, constant: buttonSize),
            faq.constraint(.width, constant: buttonSize) ])
        faq.isHidden = true // TODO: Writeup support/FAQ documentation for bitradio wallet
    }

    private func setColors() {
        title.textColor = C.Colors.text
        close.tintColor = C.Colors.text
        faq?.tintColor = C.Colors.text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
