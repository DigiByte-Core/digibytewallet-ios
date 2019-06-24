//
//  Circle.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-24.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

class Circle: UIView {

    private let color: UIColor
    private var isFilled: Bool = false

    static let defaultSize: CGFloat = 64.0

    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    func filled() -> Circle {
        isFilled = true
        return self
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if (isFilled) {
            context.addEllipse(in: rect)
            context.setFillColor(C.Colors.blue.cgColor)
            context.fillPath()
        }
        
        let innerColor: CGColor = {
            if (isFilled) {
                return UIColor(white: 1, alpha: 0.2).cgColor
            } else {
                return C.Colors.dark3.cgColor
            }
        }()
        
        context.addEllipse(in: rect.insetBy(dx: 15, dy: 15))
        context.setFillColor(innerColor)
        context.fillPath()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
