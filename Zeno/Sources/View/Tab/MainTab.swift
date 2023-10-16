//
//  MainTab.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/13.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

enum MainTab: Int, CaseIterable, Identifiable {
    case alert, zeno, comm, myPage
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .alert:
            AlarmView()
        case .zeno:
            SelectCommunityVer2()
        case .comm:
            CommMainView()
        case .myPage:
            MyPageMain()
        }
    }
    
    var title: String {
        switch self {
        case .alert:
            return "홈"
        case .zeno:
            return "제노"
        case .comm:
            return "그룹"
        case .myPage:
            return "마이페이지"
        }
    }
    
    var imageName: String {
        switch self {
        case .alert:
            return "house"
        case .zeno:
            return "z.circle.fill"
        case .comm:
            return "rectangle.3.group"
        case .myPage:
            return "person.circle"
        }
    }
    
    var id: Self { self }
}
