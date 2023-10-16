//
//  UINavigationController+.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/14.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import UIKit
/// NavigationBackButton 커스텀 시 navigationBarBackButtonHidden로 인해 Back 제스처 무시를 해결
extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
