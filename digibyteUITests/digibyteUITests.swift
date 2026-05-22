//
//  breadwalletUITests.swift
//  breadwalletUITests
//
//  Created by ajv on 10/5/16.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import XCTest

class breadwalletUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testCreateWalletOrLoginSmoke() {
        if isRecoveryKeyScreenVisible(timeout: 3) {
            return
        }

        if app.staticTexts["Welcome to the DigiByte wallet."].waitForExistence(timeout: 8) {
            advanceWelcomeFlow()
        }

        if tapButton(titles: ["CREATE NEW WALLET", "Create New Wallet"], timeout: 8) {
            createWallet(pin: "111111")
        } else if app.staticTexts["Enter PIN"].waitForExistence(timeout: 3) ||
                    app.staticTexts["Security Check"].exists ||
                    app.staticTexts["SECURITY CHECK"].exists {
            enterPin("111111")
            XCTAssert(waitForAnyText(["DigiByte", "ALL", "SENT", "RECEIVED", "Personal Recovery Key", "Write Down Personal Recovery Key"], timeout: 15), app.debugDescription)
        } else {
            XCTFail("App did not reach welcome, wallet creation, or PIN login flow.\n\(app.debugDescription)")
        }
    }

    private func advanceWelcomeFlow() {
        for _ in 0..<5 {
            app.swipeLeft()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.4))
        }
    }

    private func createWallet(pin: String) {
        XCTAssert(waitForAnyText(["Set PIN", "SET PIN"], timeout: 8), app.debugDescription)
        enterPin(pin)
        XCTAssert(waitForAnyText(["Re-Enter PIN", "RE-ENTER PIN"], timeout: 8), app.debugDescription)
        enterPin(pin)
        XCTAssert(isRecoveryKeyScreenVisible(timeout: 30), app.debugDescription)
    }

    private func enterPin(_ pin: String) {
        for digit in pin.map(String.init) {
            tapPinDigit(digit)
        }
    }

    private func tapPinDigit(_ digit: String) {
        let key = app.descendants(matching: .any)["pin-\(digit)"].firstMatch
        if key.waitForExistence(timeout: 2) {
            key.tap()
            return
        }

        let staticText = app.staticTexts[digit].firstMatch
        if staticText.waitForExistence(timeout: 1) {
            staticText.tap()
            return
        }

        let cell = app.collectionViews.cells[digit].firstMatch
        if cell.waitForExistence(timeout: 1) {
            cell.tap()
            return
        }

        XCTFail("Could not find PIN digit \(digit).\n\(app.debugDescription)")
    }

    @discardableResult
    private func tapButton(titles: [String], timeout: TimeInterval) -> Bool {
        let deadline = Date(timeIntervalSinceNow: timeout)
        while Date() < deadline {
            for title in titles {
                let button = app.buttons[title].firstMatch
                if button.exists {
                    button.tap()
                    return true
                }
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
        }
        return false
    }

    private func waitForAnyText(_ labels: [String], timeout: TimeInterval) -> Bool {
        let deadline = Date(timeIntervalSinceNow: timeout)
        while Date() < deadline {
            for label in labels {
                if app.staticTexts[label].exists || app.navigationBars[label].exists || app.buttons[label].exists {
                    return true
                }

                let containsLabel = NSPredicate(format: "label CONTAINS %@", label)
                if app.descendants(matching: .any).matching(containsLabel).firstMatch.exists {
                    return true
                }
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
        }
        return false
    }

    private func isRecoveryKeyScreenVisible(timeout: TimeInterval) -> Bool {
        return waitForAnyText([
            "Personal Recovery Key",
            "Write Down Personal Recovery Key",
            "Paper Key",
            "Recovery Phrase"
        ], timeout: timeout)
    }
}
