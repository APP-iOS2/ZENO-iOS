//
//  ZenoNavigationManage.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/08.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject
    var router = Router<Path>(root: .A)
    
    var body: some View {
        RouterView(router: router) { path in
            switch path {
            case .A: SelectCommunityVer2()
            case .B: ZenoView(zenoList: Array(Zeno.ZenoQuestions.shuffled().prefix(10)), allMyFriends: User.dummy)
            case .C: ZenoRewardView()
            case .D: FinishZenoView()
            }
        }
    }
}
