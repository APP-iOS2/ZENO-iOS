//
//  Array+.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/19.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

extension Array {
    mutating func removeFirstElement(_ element: Element) where Self: Equatable {
        guard let index = self.firstIndex(of: element) else { return }
        self.remove(at: index)
    }
    
    func slice(maxCount: Int) -> [Self] {
        var currentIndex = 0
        var result: [[Element]] = []
        while currentIndex < self.count {
            let endIndex = Swift.min(currentIndex + maxCount, self.count)
            let piece = Array(self[currentIndex..<endIndex])
            result.append(piece)
            currentIndex += maxCount
        }
        return result
    }
}
