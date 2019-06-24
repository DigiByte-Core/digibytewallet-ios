//
//  GradientSwitch.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-04-05.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

class GradientSwitch : UISwitch {

    init() {
        super.init(frame: .zero)
        setup()
    }

    // ToDo: cleanup
//    private let background: GradientView = {
//        let view = GradientView()
//        view.clipsToBounds = true
//        view.layer.cornerRadius = 16.0
//        view.alpha = 0.0
//        return view
//    }()

    private func setup() {
        // onTintColor = .clear
        onTintColor = C.Colors.weirdGreen
        // tintColor = C.Colors.blueGrey
        //insertSubview(background, at: 0)
        //background.constrain(toSuperviewEdges: nil)
        addTarget(self, action: #selector(toggleBackground), for: .valueChanged)
    }

    @objc private func toggleBackground() {
//        UIView.animate(withDuration: 0.1, animations: {
//            self.onTintColor = self.isOn ? C.Colors.weirdGreen : .clear
//        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
