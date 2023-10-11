//
//  Extension+ Color.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

extension Color {
    static let mainColor = Color(red: 123/255, green: 103/255, blue: 200/255)
    static let ggullungColor = Color(red: 49/255, green: 43/255, blue: 92/255)
    static let purple2 = hex("ac9ff0")
    static let purple3 = hex("8F62DC")
    static let gray2 = hex("C6C6C9")
    static let gray3 = hex("8e8e93")
    static let gray4 = hex("35363A")
    
	static func hex(_ hex: String) -> Self {
		let scanner = Scanner(string: hex)
		scanner.currentIndex = .init(utf16Offset: 0, in: hex)
		var rgbValue: UInt64 = 0
		scanner.scanHexInt64(&rgbValue)

		let r = (rgbValue & 0xff0000) >> 16
		let g = (rgbValue & 0xff00) >> 8
		let b = rgbValue & 0xff

		return Self.init(
			red: Double(r) / 0xff,
			green: Double(g) / 0xff,
			blue: Double(b) / 0xff,
			opacity: 1
		)
	}
}
