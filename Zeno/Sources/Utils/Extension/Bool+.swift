//
//  Bool+.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/17.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

extension Bool {
    static var isIPhoneSE: Bool {
        return CGFloat.screenHeight == 667
    }
}
