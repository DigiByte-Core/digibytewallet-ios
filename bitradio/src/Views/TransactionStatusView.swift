//
//  TransactionStatusView.swift
//  bitradio
//
//  Created by Yoshi Jäger on 04.08.18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit

class TransactionStatusView: UILabel {
    enum Status {
        case unknown
        case invalid
        case progress
        case complete
    }
    
    override var text: String? {
        didSet {
            super.text = text?.uppercased()
            
        }
    }
    
    var status: Status {
        didSet {
            setBackgroundColor(status: status)
        }
    }
    
    init(font: UIFont, color: UIColor, status: Status) {
        self.status = status
        super.init(frame: CGRect())
        
        self.font = font
        self.textColor = color
        
        setBackgroundColor(status: status)
        setStyle()
    }
    
    private func setStyle() {
        layer.cornerRadius = 3
        textColor = C.Colors.text
        layer.masksToBounds = true
        textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setBackgroundColor(status: Status) {
        switch status {
        case .unknown:
            backgroundColor = UIColor.gray
        case .progress:
            backgroundColor = UIColor.orange
        case .invalid:
            backgroundColor = C.Colors.weirdRed
        case .complete:
            backgroundColor = C.Colors.weirdGreen
        }
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 20, height: size.height + 20)
    }
}
