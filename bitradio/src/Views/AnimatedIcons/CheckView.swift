//
//  CheckView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-22.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

class CheckView : UIView, AnimatableIcon {

    init(_ size: Double) {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        
        let image = UIImageView(image: #imageLiteral(resourceName: "check"))
        image.contentMode = .scaleAspectFit
        self.addSubview(image)
        
        image.constrain([
            image.topAnchor.constraint(equalTo: self.topAnchor),
            image.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            image.leftAnchor.constraint(equalTo: self.leftAnchor),
            image.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func animate() {
        let check = UIBezierPath()
        
        // viewBox="0 0 100 116
        // M38 48.969l2.182-2.125 4.909 3.187s5.468-6.06 15.818-9.031L62 43.125S50.566 47.92 45.09 58L38 48.969z
        // professorcloud.com/svg-to-canvas output:
        /*
        var draw = function(ctx) {
            ctx.save();
            ctx.beginPath();
            ctx.moveTo(0,0);
            ctx.lineTo(100,0);
            ctx.lineTo(100,116);
            ctx.lineTo(0,116);
            ctx.closePath();
            ctx.clip();
            ctx.translate(0,0);
            ctx.translate(0,0);
            ctx.scale(1,1);
            ctx.translate(0,0);
            ctx.strokeStyle = 'rgba(0,0,0,0)';
            ctx.lineCap = 'butt';
            ctx.lineJoin = 'miter';
            ctx.miterLimit = 4;
            ctx.save();
            ctx.fillStyle = "rgba(0, 0, 0, 0)";
            ctx.save();
            ctx.fillStyle = "#ffffff";
         
            ctx.beginPath();
            ctx.moveTo(38, 48.969);
            ctx.lineTo(40.182, 46.844);
            ctx.lineTo(45.091, 50.031);
            ctx.bezierCurveTo(45.091, 50.031, 50.559, 43.971, 60.909, 41);
            ctx.lineTo(62, 43.125);
            ctx.bezierCurveTo(62, 43.125, 50.566, 47.92, 45.09, 58);
            ctx.lineTo(38, 48.969);
            ctx.closePath();
            ctx.fill();
         
            ctx.stroke();
            ctx.restore();
            ctx.restore();
            ctx.restore();
        };
        */
        let scaleX = self.frame.width / 100
        let scaleY = self.frame.height / 116
        
        check.move(to: CGPoint(x: 38 * scaleX, y: 48.969 * scaleY))
        check.addLine(to: CGPoint(x: 40.182 * scaleX, y: 46.844 * scaleY))
        check.addLine(to: CGPoint(x: 45.091 * scaleX, y: 50.031 * scaleY))
        check.addCurve(
            to: CGPoint(x: 60.909 * scaleX, y: 41 * scaleY),
            controlPoint1: CGPoint(x: 45.091 * scaleX, y: 50.031 * scaleY),
            controlPoint2: CGPoint(x: 50.559 * scaleX, y: 43.971 * scaleX)
        )
        check.addLine(to: CGPoint(x: 62 * scaleX, y: 43.125 * scaleY))
        check.addCurve(
            to: CGPoint(x: 45.09 * scaleX, y: 58 * scaleY),
            controlPoint1: CGPoint(x: 62 * scaleX, y: 43.125 * scaleY),
            controlPoint2: CGPoint(x: 50.566 * scaleX, y: 47.92 * scaleX)
        )
        check.addLine(to: CGPoint(x: 38 * scaleX, y: 48.969 * scaleY))
        check.close()
        
        let shape = CAShapeLayer()
        shape.path = check.cgPath
        shape.lineWidth = 1.0
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.white.cgColor
        shape.strokeStart = 0.0
        shape.strokeEnd = 0.0
        shape.lineCap = kCALineCapButt
        shape.lineJoin = kCALineCapRound
        layer.addSublayer(shape)

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.duration = 0.6

        shape.add(animation, forKey: nil)
    }

    override func draw(_ rect: CGRect) {
/*
        let checkcircle = UIBezierPath()
        checkcircle.move(to: CGPoint(x: 47.76, y: -0))
        checkcircle.addCurve(to: CGPoint(x: 0, y: 47.76), controlPoint1: CGPoint(x: 21.38, y: -0), controlPoint2: CGPoint(x: 0, y: 21.38))
        checkcircle.addCurve(to: CGPoint(x: 47.76, y: 95.52), controlPoint1: CGPoint(x: 0, y: 74.13), controlPoint2: CGPoint(x: 21.38, y: 95.52))
        checkcircle.addCurve(to: CGPoint(x: 95.52, y: 47.76), controlPoint1: CGPoint(x: 74.14, y: 95.52), controlPoint2: CGPoint(x: 95.52, y: 74.13))
        checkcircle.addCurve(to: CGPoint(x: 47.76, y: -0), controlPoint1: CGPoint(x: 95.52, y: 21.38), controlPoint2: CGPoint(x: 74.14, y: -0))
        checkcircle.addLine(to: CGPoint(x: 47.76, y: -0))
        checkcircle.close()
        checkcircle.move(to: CGPoint(x: 47.99, y: 85.97))
        checkcircle.addCurve(to: CGPoint(x: 9.79, y: 47.76), controlPoint1: CGPoint(x: 26.89, y: 85.97), controlPoint2: CGPoint(x: 9.79, y: 68.86))
        checkcircle.addCurve(to: CGPoint(x: 47.99, y: 9.55), controlPoint1: CGPoint(x: 9.79, y: 26.66), controlPoint2: CGPoint(x: 26.89, y: 9.55))
        checkcircle.addCurve(to: CGPoint(x: 86.2, y: 47.76), controlPoint1: CGPoint(x: 69.1, y: 9.55), controlPoint2: CGPoint(x: 86.2, y: 26.66))
        checkcircle.addCurve(to: CGPoint(x: 47.99, y: 85.97), controlPoint1: CGPoint(x: 86.2, y: 68.86), controlPoint2: CGPoint(x: 69.1, y: 85.97))
        checkcircle.close()

        UIColor.white.setFill()
        checkcircle.fill()
*/
        //This is the non-animated check left here for now as a reference
//        let check = UIBezierPath()
//        check.move(to: CGPoint(x: 30.06, y: 51.34))
//        check.addCurve(to: CGPoint(x: 30.06, y: 44.75), controlPoint1: CGPoint(x: 28.19, y: 49.52), controlPoint2: CGPoint(x: 28.19, y: 46.57))
//        check.addCurve(to: CGPoint(x: 36.9, y: 44.69), controlPoint1: CGPoint(x: 32, y: 42.87), controlPoint2: CGPoint(x: 35.03, y: 42.87))
//        check.addLine(to: CGPoint(x: 42.67, y: 50.3))
//        check.addLine(to: CGPoint(x: 58.62, y: 34.79))
//        check.addCurve(to: CGPoint(x: 65.39, y: 34.8), controlPoint1: CGPoint(x: 60.49, y: 32.98), controlPoint2: CGPoint(x: 63.53, y: 32.98))
//        check.addCurve(to: CGPoint(x: 65.46, y: 41.45), controlPoint1: CGPoint(x: 67.33, y: 36.68), controlPoint2: CGPoint(x: 67.33, y: 39.63))
//        check.addLine(to: CGPoint(x: 45.33, y: 61.02))
//        check.addCurve(to: CGPoint(x: 40.01, y: 61.02), controlPoint1: CGPoint(x: 43.86, y: 62.44), controlPoint2: CGPoint(x: 41.48, y: 62.44))
//        check.addLine(to: CGPoint(x: 30.06, y: 51.34))
//        check.close()
//        check.move(to: CGPoint(x: 30.06, y: 51.34))
//
//        UIColor.green.setFill()
//        check.fill()
    }
}
