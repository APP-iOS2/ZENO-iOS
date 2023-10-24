//
//  String+.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/24.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

extension String {
    var checkKoreaLang: Bool {
        let pattern = "^[가-힣]*$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: self.utf16.count)
            if regex.firstMatch(in: self, options: [], range: range) != nil {
                return true
            }
        }
        return false
    }
}
