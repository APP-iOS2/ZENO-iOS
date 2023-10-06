//
//  ZenoViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class ZenoViewModel: ObservableObject {
    
    @Published private var selected: Int = 0

    private let coolTime: Int = 15
    
    init() {
        
    }
}
