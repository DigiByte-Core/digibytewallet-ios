//
//  WalletOverlayView.swift
//  bitradio
//
//  Created by Yoshi Jäger on 04.08.18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit

/* shadow and shape overlay for wallet transaction card */
class WalletOverlayView: UIView {
    private let shape: CAShapeLayer
    
    override init(frame: CGRect) {
        shape = CAShapeLayer()
        super.init(frame: frame)
        layer.addSublayer(shape)
        style()
    }
    
    private func style() {
        shape.lineWidth = 1
        // #191A29
        shape.fillColor = UIColor(red: 0x19 / 255, green: 0x1A / 255, blue: 0x29 / 255, alpha: 1).cgColor
        shape.strokeColor = UIColor.clear.cgColor
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.13;
        layer.shadowOffset = CGSize(width: 0, height: -7.0);
        layer.shadowRadius = 5.0;
        layer.masksToBounds = false;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func recalc() {
        let cutStart: CGFloat = shape.frame.height * 1 / 3
        let curveStart: CGFloat = shape.frame.width * 1 / 6
        let middle: CGFloat = shape.frame.width / 2
        let curveStrengthBottom: CGFloat = 0.6
        let curveStrength: CGFloat = 0.2
        
        let curveEnd: CGFloat = shape.frame.width - curveStart
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: shape.frame.height))
        path.addLine(to: CGPoint(x: 0, y: cutStart))
        path.addLine(to: CGPoint(x: curveStart, y: cutStart))
        
        path.addCurve(
            to: CGPoint(x: middle, y: 0),
            controlPoint1: CGPoint(x: middle * (1 - curveStrength), y: cutStart),
            controlPoint2: CGPoint(x: curveStart * (1 + curveStrengthBottom), y: 0)
        )
        
        path.addCurve(
            to: CGPoint(x: curveEnd, y: cutStart),
            controlPoint1: CGPoint(x: shape.frame.width - curveStart * (1 + curveStrengthBottom), y: 0),
            controlPoint2: CGPoint(x: shape.frame.width - middle * (1 - curveStrength), y: cutStart)
        )
        
        path.addLine(to: CGPoint(x: shape.frame.width, y: cutStart))
        path.addLine(to: CGPoint(x: shape.frame.width, y: shape.frame.height))
        path.close()
        path.fill()
        
        shape.path = path.cgPath
        shape.shadowPath = path.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shape.frame = self.layer.bounds
        recalc()
    }
}
