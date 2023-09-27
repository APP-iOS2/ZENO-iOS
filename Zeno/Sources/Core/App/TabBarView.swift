//
//  TabBarView.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTabIndex = 0
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            HomeMainView()
                .tabItem {
                    Image(systemName: "house")
                    Text("홈")
                }
                .tag(0)
            
            SelectCommunityView()
                .tabItem {
                    Image(systemName: "z.circle.fill")
                    Text("제노")
                }
                .tag(1)
            
            HomeMainView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("알림")
                }
                .tag(2)
            
            HomeMainView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("마이페이지")
                }
                .tag(3)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
