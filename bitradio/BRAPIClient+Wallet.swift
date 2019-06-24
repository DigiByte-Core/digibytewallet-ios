//
//  BRAPIClient+Wallet.swift
//  breadwallet
//
//  Created by Samuel Sutch on 4/2/17.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import Foundation

private let feeURL = "https://go.bitrad.io/bws/api/v2/feelevels/"
private let ratesURL = "https://bitrad.io/rates.php"
private let fallbackRatesURL = "http://pettys.website/rates.php"

extension BRAPIClient {
    func feePerKb(_ handler: @escaping (_ fees: Fees, _ error: String?) -> Void) {
		//FIXME: We are hard coding fee levels to boost sync performance temporarily, We should not be calling this everytime we make a call to get blocks.  We should find a way to improve this.
		let req = URLRequest(url: URL(string: feeURL)!)
        let task = self.dataTaskWithRequest(req) { (data, response, err) -> Void in
            var regularFeePerKb: uint_fast64_t = 80000
            var economyFeePerKb: uint_fast64_t = 50000
            var errStr: String? = nil
            if err == nil {
                do {
                    let parsedObject: Any? = try JSONSerialization.jsonObject(
                        with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
					if let top = parsedObject as? NSArray,
                    let regularDictionary = top.object(at: 2) as? NSDictionary, let economyDictionary = top.object(at: 3) as? NSDictionary {
						if let regular = regularDictionary["feePerKb"] as? NSNumber, let economy = economyDictionary["feePerKb"] as? NSNumber {
							regularFeePerKb = regular.uint64Value
							economyFeePerKb = economy.uint64Value
						}
                    }
                } catch (let e) {
                    self.log("fee-per-kb: error parsing json \(e)")
                }
                if regularFeePerKb == 0 || economyFeePerKb == 0 {
                    errStr = "invalid json"
                }
            } else {
                self.log("fee-per-kb network error: \(String(describing: err))")
                errStr = "bad network connection"
            }
            handler(Fees(regular: regularFeePerKb, economy: economyFeePerKb), errStr)
        }
        task.resume()
    }
    
    private func cache(_ data: Data, name: String) {
        do {
            let filename = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name)
            try data.write(to: filename)
        } catch {
            print("[BRAPIClient::cache]", error)
        }
    }
    
    private func loadFromCache(_ name: String) -> Data? {
        do {
            let filename = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name)
            let data = FileManager.default.contents(atPath: filename.path)
            
            if data == nil {
                // Emergency currency conversion fallback
                return Data(base64Encoded: EMERGENCY_RATES)!
            }
            
            return data
        } catch {
            print("[BRAPIClient::loadFromCache]", error)
            return nil
        }
    }
    
    func exchangeRates(isFallback: Bool = false, _ handler: @escaping (_ rates: [Rate], _ error: String?) -> Void) {
        let request = isFallback ? URLRequest(url: URL(string: fallbackRatesURL)!) : URLRequest(url: URL(string: ratesURL)!)
        let task = dataTaskWithRequest(request) { (data, response, error) in
            var dataRAW: Data? = data
            
            if error != nil {
                // if data from response is nil,
                // we try to load the recent valid version of rates that we have cached.
                dataRAW = self.loadFromCache("rates.json")
            }
            
            if let data = dataRAW,
               let parsedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                self.cache(data, name: "rates.json")
                
                if isFallback {
                    guard let array = parsedData as? [Any] else {
                        return handler([], "/rates didn't return an array")
                    }
                    handler(array.flatMap { Rate(data: $0) }, nil)
                } else {
                    guard let array = parsedData as? [Any] else {
                         return handler([], "/rates didn't return an array")
                    }
                    handler(array.flatMap { Rate(data: $0) }, nil)
                }
            } else {
                if isFallback {
                    handler([], "Error fetching from fallback url")
                } else {
                    self.exchangeRates(isFallback: true, handler)
                }
            }
        }
        task.resume()
    }
    
    func savePushNotificationToken(_ token: Data) {
        var req = URLRequest(url: url("/me/push-devices"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let reqJson = [
            "token": token.hexString,
            "service": "apns",
            "data": [   "e": pushNotificationEnvironment(),
                        "b": Bundle.main.bundleIdentifier!]
            ] as [String : Any]
        do {
            let dat = try JSONSerialization.data(withJSONObject: reqJson, options: .prettyPrinted)
            req.httpBody = dat
        } catch (let e) {
            log("JSON Serialization error \(e)")
            return
        }
        dataTaskWithRequest(req as URLRequest, authenticated: true, retryCount: 0) { (dat, resp, er) in
            let dat2 = String(data: dat ?? Data(), encoding: .utf8)
            self.log("save push token resp: \(String(describing: resp)) data: \(String(describing: dat2))")
        }.resume()
    }

    func deletePushNotificationToken(_ token: Data) {
        var req = URLRequest(url: url("/me/push-devices/apns/\(token.hexString)"))
        req.httpMethod = "DELETE"
        dataTaskWithRequest(req as URLRequest, authenticated: true, retryCount: 0) { (dat, resp, er) in
            self.log("delete push token resp: \(String(describing: resp))")
            if let statusCode = resp?.statusCode {
                if statusCode >= 200 && statusCode < 300 {
                    UserDefaults.pushToken = nil
                    self.log("deleted old token")
                }
            }
        }.resume()
    }

    func publishBCashTransaction(_ txData: Data, callback: @escaping (String?) -> Void) {
        var req = URLRequest(url: url("/bch/publish-transaction"))
        req.httpMethod = "POST"
        req.setValue("application/bcashdata", forHTTPHeaderField: "Content-Type")
        req.httpBody = txData
        dataTaskWithRequest(req as URLRequest, authenticated: true, retryCount: 0) { (dat, resp, er) in
            if let statusCode = resp?.statusCode {
                if statusCode >= 200 && statusCode < 300 {
                    callback(nil)
                } else if let data = dat, let errorString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    callback(errorString as String)
                } else {
                    callback("\(statusCode)")
                }
            }
        }.resume()
    }
}

private func pushNotificationEnvironment() -> String {
    return E.isDebug ? "d" : "p" //development or production
}
