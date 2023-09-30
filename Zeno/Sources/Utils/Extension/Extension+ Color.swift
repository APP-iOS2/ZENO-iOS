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
    static let mainColor2 = #colorLiteral(red: 0.1589618165, green: 0.1237950838, blue: 0.2860623389, alpha: 1)
    
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
