//
//  FirebaseAvailable.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/05.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

protocol FirebaseAvailable {
    var id: String { get }
}

extension FirebaseAvailable {
    func mirrorToDic() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: Any]()
        
        mirror.children.forEach {
            guard let key = $0.label else {
                #if DEBUG
                print(#function + ": fail to optional bind")
                #endif
                return
            }
            dictionary[key] = $0.value
        }
        return dictionary
    }
}
