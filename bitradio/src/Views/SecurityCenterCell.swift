//
//  SecurityCenterCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-02-15.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

private let buttonSize: CGFloat = 16.0

class SecurityCenterCell : UIControl {

    //MARK: - Public
    var isCheckHighlighted: Bool = false {
        didSet {
            check.tintColor = isCheckHighlighted ? C.Colors.weirdGreen : .grayTextTint
        }
    }

    init(title: String, descriptionText: String) {
        super.init(frame: .zero)
        self.title.text = title
        descriptionLabel.text = descriptionText
        setup()
    }

    //MARK: - Private
    private func setup() {
        addSubview(title)
        addSubview(descriptionLabel)
        addSubview(separator)
        addSubview(check)
        check.constrain([
            check.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
            check.topAnchor.constraint(equalTo: topAnchor, constant: C.padding[2]),
            check.widthAnchor.constraint(equalToConstant: buttonSize),
            check.heightAnchor.constraint(equalToConstant: buttonSize) ])
        title.constrain([
            title.leadingAnchor.constraint(equalTo: check.trailingAnchor, constant: C.padding[1]),
            title.topAnchor.constraint(equalTo: check.topAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]) ])
        descriptionLabel.constrain([
            descriptionLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: title.bottomAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: title.trailingAnchor) ])
        separator.constrain([
            separator.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: C.padding[3]),
            separator.leadingAnchor.constraint(equalTo: check.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor) ])

        separator.backgroundColor = C.Colors.greyBlue
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        check.setImage(#imageLiteral(resourceName: "CircleCheck"), for: .normal)
        isCheckHighlighted = false
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = UIColor(white: 1, alpha: 0.2)
            } else {
                backgroundColor = .clear
            }
        }
    }

    private let title = UILabel(font: .customMedium(size: 13.0), color: C.Colors.text)
    private let descriptionLabel = UILabel(font: .customBody(size: 13.0), color: C.Colors.lightText)
    private let separator = UIView(color: .secondaryShadow)
    private let check = UIButton(type: .system)

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
