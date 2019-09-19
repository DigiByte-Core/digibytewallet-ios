//
//  MenuButtonType.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-30.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

enum MenuButtonType {
    case security
    case support
    case settings
    case lock

    var title: String {
        switch self {
        case .security:
            return S.MenuButton.security
        case .support:
            return S.MenuButton.support
        case .settings:
            return S.MenuButton.settings
        case .lock:
            return S.MenuButton.lock
        }
    }

    var image: UIImage {
        switch self {
        case .security:
            return UIImage(named: "Shield")!
        case .support:
            return UIImage(named: "FaqFill")!
        case .settings:
            return UIImage(named: "Settings")!
        case .lock:
            return UIImage(named: "Lock")!
        }
    }
}
