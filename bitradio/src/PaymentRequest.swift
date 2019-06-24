//
//  PaymentRequest.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-03-26.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import Foundation
import BRCore

enum PaymentRequestType {
    case local
    case remote
}

struct PaymentRequest {

    init?(string: String) {
        if let trimmedUrl = NSURL(string: string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).replacingOccurrences(of: "://", with: ":").replacingOccurrences(of: " ", with: "%20")) {

            if let scheme = trimmedUrl.scheme, let resourceSpecifier = trimmedUrl.resourceSpecifier, trimmedUrl.host == nil,
                let url = NSURL(string: "\(scheme)://\(resourceSpecifier)") {

                if url.scheme == "bitradio", let host = url.host {
                    toAddress = host
                    guard let components = url.query?.components(separatedBy: "&") else { type = .local; return }
                    for component in components {
                        let pair = component.components(separatedBy: "=")
                        if pair.count < 2 { continue }
                        let key = pair[0]
                        var value = String(component[component.index(key.endIndex, offsetBy: 1)...])
                        value = (value.replacingOccurrences(of: "+", with: " ") as NSString).removingPercentEncoding!

                        switch key {
                        case "amount":
                            amount = Satoshis(btcString: value)
                        case "label":
                            label = value
                        case "message":
                            message = value
                        case "r":
                            r = URL(string: value)
                        default:
                            print("Key not found: \(key)")
                        }
                    }
                    type = r == nil ? .local : .remote
                    return
                }
            } else if trimmedUrl.scheme == "http" || trimmedUrl.scheme == "https" {
                type = .remote
                remoteRequest = trimmedUrl
                return
            }
        }

        if string.isValidAddress {
            toAddress = string
            type = .local
            return
        }

        return nil
    }

    init?(data: Data) {
        self.paymentProtoclRequest = PaymentProtocolRequest(data: data)
        type = .local
    }

    func fetchRemoteRequest(completion: @escaping (PaymentRequest?) -> Void) {

        let request: NSMutableURLRequest
        if let url = r {
            request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5.0)
        } else {
            request = NSMutableURLRequest(url: remoteRequest! as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5.0) //TODO - fix !
        }

        request.setValue("application/bitradio-paymentrequest", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else { return completion(nil) }
            guard let data = data else { return completion(nil) }
            guard let response = response else { return completion(nil) }

            if response.mimeType?.lowercased() == "application/bitradio-paymentrequest" {
                completion(PaymentRequest(data: data))
            } else if response.mimeType?.lowercased() == "text/uri-list" {
                for line in (String(data: data, encoding: .utf8)?.components(separatedBy: "\n"))! {
                    if line.hasPrefix("#") { continue }
                    completion(PaymentRequest(string: line))
                    break
                }
                completion(nil)
            } else {
                completion(nil)
            }
        }.resume()
    }

    static func requestString(withAddress: String, forAmount: UInt64) -> String {
        let btcAmount = convertToBTC(fromSatoshis: forAmount)
        return "bitradio://\(withAddress)?amount=\(btcAmount)"
    }

    static func requestString(withAddress: String) -> String {
        return "bitradio://\(withAddress)"
    }

    var toAddress: String?
    let type: PaymentRequestType
    var amount: Satoshis?
    var label: String?
    var message: String?
    var remoteRequest: NSURL?
    var paymentProtoclRequest: PaymentProtocolRequest?
    var r: URL?
}

private func convertToBTC(fromSatoshis: UInt64) -> String {
    var decimal = Decimal(fromSatoshis)
    var amount: Decimal = 0.0
    NSDecimalMultiplyByPowerOf10(&amount, &decimal, -8, .up)
    return NSDecimalNumber(decimal: amount).stringValue
}
