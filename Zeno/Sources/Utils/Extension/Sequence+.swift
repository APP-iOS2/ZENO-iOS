//
//  Sequence+.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/09.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

extension Sequence {
    func asyncForEach(
        _ operation: @escaping (Element) async -> Void
    ) async {
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
        }
    }
	// 사용안함
//	func filterElementsInArray(arr: Self) -> [Self.Element] where Self.Element: Equatable {
//		let resultArr = filter {
//			var result = true
//			for i in arr {
//				if i != $0 {
//					result = false
//					break
//				}
//			}
//			return result
//		}
//		return resultArr
//	}
}
