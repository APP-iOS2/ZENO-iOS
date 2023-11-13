//
//  KeyPath+.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/24.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

extension KeyPath {
    var toString: String {
        guard let propertyName = self.debugDescription.split(separator: ".").last else { return "" }
        return String(propertyName)
    }
}
