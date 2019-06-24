//
//  WhiteNumberPad.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-03-16.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

class WhiteNumberPad : GenericPinPadCell {

    override func setAppearance() {
        
        if text == "0" {
            topLabel.isHidden = true
            centerLabel.isHidden = false
        } else {
            topLabel.isHidden = false
            centerLabel.isHidden = true
        }

        if isHighlighted {
            backgroundColor = C.Colors.background
            topLabel.textColor = .white
            centerLabel.textColor = .white
            sublabel.textColor = .white
        } else {
            if text == "" || text == deleteKeyIdentifier {
                backgroundColor = C.Colors.background
                imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = C.Colors.blueGrey
            } else {
                backgroundColor = C.Colors.background
                topLabel.textColor = C.Colors.blueGrey
                centerLabel.textColor = C.Colors.blueGrey
                sublabel.textColor = C.Colors.blueGrey
            }
        }
    }

    override func setSublabel() {
        guard let text = self.text else { return }
        if sublabels[text] != nil {
            sublabel.text = sublabels[text]
        }
    }
}
