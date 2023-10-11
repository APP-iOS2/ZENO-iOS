//
//  TabBarView.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

enum MainTab: Int, CaseIterable, Identifiable {
    case home, zeno, alert, myPage
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .home:
            CommMainView()
        case .zeno:
            SelectCommunityVer2()
        case .alert:
            AlarmView()
        case .myPage:
            MyPageMain()
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .zeno:
            return "제노"
        case .alert:
            return "알림"
        case .myPage:
            return "마이페이지"
        }
    }
    
    var imageName: String {
        switch self {
        case .home:
            return "house"
        case .zeno:
            return "z.circle.fill"
        case .alert:
            return "bell.fill"
        case .myPage:
            return "person.circle"
        }
    }
    
    var id: Self { self }
}

struct TabBarView: View {
    @AppStorage("fcmToken") var fcmToken: String = ""
    @State private var selectedTabIndex = 0
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject var alarmViewModel: AlarmViewModel = AlarmViewModel()
    @StateObject var iAPStore: IAPStore = IAPStore()
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            ForEach(MainTab.allCases) { tab in
                tab.view
                    .tabItem {
                        Image(systemName: tab.imageName)
                        Text(tab.title)
                    }
                    .tag(tab.rawValue)
            }
            .toolbarBackground(.visible, for: .tabBar)
		}
        .environmentObject(alarmViewModel)
        .environmentObject(iAPStore)
        .task {
            if let loginUser = userViewModel.currentUser {
                print("fetch alarm and update user fcmtoken")
                await alarmViewModel.fetchAlarm(showUserID: loginUser.id)
                await userViewModel.updateUserFCMToken(fcmToken)
            }
        }
	}
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .environmentObject(UserViewModel())
            .environmentObject(CommViewModel())
    }
}
