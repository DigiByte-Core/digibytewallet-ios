//
//  Setting.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-04-01.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import Foundation

struct Setting {
    let title: String
    let accessoryText: (() -> String)?
    let callback: (Bool) -> Void
    let switchViewMode: Bool
    let initialSwitchValue: Bool
}

extension Setting {
    init(title: String, callback: @escaping () -> Void) {
        self.title = title
        self.accessoryText = nil
        self.callback = { (_) in callback() }
        self.switchViewMode = false
        self.initialSwitchValue = false
    }
    
    init(title: String, accessoryText: @escaping () -> String, callback: @escaping () -> Void) {
        self.title = title
        self.accessoryText = accessoryText
        self.callback = { (_) in callback() }
        self.switchViewMode = false
        self.initialSwitchValue = false
    }
    
    // callback is called when switch value was changed
    init(switchWithTitle: String, initial: Bool, callback: @escaping (Bool) -> Void) {
        self.title = switchWithTitle
        self.accessoryText = nil
        self.callback = callback
        self.switchViewMode = true
        self.initialSwitchValue = initial
    }
}
