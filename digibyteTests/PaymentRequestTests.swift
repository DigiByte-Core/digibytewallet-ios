//
//  PaymentRequestTests.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-03-26.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import XCTest
@testable import DigiByte

class PaymentRequestTests : XCTestCase {
    private let legacyAddress = "D597kHXGdkwkryF9oGhz9Bp1ypTpD1u99Z"
    private let segwitAddress = "dgb1qqqqsyqcyq5rqwzqfpg9scrgwpugpzysnzhtfd6"
    private let taprootAddress = "dgb1pqqqsyqcyq5rqwzqfpg9scrgwpugpzysnzs23v9ccrydpk8qarc0s470eva"
    private let invalidTaprootChecksum = "dgb1pqqqsyqcyq5rqwzqfpg9scrgwpugpzysnzs23v9ccrydpk8qarc0s470evq"

    func testEmptyString() {
        XCTAssertNil(PaymentRequest(string: ""))
    }

    func testInvalidAddress() {
        XCTAssertNil(PaymentRequest(string: "notandaddress"), "Payment request should be nil for invalid addresses")
    }

    func testBasicExample() {
        let uri = "digibyte:\(legacyAddress)"
        let request = PaymentRequest(string: uri)
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.toAddress == legacyAddress)
    }

    func testAmountInUri() {
        let uri = "digibyte:\(legacyAddress)?amount=1.2"
        let request = PaymentRequest(string: uri)
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.toAddress == legacyAddress)
        XCTAssertTrue(request?.amount?.rawValue == 120000000)
    }

    func testRequestMetaData() {
        let uri = "digibyte:\(legacyAddress)?amount=1.2&message=Payment&label=Satoshi"
        let request = PaymentRequest(string: uri)
        XCTAssertTrue(request?.toAddress == legacyAddress)
        XCTAssertTrue(request?.amount?.rawValue == 120000000)
        XCTAssertTrue(request?.message == "Payment")
        XCTAssertTrue(request?.label == "Satoshi")
    }

    func testExtraEqualSign() {
        let uri = "digibyte:\(legacyAddress)?amount=1.2&message=Payment=true&label=Satoshi"
        let request = PaymentRequest(string: uri)
        XCTAssertTrue(request?.message == "Payment=true")
    }

    func testMessageWithSpace() {
        let uri = "digibyte:\(legacyAddress)?amount=1.2&message=Payment message test&label=Satoshi"
        let request = PaymentRequest(string: uri)
        XCTAssertTrue(request?.message == "Payment message test")
    }

    func testTaprootAddressIsValid() {
        XCTAssertTrue(taprootAddress.isValidAddress)
    }

    func testTaprootPaymentRequest() {
        let request = PaymentRequest(string: "digibyte:\(taprootAddress)?amount=2.5")
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.toAddress, taprootAddress)
        XCTAssertEqual(request?.amount?.rawValue, 250000000)
    }

    func testTaprootInvalidChecksumRejected() {
        XCTAssertFalse(invalidTaprootChecksum.isValidAddress)
        XCTAssertNil(PaymentRequest(string: invalidTaprootChecksum))
        XCTAssertNil(PaymentRequest(string: "digibyte:\(invalidTaprootChecksum)"))
    }

    func testLegacyAndSegwitStillValid() {
        XCTAssertTrue(legacyAddress.isValidAddress)
        XCTAssertTrue(segwitAddress.isValidAddress)
    }

    func testPaymentProtocol() {
        let uri = "https://www.syndicoin.co/signednoroot.paymentrequest"
        let request = PaymentRequest(string: uri)
        XCTAssertTrue(request?.type == .remote)

        let promise = expectation(description: "Fetch Request")
        request?.fetchRemoteRequest(completion: { newRequest in
            XCTAssertNotNil(newRequest)
            promise.fulfill()
        })

        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error)
        }
    }
}
