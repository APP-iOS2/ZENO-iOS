//
//  CaseIdentifiable.swift
//  Zeno
//
//  Created by gnksbm on 2023/11/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

protocol CaseIdentifiable: Identifiable { }

extension CaseIdentifiable {
    var id: Self { self }
}
