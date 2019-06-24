//
//  OldestBlockRequest.swift
//  breadwallet
//
//  Created by YoshiCarlsberg on 15.04.18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import Foundation

struct AddressInfoJSON: Decodable {
    let addrStr: String
    let balance: Double
    let balanceSat: Int64
    let totalReceived: Double
    let totalReceivedSat: Int64
    let totalSent: Double
    let totalSentSat: Int64
    let unconfirmedBalance: Double
    let unconfirmedTxApperances: Int
    let transactions: [String]
}

struct TransactionJSON: Decodable {
    var txid: String
    var hash: String
    var version: Int
    var size: Int
    var blocktime: Int
    var blockhash: String
}

struct BlockJSON: Decodable {
    var hash: String
    var confirmations: Int
    var size: Int
    var height: Int
    var time: Int
    var previousblockhash: String
    var nextblockhash: String
}

class OldestBlockRequest {
    
    private struct Block {
        var hash: String
        var blockHeight: Int
        var blockTime: Int
    }
    
    static let multiAddressBaseURL = "https://digiexplorer.info/api/addrs" /*  /<addr1,addr2,...>/txs */
    static let txBaseURL = "https://digiexplorer.info/api/tx"
    static let blockBaseURL = "https://digiexplorer.info/api/block"
    private var oldestBlock: Block?
    let onCompletion: (Bool, String, Int, Int) -> Void // success, hash, blockHeight, blockTime
    let session: URLSession
    let addresses: [String]
    
    var completed = false
    var callbackCalled = false
    // var lock = DispatchSemaphore(value: 1)
    
    private func next(_ callback: @escaping () -> Void) {
        // lock.wait()
        self.session.getAllTasks(completionHandler: { (tasks) in
            if !self.callbackCalled && tasks.count == 0 {
                self.callbackCalled = true
                // self.lock.signal()
                callback()
            }
        })
    }
    
    private func fetchTransactions(_ callback: @escaping ([TransactionJSON]) -> Void) {
        callbackCalled = false
        var transactions: [TransactionJSON] = []
        
        if self.addresses.count == 0 {
            return finish()
        }
        
        let addressStr = self.addresses.joined(separator: ",")
        let url = "\(OldestBlockRequest.multiAddressBaseURL)/\(addressStr)/txs/"
        let dataTask = self.session.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            if let err = error {
                print("SYNC: ERROR", err);
                self.next { callback(transactions) }
                return;
            }
            
            guard let data = data else { return }
            do {
                let parsedJSON = try JSONDecoder().decode([TransactionJSON].self, from: data)
                
                for transaction in parsedJSON {
                    transactions.append(transaction)
                }
            } catch let jsonErr {
                print("SYNC: JSON ERROR", jsonErr);
            }
            
            self.next { callback(transactions) }
        })
        
        dataTask.resume()
    }
    
    private func finish() {
        if self.completed { return }
        completed = true
        
        if let b = oldestBlock {
            self.onCompletion(true, b.hash, b.blockHeight, b.blockTime)
        } else {
            self.onCompletion(false, "", 0, 0)
        }
    }
    
    private func getBlock(_ blockHash: String, callback: @escaping (BlockJSON?) -> Void) {
        let url = "\(OldestBlockRequest.blockBaseURL)/\(blockHash)"
        let dataTask = self.session.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            guard let data = data else { return }
            do {
                let json = try JSONDecoder().decode(BlockJSON.self, from: data)
                callback(json)
            } catch {
                print("Error deserializing JSON \(error):", String.init(bytes: data, encoding: .utf8) ?? "<<null>>")
                callback(nil)
            }
        })
        dataTask.resume()
    }
    
    func start() {
        // get the transactions for the public wallet addresses
        self.fetchTransactions { (transactions) in
            if transactions.count == 0 { return self.finish() }
            
            // get the oldest transaction
            guard let oldestTx = transactions.max(by: { (a, b) -> Bool in
                return a.blocktime > b.blocktime
            }) else { return self.finish() }
        
            // get the block data from the oldest transaction
            self.getBlock(oldestTx.blockhash, callback: { (block) in
                if let b = block {
                    self.getBlock(b.previousblockhash, callback: { (prevBlock) in
                        if let p = prevBlock {
                            self.oldestBlock = Block(hash: p.hash, blockHeight: p.height, blockTime: p.time)
                        }
                        self.finish()
                    })
                } else {
                    self.finish()
                }
            })
        }
    }
    
    init(_ addr: [String], completion: @escaping (Bool, String, Int, Int) -> Void) {
        onCompletion = completion
        
        // create session
        let cfg = URLSessionConfiguration.default
        cfg.httpMaximumConnectionsPerHost = 3
        session = URLSession(configuration: cfg)
        self.addresses = addr
    }
}
