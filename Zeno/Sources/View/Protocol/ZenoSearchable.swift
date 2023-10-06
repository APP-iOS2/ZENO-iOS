//
//  ZenoSearchable.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/05.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

protocol ZenoSearchable: Identifiable {
    var name: String { get set }
    var imageURL: String? { get set }
    var description: String { get set }
}
