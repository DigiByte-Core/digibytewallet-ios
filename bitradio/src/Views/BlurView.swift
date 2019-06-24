//
//  BlurView.swift
//  bitradio
//
//  Created by Yoshi Jäger on 27.06.18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import Foundation
import VisualEffectView

class BlurView: VisualEffectView {
    override init(effect: UIVisualEffect? = nil) {
        super.init(effect: effect)
        configure()
    }
    
    private func configure() {
        colorTint = C.Colors.blue
        colorTintAlpha = 0.7
        blurRadius = 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
