//
//  TransactionCardView.swift
//  bitradio
//
//  Created by Yoshi Jäger on 04.08.18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit

class TransactionCardView: UIView {
    private let circleWidth: CGFloat = 16
    private let dots: UIImageView
    private let circleLeft: UIView
    private let circleRight: UIView
    private var dotLineTopConstrain: NSLayoutConstraint? = nil
    
    var foldLineTop: CGFloat = -100 {
        didSet {
            dotLineTopConstrain?.constant = foldLineTop
            dots.setNeedsLayout()
            updateMask()
        }
    }
    
    private func updateMask() {
        
        let f = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        
        let shape = CAShapeLayer()
        shape.frame = f
        
        let outerPath = UIBezierPath(roundedRect: f, cornerRadius: 12)
        
        /* debugging
         let view = UIView(frame: f)
         view.backgroundColor = .red
         view.layer.opacity = 0.1
         addSubview(view)
         */
        
        let circlePath1 = UIBezierPath(ovalIn: circleLeft.frame)
        let circlePath2 = UIBezierPath(ovalIn: circleRight.frame)
        outerPath.usesEvenOddFillRule = true
        outerPath.append(circlePath1)
        outerPath.append(circlePath2)
        
        shape.fillColor = UIColor.white.cgColor
        shape.fillRule = kCAFillRuleEvenOdd
        shape.path = outerPath.cgPath
        
        layer.mask = shape
    }
    
    override init(frame: CGRect) {
        dots = UIImageView(image: #imageLiteral(resourceName: "dots"))
        dots.contentMode = .scaleToFill
        circleLeft = UIView()
        circleRight = UIView()
        super.init(frame: frame)
        
        addSubview(circleLeft)
        addSubview(circleRight)
        
        addSubview(dots)
        dotLineTopConstrain = dots.topAnchor.constraint(equalTo: topAnchor, constant: -circleWidth)
        dots.constrain([
            dotLineTopConstrain,
            dots.leftAnchor.constraint(equalTo: leftAnchor),
            dots.rightAnchor.constraint(equalTo: rightAnchor),
            dots.heightAnchor.constraint(equalToConstant: 1.0)
            ])
        
        circleLeft.constrain([
            circleLeft.rightAnchor.constraint(equalTo: dots.leftAnchor, constant: circleWidth / 2),
            circleLeft.topAnchor.constraint(equalTo: dots.topAnchor, constant: -circleWidth / 2),
            circleLeft.widthAnchor.constraint(equalToConstant: circleWidth),
            circleLeft.heightAnchor.constraint(equalToConstant: circleWidth),
            ])
        
        circleRight.constrain([
            circleRight.leftAnchor.constraint(equalTo: dots.rightAnchor, constant: -circleWidth / 2),
            circleRight.topAnchor.constraint(equalTo: dots.topAnchor, constant: -circleWidth / 2),
            circleRight.widthAnchor.constraint(equalToConstant: circleWidth),
            circleRight.heightAnchor.constraint(equalToConstant: circleWidth),
            ])
        
        circleLeft.backgroundColor = .clear
        
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        // layer.cornerRadius = 12
        backgroundColor = UIColor(red: 0x1D / 255, green: 0x1C / 255, blue: 0x2B / 255, alpha: 1) // #1D1C2B
        // layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMask()
    }
}
