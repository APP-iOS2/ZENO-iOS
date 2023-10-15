//
//  GlobalFunction.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/13.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

/// 한글로 써져있는지 체크 (정규 표현식 패턴을 사용)
func koreaLangCheck(_ input: String) -> Bool {
    let pattern = "^[가-힣]*$"
    if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
        let range = NSRange(location: 0, length: input.utf16.count)
        if regex.firstMatch(in: input, options: [], range: range) != nil {
            return true
        }
    }
    return false
}
