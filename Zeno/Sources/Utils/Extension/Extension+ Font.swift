//
//  Extension+ Font.swift
//  Zeno
//
//  Created by Muker on 2023/10/13.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

extension Font {
	static func thin(_ size: CGFloat) -> Font {
		return ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: size)
	}
	
	static func regular(_ size: CGFloat) -> Font {
		return ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: size)
	}
	
	static func bold(_ size: CGFloat) -> Font {
		return ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: size)
	}
	
	static func extraBold(_ size: CGFloat) -> Font {
		return ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: size)
	}
}
