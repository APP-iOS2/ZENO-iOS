//
//  TabBarViewModel.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/13.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

class TabBarViewModel: ObservableObject {
    @Published var selected: MainTab = .alert
}
