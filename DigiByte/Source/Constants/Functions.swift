//
//  Functions.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-06-18.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

func guardProtected(queue: DispatchQueue, callback: @escaping () -> Void) {
    var protectedDataObserver: Any?
    var didBecomeActiveObserver: Any?
    var didRun = false

    let removeObservers = {
        if let observer = protectedDataObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = didBecomeActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    let runCallback = {
        guard !didRun else { return }
        didRun = true
        removeObservers()
        queue.async {
            callback()
        }
    }

    if UIApplication.shared.isProtectedDataAvailable || UIApplication.shared.applicationState != .background {
        runCallback()
    } else {
        protectedDataObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.protectedDataDidBecomeAvailableNotification,
            object: nil,
            queue: nil,
            using: { _ in runCallback() }
        )
        didBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: nil,
            using: { _ in runCallback() }
        )
    }
}

func strongify<Context: AnyObject>(_ context: Context, closure: @escaping(Context) -> Void) -> () -> Void {
    return { [weak context] in
        guard let strongContext = context else { return }
        closure(strongContext)
    }
}

func strongify<Context: AnyObject, Arguments>(_ context: Context?, closure: @escaping (Context, Arguments) -> Void) -> (Arguments) -> Void {
    return { [weak context] arguments in
        guard let strongContext = context else { return }
        closure(strongContext, arguments)
    }
}
