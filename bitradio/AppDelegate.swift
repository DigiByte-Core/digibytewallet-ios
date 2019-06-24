//
//  AppDelegate.swift
//  breadwallet
//
//  Created by Aaron Voisine on 10/5/16.
//  Copyright (c) 2016 breadwallet LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import LocalAuthentication
import Buglife

var senderApp = ""

class AppDelegate: UIResponder, UIApplicationDelegate {

    private var window: UIWindow? {
        return applicationController.window
    }
    let applicationController = ApplicationController()
    
#if Debug
    func resetKeychain() {
        deleteAllKeysForSecClass(kSecClassGenericPassword)
        deleteAllKeysForSecClass(kSecClassInternetPassword)
        deleteAllKeysForSecClass(kSecClassCertificate)
        deleteAllKeysForSecClass(kSecClassKey)
        deleteAllKeysForSecClass(kSecClassIdentity)
    }
    
    func deleteAllKeysForSecClass(_ secClass: CFTypeRef) {
        let dict: [NSString : Any] = [kSecClass : secClass]
        let result = SecItemDelete(dict as CFDictionary)
        assert(result == noErr || result == errSecItemNotFound, "Error deleting keychain data (\(result))")
    }
#endif
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

#if Debug
        
        if false {
            UserDefaults.hasShownWelcome = false
            resetKeychain()
        }
#endif
        
		Buglife.shared().start(withAPIKey: "") // TODO: Replace me with the BugLife API Key
        
        let appearance = Buglife.shared().appearance
        appearance.tintColor = .black
        appearance.barTintColor = .blueGradientEnd
        appearance.statusBarStyle = .lightContent
        
        UIView.swizzleSetFrame()
        applicationController.launch(application: application, options: launchOptions)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        senderApp = ""
        
        applicationController.willEnterForeground()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        applicationController.didEnterBackground()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        applicationController.willResignActive()
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        applicationController.performFetch(completionHandler)
    }

    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
        return false // disable extensions such as custom keyboards for security purposes
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        applicationController.application(application, didRegister: notificationSettings)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        applicationController.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        applicationController.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sendingAppID: String = options[.sourceApplication] as! String
        senderApp = sendingAppID
        
        return applicationController.open(url: url)
    }

}
