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
    /// 기기높이별 Font비율 return
    static func setSize() -> Double {
        let height = CGFloat.screenHeight
        var size = 1.0
        switch height {
        case 480.0: // IPhone 3,4S => 3.5 inch
            size = 0.85
        case 568.0: // IPhone 5, SE => 4 inch
            size = 0.9
        case 667.0: // IPhone 6, 6s, 7, 8 => 4.7 inch
            size = 0.9
        case 736.0: // IPhone 6s+ 6+, 7+, 8+ => 5.5 inch
            size = 0.95
        case 812.0: // IPhone X, XS, 13 mini, 12 mini => 5.8 inch
            size = 0.98
        case 844.0: // IPhone 14, 13 pro, 13, 12 pro, 12
            size = 1
        case 852.0: // IPhone 14 pro
            size = 1
        case 926.0: // IPhone 14 plus, 13 pro max, 12 pro max
            size = 1.05
        case 896.0: // IPhone XR => 6.1 inch  // IPhone XS MAX => 6.5 inch, 11 pro max, 11
            size = 1.05
        case 932.0: // IPhone 14 Pro Max
            size = 1.08
        default:
            size = 1
        }
        return size
    }
}
