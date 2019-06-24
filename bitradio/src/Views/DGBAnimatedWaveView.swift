//
//  DGBAnimatedWaveView.swift
//  bitradio
//
//  Created by Thomas Ploentzke on 14.06.18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit

class DGBAnimatedWaveView: UIView {
	private let waveColor: UIColor
	private var rotate:CGFloat = 0
	private var rotateSpeed:CGFloat = 0.15

	init(color: UIColor, background: UIColor) {
		waveColor = color
		super.init(frame: CGRect())
		backgroundColor = background
	}

	func startAnimation() {

	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func draw(_ rect: CGRect) {

		let context = UIGraphicsGetCurrentContext()!

		context.saveGState()
		context.translateBy(x: self.frame.width/2.0, y: 968.48)
		context.rotate(by: self.rotate * CGFloat.pi/180)

		let ovalPath = UIBezierPath()
		ovalPath.move(to: CGPoint(x: 465.86, y: -771.2))
		ovalPath.addCurve(to: CGPoint(x: 700.15, y: -581.4), controlPoint1: CGPoint(x: 498.96, y: -722.58), controlPoint2: CGPoint(x: 639.79, y: -649.99))
		ovalPath.addCurve(to: CGPoint(x: 924.08, y: 8.56), controlPoint1: CGPoint(x: 839.75, y: -422.77), controlPoint2: CGPoint(x: 860.41, y: -68.35))
		ovalPath.addCurve(to: CGPoint(x: 585.4, y: 612.14), controlPoint1: CGPoint(x: 991.44, y: 89.94), controlPoint2: CGPoint(x: 553.14, y: 476.92))
		ovalPath.addCurve(to: CGPoint(x: -8.1, y: 915.9), controlPoint1: CGPoint(x: 587.05, y: 718.39), controlPoint2: CGPoint(x: 209.3, y: 915.9))
		ovalPath.addCurve(to: CGPoint(x: -315.59, y: 823.05), controlPoint1: CGPoint(x: -120.47, y: 915.9), controlPoint2: CGPoint(x: -241, y: 855.54))
		ovalPath.addCurve(to: CGPoint(x: -666.09, y: 493.52), controlPoint1: CGPoint(x: -613.96, y: 693.09), controlPoint2: CGPoint(x: -565.86, y: 690.14))
		ovalPath.addCurve(to: CGPoint(x: -940.27, y: 8.56), controlPoint1: CGPoint(x: -742.24, y: 344.15), controlPoint2: CGPoint(x: -940.27, y: 177.68))
		ovalPath.addCurve(to: CGPoint(x: -742.05, y: -550.88), controlPoint1: CGPoint(x: -940.27, y: -202.51), controlPoint2: CGPoint(x: -866.23, y: -396.74))
		ovalPath.addCurve(to: CGPoint(x: -440.73, y: -812.23), controlPoint1: CGPoint(x: -660.89, y: -651.62), controlPoint2: CGPoint(x: -511.25, y: -823.27))
		ovalPath.addCurve(to: CGPoint(x: -8.1, y: -898.78), controlPoint1: CGPoint(x: -362.22, y: -799.93), controlPoint2: CGPoint(x: -164.35, y: -898.78))
		ovalPath.addCurve(to: CGPoint(x: 465.86, y: -771.2), controlPoint1: CGPoint(x: 175.25, y: -898.78), controlPoint2: CGPoint(x: 356.3, y: -932.15))
		ovalPath.close()
		waveColor.setFill()
		ovalPath.fill()

		context.restoreGState()

		self.rotate = self.rotate + self.rotateSpeed;
	}
}
