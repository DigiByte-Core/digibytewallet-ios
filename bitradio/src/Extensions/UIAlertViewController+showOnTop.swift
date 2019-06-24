//
//  UIAlertViewController+showOnTop.swift
//  bitradio
//
//  Created by Yoshi Jäger on 07.02.19.
//  Copyright © 2019 breadwallet LLC. All rights reserved.
//

import UIKit

// https://stackoverflow.com/questions/40991450/ios-present-uialertcontroller-on-top-of-everything-regardless-of-the-view-hier
public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
