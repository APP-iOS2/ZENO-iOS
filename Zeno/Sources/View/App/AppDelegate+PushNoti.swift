//
//  AppDelegate+PushNoti.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/13.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks

/// DynamicLink(미구현)
extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks()
//            .handleUniversalLink(userActivity.webpageURL!) { dynamiclink, error in
            .handleUniversalLink(userActivity.webpageURL!) { _, _ in
            }
        return handled
    }
}
