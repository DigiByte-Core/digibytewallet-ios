//
//  UILabel+CharacterSpacing.swift
//  breadwallet
//
//  Created by Yoshi Jäger on 19.05.18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit

extension UILabel {
    func setCharacterSpacing(_ spacing: Double) {
        guard let t = self.text else { return }
        let attributedString = NSMutableAttributedString(string: t)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: spacing, range: NSRange(location: 0, length: attributedString.length))
        self.attributedText = attributedString
    }
}
