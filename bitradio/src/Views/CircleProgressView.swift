//
//  CircleProgressView.swift
//  breadwallet
//
//  Created by ploenne on 14.06.18.
//  Copyright © 2018 dgb foundation. All rights reserved.
//

import UIKit

class CircleProgressView: UIView {

    var syncProgress: CGFloat {
        set {    let fr = Int((newValue * 10).truncatingRemainder(dividingBy: 10))
                self.progressFractionText = ".\(fr)"
                let r = Int(newValue)
                self.progressText = "\(r)"
                self.outerProgress = newValue / 100.0
        }
        get { return 0}
    }
    var innerProgress: CGFloat = 0.0

    private var outerProgress: CGFloat = 0
    private var progressText: String = "0"
    private var progressFractionText: String = "0"

    var blockHeightText: String = "0"
	var lastBlockTimeSt: String = "0"
	var lastBlockTextSt: String = "LAST BLOCK"
    var showInnerProgress: Bool = false
    
    private var fontSize: CGFloat = 37.0
    private var fontName: String = "GillSans"
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation. */
    override func draw(_ rect: CGRect) {

        var frame: CGRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        
        self.fontSize = 32.0 + ((self.frame.size.width - 150) / 10.0)

        let context = UIGraphicsGetCurrentContext()!

        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }
        
        //// Color Declarations
        let outer1 = UIColor(red: 0.701, green: 0.932, blue: 0.311, alpha: 1.000)
        let color2 = UIColor(red: 0.262, green: 0.580, blue: 0.126, alpha: 1.000)
        let inner1 = UIColor(red: 0.532, green: 0.670, blue: 0.382, alpha: 1.000)
        let inner2 = UIColor(red: 0.140, green: 0.234, blue: 0.121, alpha: 1.000)
        let color3 = UIColor(red: 0.000, green: 0.415, blue: 0.787, alpha: 1.000)
        let color4 = UIColor(red: 0.000, green: 0.192, blue: 0.407, alpha: 1.000)
        let color5 = UIColor(red: 0.000, green: 0.184, blue: 0.333, alpha: 1.000)
        let color6 = UIColor(red: 0.038, green: 0.111, blue: 0.228, alpha: 1.000)
        let base1 = UIColor(red: 0.195, green: 0.201, blue: 0.300, alpha: 1.000)
        let base2 = UIColor(red: 0.143, green: 0.150, blue: 0.262, alpha: 1.000)
        let lineColor = self.backgroundColor != nil ? self.backgroundColor! :  UIColor.black
        
        //// Gradient Declarations
        let gradient1 = CGGradient(colorsSpace: nil, colors: [outer1.cgColor, color2.cgColor] as CFArray, locations: [0, 1])!
        let gradient2 = CGGradient(colorsSpace: nil, colors: [inner1.cgColor, inner2.cgColor] as CFArray, locations: [0, 1])!
        let gradient3 = CGGradient(colorsSpace: nil, colors: [color3.cgColor, color4.cgColor] as CFArray, locations: [0, 1])!
        let gradient4 = CGGradient(colorsSpace: nil, colors: [color5.cgColor, color6.cgColor] as CFArray, locations: [0, 1])!

        //// Subframes
        let baseRings: CGRect = CGRect(x: frame.minX, y: frame.minY + fastFloor((frame.height) * 0.00000 + 0.5), width: frame.width, height: frame.height - fastFloor((frame.height) * 0.00000 + 0.5))
        let rings: CGRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let lines: CGRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let textGroup: CGRect = CGRect(x: frame.minX, y: frame.height * 0.25, width: frame.width, height: frame.height * 0.5)
        
        //// Base Rings
        if (showInnerProgress) {
            //// BaseRing4 Drawing
            let baseRing4Path = UIBezierPath()
            baseRing4Path.move(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.14000 * baseRings.height))
            baseRing4Path.addCurve(to: CGPoint(x: baseRings.minX + 0.31884 * baseRings.width, y: baseRings.minY + 0.18884 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.43395 * baseRings.width, y: baseRings.minY + 0.14000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.37205 * baseRings.width, y: baseRings.minY + 0.15779 * baseRings.height))
            baseRing4Path.addCurve(to: CGPoint(x: baseRings.minX + 0.14000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.21187 * baseRings.width, y: baseRings.minY + 0.25125 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.14000 * baseRings.width, y: baseRings.minY + 0.36723 * baseRings.height))
            baseRing4Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.86000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.14000 * baseRings.width, y: baseRings.minY + 0.69882 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.30118 * baseRings.width, y: baseRings.minY + 0.86000 * baseRings.height))
            baseRing4Path.addCurve(to: CGPoint(x: baseRings.minX + 0.86000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.69882 * baseRings.width, y: baseRings.minY + 0.86000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.86000 * baseRings.width, y: baseRings.minY + 0.69882 * baseRings.height))
            baseRing4Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.14000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.86000 * baseRings.width, y: baseRings.minY + 0.30118 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.69882 * baseRings.width, y: baseRings.minY + 0.14000 * baseRings.height))
            baseRing4Path.close()
            baseRing4Path.move(to: CGPoint(x: baseRings.minX + 0.89000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height))
            baseRing4Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.89000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.89000 * baseRings.width, y: baseRings.minY + 0.71539 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.71539 * baseRings.width, y: baseRings.minY + 0.89000 * baseRings.height))
            baseRing4Path.addCurve(to: CGPoint(x: baseRings.minX + 0.11000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.28461 * baseRings.width, y: baseRings.minY + 0.89000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.11000 * baseRings.width, y: baseRings.minY + 0.71539 * baseRings.height))
            baseRing4Path.addCurve(to: CGPoint(x: baseRings.minX + 0.29422 * baseRings.width, y: baseRings.minY + 0.16864 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.11000 * baseRings.width, y: baseRings.minY + 0.36014 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.18362 * baseRings.width, y: baseRings.minY + 0.23748 * baseRings.height))
            baseRing4Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.11000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.35395 * baseRings.width, y: baseRings.minY + 0.13147 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.42447 * baseRings.width, y: baseRings.minY + 0.11000 * baseRings.height))
            baseRing4Path.addCurve(to: CGPoint(x: baseRings.minX + 0.89000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.71539 * baseRings.width, y: baseRings.minY + 0.11000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.89000 * baseRings.width, y: baseRings.minY + 0.28461 * baseRings.height))
            baseRing4Path.close()
            base2.setFill()
            baseRing4Path.fill()
            
            
            //// BaseRing3 Drawing
            let baseRing3Path = UIBezierPath()
            baseRing3Path.move(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.11000 * baseRings.height))
            baseRing3Path.addCurve(to: CGPoint(x: baseRings.minX + 0.29422 * baseRings.width, y: baseRings.minY + 0.16864 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.42447 * baseRings.width, y: baseRings.minY + 0.11000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.35395 * baseRings.width, y: baseRings.minY + 0.13147 * baseRings.height))
            baseRing3Path.addCurve(to: CGPoint(x: baseRings.minX + 0.11000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.18362 * baseRings.width, y: baseRings.minY + 0.23748 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.11000 * baseRings.width, y: baseRings.minY + 0.36014 * baseRings.height))
            baseRing3Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.89000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.11000 * baseRings.width, y: baseRings.minY + 0.71539 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.28461 * baseRings.width, y: baseRings.minY + 0.89000 * baseRings.height))
            baseRing3Path.addCurve(to: CGPoint(x: baseRings.minX + 0.89000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.71539 * baseRings.width, y: baseRings.minY + 0.89000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.89000 * baseRings.width, y: baseRings.minY + 0.71539 * baseRings.height))
            baseRing3Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.11000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.89000 * baseRings.width, y: baseRings.minY + 0.28461 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.71539 * baseRings.width, y: baseRings.minY + 0.11000 * baseRings.height))
            baseRing3Path.close()
            baseRing3Path.move(to: CGPoint(x: baseRings.minX + 0.92000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height))
            baseRing3Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.92000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.92000 * baseRings.width, y: baseRings.minY + 0.73196 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.73196 * baseRings.width, y: baseRings.minY + 0.92000 * baseRings.height))
            baseRing3Path.addCurve(to: CGPoint(x: baseRings.minX + 0.08000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.26804 * baseRings.width, y: baseRings.minY + 0.92000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.08000 * baseRings.width, y: baseRings.minY + 0.73196 * baseRings.height))
            baseRing3Path.addCurve(to: CGPoint(x: baseRings.minX + 0.26883 * baseRings.width, y: baseRings.minY + 0.14929 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.08000 * baseRings.width, y: baseRings.minY + 0.35345 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.15506 * baseRings.width, y: baseRings.minY + 0.22443 * baseRings.height))
            baseRing3Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.08000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.33513 * baseRings.width, y: baseRings.minY + 0.10549 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.41459 * baseRings.width, y: baseRings.minY + 0.08000 * baseRings.height))
            baseRing3Path.addCurve(to: CGPoint(x: baseRings.minX + 0.92000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.73196 * baseRings.width, y: baseRings.minY + 0.08000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.92000 * baseRings.width, y: baseRings.minY + 0.26804 * baseRings.height))
            baseRing3Path.close()
            base1.setFill()
            baseRing3Path.fill()
        }
        
        
        //// BaseRing2 Drawing
        let baseRing2Path = UIBezierPath()
        baseRing2Path.move(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.06000 * baseRings.height))
        baseRing2Path.addCurve(to: CGPoint(x: baseRings.minX + 0.25151 * baseRings.width, y: baseRings.minY + 0.13684 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.40780 * baseRings.width, y: baseRings.minY + 0.06000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.32222 * baseRings.width, y: baseRings.minY + 0.08836 * baseRings.height))
        baseRing2Path.addCurve(to: CGPoint(x: baseRings.minX + 0.06000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.13586 * baseRings.width, y: baseRings.minY + 0.21612 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.06000 * baseRings.width, y: baseRings.minY + 0.34920 * baseRings.height))
        baseRing2Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.94000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.06000 * baseRings.width, y: baseRings.minY + 0.74301 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.25699 * baseRings.width, y: baseRings.minY + 0.94000 * baseRings.height))
        baseRing2Path.addCurve(to: CGPoint(x: baseRings.minX + 0.94000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.74301 * baseRings.width, y: baseRings.minY + 0.94000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.94000 * baseRings.width, y: baseRings.minY + 0.74301 * baseRings.height))
        baseRing2Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.06000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.94000 * baseRings.width, y: baseRings.minY + 0.25699 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.74301 * baseRings.width, y: baseRings.minY + 0.06000 * baseRings.height))
        baseRing2Path.close()
        baseRing2Path.move(to: CGPoint(x: baseRings.minX + 0.97000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height))
        baseRing2Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.97000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.97000 * baseRings.width, y: baseRings.minY + 0.75957 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.75957 * baseRings.width, y: baseRings.minY + 0.97000 * baseRings.height))
        baseRing2Path.addCurve(to: CGPoint(x: baseRings.minX + 0.03000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.24043 * baseRings.width, y: baseRings.minY + 0.97000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.03000 * baseRings.width, y: baseRings.minY + 0.75957 * baseRings.height))
        baseRing2Path.addCurve(to: CGPoint(x: baseRings.minX + 0.22500 * baseRings.width, y: baseRings.minY + 0.11881 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.03000 * baseRings.width, y: baseRings.minY + 0.34311 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.10687 * baseRings.width, y: baseRings.minY + 0.20418 * baseRings.height))
        baseRing2Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.03000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.30232 * baseRings.width, y: baseRings.minY + 0.06293 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.39731 * baseRings.width, y: baseRings.minY + 0.03000 * baseRings.height))
        baseRing2Path.addCurve(to: CGPoint(x: baseRings.minX + 0.97000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.75957 * baseRings.width, y: baseRings.minY + 0.03000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.97000 * baseRings.width, y: baseRings.minY + 0.24043 * baseRings.height))
        baseRing2Path.close()
        base2.setFill()
        baseRing2Path.fill()
        
        
        //// BaseRing1 Drawing
        let baseRing1Path = UIBezierPath()
        baseRing1Path.move(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.03000 * baseRings.height))
        baseRing1Path.addCurve(to: CGPoint(x: baseRings.minX + 0.22500 * baseRings.width, y: baseRings.minY + 0.11881 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.39731 * baseRings.width, y: baseRings.minY + 0.03000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.30232 * baseRings.width, y: baseRings.minY + 0.06293 * baseRings.height))
        baseRing1Path.addCurve(to: CGPoint(x: baseRings.minX + 0.03000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.10687 * baseRings.width, y: baseRings.minY + 0.20418 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.03000 * baseRings.width, y: baseRings.minY + 0.34311 * baseRings.height))
        baseRing1Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.97000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.03000 * baseRings.width, y: baseRings.minY + 0.75957 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.24043 * baseRings.width, y: baseRings.minY + 0.97000 * baseRings.height))
        baseRing1Path.addCurve(to: CGPoint(x: baseRings.minX + 0.97000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.75957 * baseRings.width, y: baseRings.minY + 0.97000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.97000 * baseRings.width, y: baseRings.minY + 0.75957 * baseRings.height))
        baseRing1Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.03000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.97000 * baseRings.width, y: baseRings.minY + 0.24043 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.75957 * baseRings.width, y: baseRings.minY + 0.03000 * baseRings.height))
        baseRing1Path.close()
        baseRing1Path.move(to: CGPoint(x: baseRings.minX + 1.00000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height))
        baseRing1Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 1.00000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 1.00000 * baseRings.width, y: baseRings.minY + 0.77614 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.77614 * baseRings.width, y: baseRings.minY + 1.00000 * baseRings.height))
        baseRing1Path.addCurve(to: CGPoint(x: baseRings.minX + 0.00000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.22386 * baseRings.width, y: baseRings.minY + 1.00000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.00000 * baseRings.width, y: baseRings.minY + 0.77614 * baseRings.height))
        baseRing1Path.addCurve(to: CGPoint(x: baseRings.minX + 0.19894 * baseRings.width, y: baseRings.minY + 0.10076 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.00000 * baseRings.width, y: baseRings.minY + 0.33689 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.07810 * baseRings.width, y: baseRings.minY + 0.19203 * baseRings.height))
        baseRing1Path.addCurve(to: CGPoint(x: baseRings.minX + 0.50000 * baseRings.width, y: baseRings.minY + 0.00000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.28269 * baseRings.width, y: baseRings.minY + 0.03751 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 0.38696 * baseRings.width, y: baseRings.minY + 0.00000 * baseRings.height))
        baseRing1Path.addCurve(to: CGPoint(x: baseRings.minX + 1.00000 * baseRings.width, y: baseRings.minY + 0.50000 * baseRings.height), controlPoint1: CGPoint(x: baseRings.minX + 0.77614 * baseRings.width, y: baseRings.minY + 0.00000 * baseRings.height), controlPoint2: CGPoint(x: baseRings.minX + 1.00000 * baseRings.width, y: baseRings.minY + 0.22386 * baseRings.height))
        baseRing1Path.close()
        base1.setFill()
        baseRing1Path.fill()
        
        
        
        
        //// Rings
        if (showInnerProgress) {
            //// inner
            context.saveGState()
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            
            
            //// Ring4 Drawing
            let ring4Path = UIBezierPath()
            ring4Path.move(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.14000 * rings.height))
            ring4Path.addCurve(to: CGPoint(x: rings.minX + 0.31884 * rings.width, y: rings.minY + 0.18884 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.43395 * rings.width, y: rings.minY + 0.14000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.37205 * rings.width, y: rings.minY + 0.15779 * rings.height))
            ring4Path.addCurve(to: CGPoint(x: rings.minX + 0.14000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.21187 * rings.width, y: rings.minY + 0.25125 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.14000 * rings.width, y: rings.minY + 0.36723 * rings.height))
            ring4Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.86000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.14000 * rings.width, y: rings.minY + 0.69882 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.30118 * rings.width, y: rings.minY + 0.86000 * rings.height))
            ring4Path.addCurve(to: CGPoint(x: rings.minX + 0.86000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.69882 * rings.width, y: rings.minY + 0.86000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.86000 * rings.width, y: rings.minY + 0.69882 * rings.height))
            ring4Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.14000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.86000 * rings.width, y: rings.minY + 0.30118 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.69882 * rings.width, y: rings.minY + 0.14000 * rings.height))
            ring4Path.close()
            ring4Path.move(to: CGPoint(x: rings.minX + 0.89000 * rings.width, y: rings.minY + 0.50000 * rings.height))
            ring4Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.89000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.89000 * rings.width, y: rings.minY + 0.71539 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.71539 * rings.width, y: rings.minY + 0.89000 * rings.height))
            ring4Path.addCurve(to: CGPoint(x: rings.minX + 0.11000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.28461 * rings.width, y: rings.minY + 0.89000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.11000 * rings.width, y: rings.minY + 0.71539 * rings.height))
            ring4Path.addCurve(to: CGPoint(x: rings.minX + 0.29422 * rings.width, y: rings.minY + 0.16864 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.11000 * rings.width, y: rings.minY + 0.36014 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.18362 * rings.width, y: rings.minY + 0.23748 * rings.height))
            ring4Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.11000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.35395 * rings.width, y: rings.minY + 0.13147 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.42447 * rings.width, y: rings.minY + 0.11000 * rings.height))
            ring4Path.addCurve(to: CGPoint(x: rings.minX + 0.89000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.71539 * rings.width, y: rings.minY + 0.11000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.89000 * rings.width, y: rings.minY + 0.28461 * rings.height))
            ring4Path.close()
            context.saveGState()
            ring4Path.addClip()
            let ring4Bounds = ring4Path.cgPath.boundingBoxOfPath
            context.drawLinearGradient(gradient4,
                                       start: CGPoint(x: ring4Bounds.midX, y: ring4Bounds.minY),
                                       end: CGPoint(x: ring4Bounds.midX, y: ring4Bounds.maxY),
                                       options: [])
            context.restoreGState()
            
            
            //// Ring3 Drawing
            let ring3Path = UIBezierPath()
            ring3Path.move(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.11000 * rings.height))
            ring3Path.addCurve(to: CGPoint(x: rings.minX + 0.29422 * rings.width, y: rings.minY + 0.16864 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.42447 * rings.width, y: rings.minY + 0.11000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.35395 * rings.width, y: rings.minY + 0.13147 * rings.height))
            ring3Path.addCurve(to: CGPoint(x: rings.minX + 0.11000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.18362 * rings.width, y: rings.minY + 0.23748 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.11000 * rings.width, y: rings.minY + 0.36014 * rings.height))
            ring3Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.89000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.11000 * rings.width, y: rings.minY + 0.71539 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.28461 * rings.width, y: rings.minY + 0.89000 * rings.height))
            ring3Path.addCurve(to: CGPoint(x: rings.minX + 0.89000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.71539 * rings.width, y: rings.minY + 0.89000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.89000 * rings.width, y: rings.minY + 0.71539 * rings.height))
            ring3Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.11000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.89000 * rings.width, y: rings.minY + 0.28461 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.71539 * rings.width, y: rings.minY + 0.11000 * rings.height))
            ring3Path.close()
            ring3Path.move(to: CGPoint(x: rings.minX + 0.92000 * rings.width, y: rings.minY + 0.50000 * rings.height))
            ring3Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.92000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.92000 * rings.width, y: rings.minY + 0.73196 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.73196 * rings.width, y: rings.minY + 0.92000 * rings.height))
            ring3Path.addCurve(to: CGPoint(x: rings.minX + 0.08000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.26804 * rings.width, y: rings.minY + 0.92000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.08000 * rings.width, y: rings.minY + 0.73196 * rings.height))
            ring3Path.addCurve(to: CGPoint(x: rings.minX + 0.26883 * rings.width, y: rings.minY + 0.14929 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.08000 * rings.width, y: rings.minY + 0.35345 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.15506 * rings.width, y: rings.minY + 0.22443 * rings.height))
            ring3Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.08000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.33513 * rings.width, y: rings.minY + 0.10549 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.41459 * rings.width, y: rings.minY + 0.08000 * rings.height))
            ring3Path.addCurve(to: CGPoint(x: rings.minX + 0.92000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.73196 * rings.width, y: rings.minY + 0.08000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.92000 * rings.width, y: rings.minY + 0.26804 * rings.height))
            ring3Path.close()
            context.saveGState()
            ring3Path.addClip()
            let ring3Bounds = ring3Path.cgPath.boundingBoxOfPath
            context.drawLinearGradient(gradient3,
                                       start: CGPoint(x: ring3Bounds.midX, y: ring3Bounds.minY),
                                       end: CGPoint(x: ring3Bounds.midX, y: ring3Bounds.maxY),
                                       options: [])
            context.restoreGState()
            
            
            //// Oval 2 Drawing
            context.saveGState()
            context.setBlendMode(.destinationOut)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            
            let oval2Rect = CGRect(x: rings.minX + fastFloor(rings.width * 0.08000 + 0.5), y: rings.minY + fastFloor(rings.height * 0.08000 + 0.5), width: fastFloor(rings.width * 0.92000 + 0.5) - fastFloor(rings.width * 0.08000 + 0.5), height: fastFloor(rings.height * 0.92000 + 0.5) - fastFloor(rings.height * 0.08000 + 0.5))
            let oval2Path = UIBezierPath()
            oval2Path.addArc(withCenter: CGPoint(x: oval2Rect.midX, y: oval2Rect.midY), radius: oval2Rect.width / 2, startAngle: -0.5 * CGFloat.pi, endAngle: (innerProgress * 2.0 * CGFloat.pi) - 0.5 * CGFloat.pi, clockwise: false)
            oval2Path.addLine(to: CGPoint(x: oval2Rect.midX, y: oval2Rect.midY))
            oval2Path.close()
            
            UIColor.gray.setFill()
            oval2Path.fill()
            
            context.endTransparencyLayer()
            context.restoreGState()
            
            
            context.endTransparencyLayer()
            context.restoreGState()
        }
        
        
        //// outer
        context.saveGState()
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        
        
        //// Ring2 Drawing
        let ring2Path = UIBezierPath()
        ring2Path.move(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.06000 * rings.height))
        ring2Path.addCurve(to: CGPoint(x: rings.minX + 0.25151 * rings.width, y: rings.minY + 0.13684 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.40780 * rings.width, y: rings.minY + 0.06000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.32222 * rings.width, y: rings.minY + 0.08836 * rings.height))
        ring2Path.addCurve(to: CGPoint(x: rings.minX + 0.06000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.13586 * rings.width, y: rings.minY + 0.21612 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.06000 * rings.width, y: rings.minY + 0.34920 * rings.height))
        ring2Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.94000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.06000 * rings.width, y: rings.minY + 0.74301 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.25699 * rings.width, y: rings.minY + 0.94000 * rings.height))
        ring2Path.addCurve(to: CGPoint(x: rings.minX + 0.94000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.74301 * rings.width, y: rings.minY + 0.94000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.94000 * rings.width, y: rings.minY + 0.74301 * rings.height))
        ring2Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.06000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.94000 * rings.width, y: rings.minY + 0.25699 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.74301 * rings.width, y: rings.minY + 0.06000 * rings.height))
        ring2Path.close()
        ring2Path.move(to: CGPoint(x: rings.minX + 0.97000 * rings.width, y: rings.minY + 0.50000 * rings.height))
        ring2Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.97000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.97000 * rings.width, y: rings.minY + 0.75957 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.75957 * rings.width, y: rings.minY + 0.97000 * rings.height))
        ring2Path.addCurve(to: CGPoint(x: rings.minX + 0.03000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.24043 * rings.width, y: rings.minY + 0.97000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.03000 * rings.width, y: rings.minY + 0.75957 * rings.height))
        ring2Path.addCurve(to: CGPoint(x: rings.minX + 0.22500 * rings.width, y: rings.minY + 0.11881 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.03000 * rings.width, y: rings.minY + 0.34311 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.10687 * rings.width, y: rings.minY + 0.20418 * rings.height))
        ring2Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.03000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.30232 * rings.width, y: rings.minY + 0.06293 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.39731 * rings.width, y: rings.minY + 0.03000 * rings.height))
        ring2Path.addCurve(to: CGPoint(x: rings.minX + 0.97000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.75957 * rings.width, y: rings.minY + 0.03000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.97000 * rings.width, y: rings.minY + 0.24043 * rings.height))
        ring2Path.close()
        context.saveGState()
        ring2Path.addClip()
        let ring2Bounds = ring2Path.cgPath.boundingBoxOfPath
        context.drawLinearGradient(gradient2,
                                   start: CGPoint(x: ring2Bounds.midX, y: ring2Bounds.minY),
                                   end: CGPoint(x: ring2Bounds.midX, y: ring2Bounds.maxY),
                                   options: [])
        context.restoreGState()
        
        
        //// Ring 1 Drawing
        let ring1Path = UIBezierPath()
        ring1Path.move(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.03000 * rings.height))
        ring1Path.addCurve(to: CGPoint(x: rings.minX + 0.22500 * rings.width, y: rings.minY + 0.11881 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.39731 * rings.width, y: rings.minY + 0.03000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.30232 * rings.width, y: rings.minY + 0.06293 * rings.height))
        ring1Path.addCurve(to: CGPoint(x: rings.minX + 0.03000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.10687 * rings.width, y: rings.minY + 0.20418 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.03000 * rings.width, y: rings.minY + 0.34311 * rings.height))
        ring1Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.97000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.03000 * rings.width, y: rings.minY + 0.75957 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.24043 * rings.width, y: rings.minY + 0.97000 * rings.height))
        ring1Path.addCurve(to: CGPoint(x: rings.minX + 0.97000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.75957 * rings.width, y: rings.minY + 0.97000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.97000 * rings.width, y: rings.minY + 0.75957 * rings.height))
        ring1Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.03000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.97000 * rings.width, y: rings.minY + 0.24043 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.75957 * rings.width, y: rings.minY + 0.03000 * rings.height))
        ring1Path.close()
        ring1Path.move(to: CGPoint(x: rings.minX + 1.00000 * rings.width, y: rings.minY + 0.50000 * rings.height))
        ring1Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 1.00000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 1.00000 * rings.width, y: rings.minY + 0.77614 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.77614 * rings.width, y: rings.minY + 1.00000 * rings.height))
        ring1Path.addCurve(to: CGPoint(x: rings.minX + 0.00000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.22386 * rings.width, y: rings.minY + 1.00000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.00000 * rings.width, y: rings.minY + 0.77614 * rings.height))
        ring1Path.addCurve(to: CGPoint(x: rings.minX + 0.19894 * rings.width, y: rings.minY + 0.10076 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.00000 * rings.width, y: rings.minY + 0.33689 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.07810 * rings.width, y: rings.minY + 0.19203 * rings.height))
        ring1Path.addCurve(to: CGPoint(x: rings.minX + 0.50000 * rings.width, y: rings.minY + 0.00000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.28269 * rings.width, y: rings.minY + 0.03751 * rings.height), controlPoint2: CGPoint(x: rings.minX + 0.38696 * rings.width, y: rings.minY + 0.00000 * rings.height))
        ring1Path.addCurve(to: CGPoint(x: rings.minX + 1.00000 * rings.width, y: rings.minY + 0.50000 * rings.height), controlPoint1: CGPoint(x: rings.minX + 0.77614 * rings.width, y: rings.minY + 0.00000 * rings.height), controlPoint2: CGPoint(x: rings.minX + 1.00000 * rings.width, y: rings.minY + 0.22386 * rings.height))
        ring1Path.close()
        context.saveGState()
        ring1Path.addClip()
        let ring1Bounds = ring1Path.cgPath.boundingBoxOfPath
        context.drawLinearGradient(gradient1,
                                   start: CGPoint(x: ring1Bounds.midX, y: ring1Bounds.minY),
                                   end: CGPoint(x: ring1Bounds.midX, y: ring1Bounds.maxY),
                                   options: [])
        context.restoreGState()
        
        //// Oval Drawing
        context.saveGState()
        context.setBlendMode(.destinationOut)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        
        let ovalRect = CGRect(x: rings.minX + fastFloor(rings.width * 0.00000 + 0.5), y: rings.minY + fastFloor(rings.height * 0.00000 + 0.5), width: fastFloor(rings.width * 1.00000 + 0.5) - fastFloor(rings.width * 0.00000 + 0.5), height: fastFloor(rings.height * 1.00000 + 0.5) - fastFloor(rings.height * 0.00000 + 0.5))
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: -0.5 * CGFloat.pi, endAngle: (outerProgress * 2.0 * CGFloat.pi) - 0.5 * CGFloat.pi, clockwise: false)
        ovalPath.addLine(to: CGPoint(x: ovalRect.midX, y: ovalRect.midY))
        ovalPath.close()
        
        UIColor.white.setFill()
        ovalPath.fill()
        
        context.endTransparencyLayer()
        context.restoreGState()

        context.endTransparencyLayer()
        context.restoreGState()

        //// Lines
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.00001 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.15004 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.00001 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.05975 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.50000 * lines.width, y: lines.minY + 0.15000 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.49500 * lines.width, y: lines.minY + 0.15003 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.49500 * lines.width, y: lines.minY + 0.00006 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.49500 * lines.width, y: lines.minY + 0.06134 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.49500 * lines.width, y: lines.minY + 0.00211 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.00000 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.49652 * lines.width, y: lines.minY + 0.00005 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.00000 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.00001 * lines.height))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: lines.minX + 0.08708 * lines.width, y: lines.minY + 0.07856 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.25682 * lines.width, y: lines.minY + 0.24829 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.08707 * lines.width, y: lines.minY + 0.07854 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.15721 * lines.width, y: lines.minY + 0.14868 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.24972 * lines.width, y: lines.minY + 0.25534 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.25442 * lines.width, y: lines.minY + 0.25060 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.25205 * lines.width, y: lines.minY + 0.25295 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.08000 * lines.width, y: lines.minY + 0.08561 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.15013 * lines.width, y: lines.minY + 0.15574 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.08000 * lines.width, y: lines.minY + 0.08561 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.08319 * lines.width, y: lines.minY + 0.08242 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.08000 * lines.width, y: lines.minY + 0.08561 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.08155 * lines.width, y: lines.minY + 0.08407 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.08707 * lines.width, y: lines.minY + 0.07854 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.08507 * lines.width, y: lines.minY + 0.08055 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.08707 * lines.width, y: lines.minY + 0.07854 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.08708 * lines.width, y: lines.minY + 0.07856 * lines.height))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: lines.minX + 0.91433 * lines.width, y: lines.minY + 0.07864 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.92146 * lines.width, y: lines.minY + 0.08561 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.91439 * lines.width, y: lines.minY + 0.07854 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.92146 * lines.width, y: lines.minY + 0.08561 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.75100 * lines.width, y: lines.minY + 0.25608 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.92146 * lines.width, y: lines.minY + 0.08561 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.85098 * lines.width, y: lines.minY + 0.15609 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.74393 * lines.width, y: lines.minY + 0.24900 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.74867 * lines.width, y: lines.minY + 0.25368 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.74632 * lines.width, y: lines.minY + 0.25133 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.91431 * lines.width, y: lines.minY + 0.07862 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.84195 * lines.width, y: lines.minY + 0.15098 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.91161 * lines.width, y: lines.minY + 0.08132 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.91433 * lines.width, y: lines.minY + 0.07864 * lines.height))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: lines.minX + 0.85000 * lines.width, y: lines.minY + 0.50000 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 1.00000 * lines.width, y: lines.minY + 0.50000 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.93384 * lines.width, y: lines.minY + 0.50000 * lines.height), controlPoint2: CGPoint(x: lines.minX + 1.00000 * lines.width, y: lines.minY + 0.50000 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 1.00000 * lines.width, y: lines.minY + 0.51000 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.84986 * lines.width, y: lines.minY + 0.51000 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.85000 * lines.width, y: lines.minY + 0.50000 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.84995 * lines.width, y: lines.minY + 0.50668 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.85000 * lines.width, y: lines.minY + 0.50334 * lines.height))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: lines.minX + 0.15014 * lines.width, y: lines.minY + 0.51000 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.00000 * lines.width, y: lines.minY + 0.51000 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.06650 * lines.width, y: lines.minY + 0.51000 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.00000 * lines.width, y: lines.minY + 0.51000 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.00000 * lines.width, y: lines.minY + 0.50000 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.15000 * lines.width, y: lines.minY + 0.50000 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.15014 * lines.width, y: lines.minY + 0.51000 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.15000 * lines.width, y: lines.minY + 0.50334 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.15005 * lines.width, y: lines.minY + 0.50668 * lines.height))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.99961 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.49500 * lines.width, y: lines.minY + 1.00000 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.49500 * lines.width, y: lines.minY + 0.84996 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.49500 * lines.width, y: lines.minY + 1.00000 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.49500 * lines.width, y: lines.minY + 0.94025 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.50000 * lines.width, y: lines.minY + 0.85000 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.84997 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 1.00000 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.94025 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 1.00000 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.50500 * lines.width, y: lines.minY + 0.99961 * lines.height))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: lines.minX + 0.92114 * lines.width, y: lines.minY + 0.91261 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.91439 * lines.width, y: lines.minY + 0.92000 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.92146 * lines.width, y: lines.minY + 0.91293 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.91439 * lines.width, y: lines.minY + 0.92000 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.74466 * lines.width, y: lines.minY + 0.75028 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.91439 * lines.width, y: lines.minY + 0.92000 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.84426 * lines.width, y: lines.minY + 0.84987 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.75171 * lines.width, y: lines.minY + 0.74319 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.74705 * lines.width, y: lines.minY + 0.74795 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.74940 * lines.width, y: lines.minY + 0.74558 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.92146 * lines.width, y: lines.minY + 0.91293 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.85132 * lines.width, y: lines.minY + 0.84279 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.92146 * lines.width, y: lines.minY + 0.91293 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.92114 * lines.width, y: lines.minY + 0.91261 * lines.height))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: lines.minX + 0.25607 * lines.width, y: lines.minY + 0.75100 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.25449 * lines.width, y: lines.minY + 0.75258 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.08707 * lines.width, y: lines.minY + 0.92000 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.15612 * lines.width, y: lines.minY + 0.85095 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.08707 * lines.width, y: lines.minY + 0.92000 * lines.height))
        bezierPath.addLine(to: CGPoint(x: lines.minX + 0.08000 * lines.width, y: lines.minY + 0.91293 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.24900 * lines.width, y: lines.minY + 0.74392 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.08000 * lines.width, y: lines.minY + 0.91293 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.14979 * lines.width, y: lines.minY + 0.84314 * lines.height))
        bezierPath.addCurve(to: CGPoint(x: lines.minX + 0.25607 * lines.width, y: lines.minY + 0.75100 * lines.height), controlPoint1: CGPoint(x: lines.minX + 0.25133 * lines.width, y: lines.minY + 0.74632 * lines.height), controlPoint2: CGPoint(x: lines.minX + 0.25368 * lines.width, y: lines.minY + 0.74867 * lines.height))
        bezierPath.close()
        lineColor.setFill()
        bezierPath.fill()
        
	
		//// TextGroup
		//// lastBlockText Drawing
		let lastBlockTextRect = CGRect(x: textGroup.minX + fastFloor(textGroup.width * 0.00000 + 0.5), y: textGroup.minY + fastFloor(textGroup.height * 0.58824 + 0.5), width: fastFloor(textGroup.width * 1.00000 + 0.5) - fastFloor(textGroup.width * 0.00000 + 0.5), height: fastFloor(textGroup.height * 1.00000 + 0.5) - fastFloor(textGroup.height * 0.58824 + 0.5))
		let lastBlockTextStyle = NSMutableParagraphStyle()
		lastBlockTextStyle.alignment = .center
		let lastBlockTextFontAttributes = [
			.font: UIFont(name: self.fontName, size: self.fontSize * 0.50)!,
			.foregroundColor: UIColor.lightGray,
			.paragraphStyle: lastBlockTextStyle,
			] as [NSAttributedStringKey: Any]

		lastBlockTextSt.draw(in: lastBlockTextRect, withAttributes: lastBlockTextFontAttributes)


		//// BlockProgressText Drawing
		let blockProgressTextRect = CGRect(x: textGroup.minX + fastFloor(textGroup.width * 0.00000 + 0.5), y: textGroup.minY + fastFloor(textGroup.height * 0.00000 + 0.5), width: fastFloor(textGroup.width * 1.00000 + 0.5) - fastFloor(textGroup.width * 0.00000 + 0.5), height: fastFloor(textGroup.height * 0.51471 + 0.5) - fastFloor(textGroup.height * 0.00000 + 0.5))
		let blockProgressTextStyle = NSMutableParagraphStyle()
		blockProgressTextStyle.alignment = .center
		let blockProgressTextFontAttributes = [
			.font: UIFont(name: self.fontName, size: self.fontSize)!,
			.foregroundColor: UIColor.white,
			.paragraphStyle: blockProgressTextStyle,
			] as [NSAttributedStringKey: Any]

		let blockProgressTextTextHeight: CGFloat = progressText.boundingRect(with: CGSize(width: blockProgressTextRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: blockProgressTextFontAttributes, context: nil).height
		context.saveGState()
		context.clip(to: blockProgressTextRect)
		lastBlockTimeSt.draw(in: CGRect(x: blockProgressTextRect.minX, y: blockProgressTextRect.minY + blockProgressTextRect.height - blockProgressTextTextHeight, width: blockProgressTextRect.width, height: blockProgressTextTextHeight), withAttributes: blockProgressTextFontAttributes)
		context.restoreGState()

    }
}
