//
//  StartNavigationDelegate.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-27.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

class StartNavigationDelegate : NSObject, UINavigationControllerDelegate {

    let store: Store

    init(store: Store) {
        self.store = store
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        // default
        navigationController.navigationBar.barTintColor = .clear
        
        if viewController is RecoverWalletIntroViewController {
            navigationController.navigationBar.tintColor = .white
            navigationController.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.customBold(size: 17.0)
            ]
            navigationController.setClearNavbar()
            navigationController.navigationBar.barTintColor = .clear
        }

        if viewController is EnterPhraseViewController {
            navigationController.navigationBar.tintColor = .clear
            navigationController.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.customBold(size: 17.0)
            ]
            navigationController.setClearNavbar()
            navigationController.navigationBar.isTranslucent = true
            navigationController.navigationBar.barTintColor = .clear
            navigationController.navigationBar.tintColor = .white
        }

        if viewController is UpdatePinViewController {
            navigationController.navigationBar.tintColor = .white
            navigationController.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.customBold(size: 17.0)
            ]
            navigationController.setClearNavbar()
        }

        if viewController is UpdatePinViewController {
            if let gr = navigationController.interactivePopGestureRecognizer {
                navigationController.view.removeGestureRecognizer(gr)
            }
        }

        if viewController is StartWipeWalletViewController {
            navigationController.setClearNavbar()
            navigationController.navigationBar.barTintColor = .clear
            navigationController.navigationBar.isTranslucent = true
            // navigationController.setWhiteStyle()
        }
    }
}
