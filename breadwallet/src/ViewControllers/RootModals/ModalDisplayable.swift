//
//  ModalDisplayable.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-12-01.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

protocol ModalDisplayable {
    var modalTitle: String { get }
    var modalSize: CGSize { get }
    var isFaqHidden: Bool { get }
}

protocol ModalPresentable {
    var parentView: UIView? { get set }
}
