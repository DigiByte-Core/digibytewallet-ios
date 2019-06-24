//
//  TransactionTableViewCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

enum TransactionCellStyle {
    case first
    case middle
    case last
    case single
}

private let timestampRefreshRate: TimeInterval = 10.0

class TransactionTableViewCell : UITableViewCell, Subscriber {

    private class TransactionTableViewCellWrapper {
        weak var target: TransactionTableViewCell?
        init(target: TransactionTableViewCell) {
            self.target = target
        }

        @objc func timerDidFire() {
            target?.updateTimestamp()
        }
    }

    //MARK: - Public
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    deinit {
        timer?.invalidate()
    }

    func setStyle(_ style: TransactionCellStyle) {
        container.style = style
        shadowView.style = style
        if style == .last || style == .single {
            innerShadow.isHidden = true
        } else {
            innerShadow.isHidden = false
        }
    }

    func setTransaction(_ transaction: Transaction, isBtcSwapped: Bool, rate: Rate, maxDigits: Int, isSyncing: Bool) {
        self.transaction = transaction
        //transactionLabel.attributedText = transaction.descriptionString(isBtcSwapped: isBtcSwapped, rate: rate, maxDigits: maxDigits)
        transactionLabel.text = transaction.amountDescription(isBtcSwapped: isBtcSwapped, rate: rate, maxDigits: maxDigits)
        address.text = String(format: transaction.direction.addressTextFormat, transaction.toAddress ?? "")
        status.text = transaction.status
        comment.text = transaction.comment
        availability.text = transaction.shouldDisplayAvailableToSpend ? S.Transaction.available : ""

        if transaction.status == S.Transaction.complete {
            status.isHidden = false
        } else {
            status.isHidden = isSyncing
        }

        let timestampInfo = transaction.timeSince
        timestamp.text = timestampInfo.0
        if timestampInfo.1 {
            timer = Timer.scheduledTimer(timeInterval: timestampRefreshRate, target: TransactionTableViewCellWrapper(target: self), selector: NSSelectorFromString("timerDidFire"), userInfo: nil, repeats: true)
        } else {
            timer?.invalidate()
        }
        timestamp.isHidden = !transaction.isValid

        if transaction.direction == .received {
            arrow.image = receivedImage
            transactionLabel.textColor = C.Colors.weirdGreen
        } else {
            arrow.image = sentImage
            transactionLabel.textColor = C.Colors.weirdRed
        }
    }

    let container = RoundedContainer()

    //MARK: - Private
    private let transactionLabel = UILabel(font: UIFont.customBody(size: 13.0))
    private let address = UILabel(font: UIFont.customBody(size: 13.0), color: C.Colors.text)
    private let status = UILabel(font: UIFont.customBody(size: 13.0), color: C.Colors.text)
    private let comment = UILabel.wrapping(font: UIFont.customBody(size: 13.0), color: C.Colors.text)
    private let timestamp = UILabel(font: UIFont.customMedium(size: 13.0), color: C.Colors.text)
    private let shadowView = MaskedShadow()
    private let innerShadow = UIView()
    private let topPadding: CGFloat = 19.0
    private var style: TransactionCellStyle = .first
    private var transaction: Transaction?
    private let availability = UILabel(font: .customBold(size: 13.0), color: .txListGreen)
    private var timer: Timer? = nil
    private let receivedImage = #imageLiteral(resourceName: "receivedTransaction")
    private let sentImage = #imageLiteral(resourceName: "sentTransaction")
    private let arrow = UIImageView(image: #imageLiteral(resourceName: "receivedTransaction"))
    private let bgView: UIImageView = {
        let img = UIImageView(image: #imageLiteral(resourceName: "cardBg"))
        img.contentMode = .scaleAspectFit
        return img
    }()

    private func setupViews() {
        addSubviews()
        addConstraints()
        setupStyle()
    }

    private func addSubviews() {
        contentView.addSubview(bgView)
        //contentView.addSubview(shadowView)
        contentView.addSubview(container)
        //container.addSubview(innerShadow)
        container.addSubview(transactionLabel)
        container.addSubview(arrow)
        // container.addSubview(address)
        // container.addSubview(status)
        // container.addSubview(comment)
        container.addSubview(timestamp)
        // container.addSubview(availability)
    }

    private func addConstraints() {
        let scale = UIScreen.main.bounds.width / #imageLiteral(resourceName: "cardBg").size.width
        
        bgView.constrain([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            bgView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bgView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            bgView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            bgView.heightAnchor.constraint(equalToConstant: scale * #imageLiteral(resourceName: "cardBg").size.height)
        ])
        
        // bgView.contentMode = .scaleAspectFit
        
        container.constrain(toSuperviewEdges: UIEdgeInsets(top: 0, left: 52 / scale, bottom: 0, right: -52 / scale))

        arrow.constrain([
            arrow.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 12.0),
            arrow.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrow.heightAnchor.constraint(equalToConstant: 26.0),
            arrow.widthAnchor.constraint(equalToConstant: 26.0)
        ])
        
        transactionLabel.constrain([
            transactionLabel.leftAnchor.constraint(equalTo: arrow.rightAnchor, constant: 10),
            transactionLabel.constraint(.centerY, toView: arrow),
            transactionLabel.rightAnchor.constraint(lessThanOrEqualTo: timestamp.leftAnchor, constant: -C.padding[1])
        ])
        
        timestamp.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        timestamp.constrain([
            timestamp.constraint(.right, toView: container, constant: -16),
            timestamp.constraint(.centerY, toView: arrow),
        ])

        /*
        address.constrain([
            address.leadingAnchor.constraint(equalTo: transactionLabel.leadingAnchor),
            address.topAnchor.constraint(equalTo: transactionLabel.bottomAnchor),
            address.trailingAnchor.constraint(lessThanOrEqualTo: timestamp.leadingAnchor, constant: -C.padding[4])])
        address.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal) */
        /* comment.constrain([
            comment.constraint(.leading, toView: container, constant: C.padding[2]),
            comment.constraint(toBottom: address, constant: C.padding[1]),
            comment.trailingAnchor.constraint(lessThanOrEqualTo: timestamp.leadingAnchor, constant: -C.padding[1]) ]) */
        /*
        status.constrain([
            status.constraint(.leading, toView: container, constant: C.padding[2]),
            status.constraint(toBottom: comment, constant: C.padding[1]),
            status.constraint(.trailing, toView: container, constant: -C.padding[2]) ]) */
        /*
        availability.constrain([
            availability.leadingAnchor.constraint(equalTo: status.leadingAnchor),
            availability.topAnchor.constraint(equalTo: status.bottomAnchor),
            availability.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -C.padding[2]) ]) */
    }

    private func setupStyle() {
        backgroundColor = .clear

        comment.textColor = .darkText
        status.textColor = .darkText
        timestamp.textColor = .grayTextTint

        shadowView.backgroundColor = .clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 4.0
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)

        innerShadow.backgroundColor = .secondaryShadow

        transactionLabel.numberOfLines = 0
        transactionLabel.lineBreakMode = .byWordWrapping

        address.lineBreakMode = .byTruncatingMiddle
        address.numberOfLines = 1
        
        transactionLabel.textColor = C.Colors.weirdGreen
    }

    func updateTimestamp() {
        guard let tx = transaction else { return }
        let timestampInfo = tx.timeSince
        timestamp.text = timestampInfo.0
        if !timestampInfo.1 {
            timer?.invalidate()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //intentional noop for now
        //The default selected state doesn't play nicely
        //with this custom cell
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard selectionStyle != .none else { container.backgroundColor = .clear; return }
        //container.backgroundColor = .clear ? .secondaryShadow : .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
