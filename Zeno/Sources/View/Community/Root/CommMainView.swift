//
//  CommMainView.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct CommMainView: View {
    @EnvironmentObject var commViewModel: CommViewModel
    @EnvironmentObject var tabBarViewModel: TabBarViewModel
    
    @State private var isShowingUserSearchView = false
    @State private var isShowingHamburgerView = false
    @State private var isPresentedAddCommView = false
	@State private var isPresentedRequestCommView = false
    
    @AppStorage("isShowingDetailNewBuddyToggle") private var isShowingDetailNewBuddyToggle = true
    
    var body: some View {
        NavigationStack {
            if commViewModel.isFetchComplete {
                VStack {
                    if commViewModel.currentComm != nil {
                        ScrollView {
                            Group {
                                NewUserListView(isShowingDetailNewBuddyToggle: $isShowingDetailNewBuddyToggle)
                                SearchableUserListView(isShowingUserSearchView: $isShowingUserSearchView)
                            }
                            .homeList()
                            .animation(.default, value: [isShowingDetailNewBuddyToggle, isShowingUserSearchView])
                            if commViewModel.currentCommMembers.isEmpty {
                                CommMainInviteView()
                            }
                        }
                        .scrollDismissesKeyboard(.immediately)
                        .toolbar {
                            groupNameToolbarItem
                            hamburgerToolbarItem
                        }
                    } else {
                        // 가입된 커뮤니티가 없을 때
                        CommEmptyView {
                            commViewModel.isShowingCommListSheet.toggle()
                        }
                    }
                }
                .sheet(isPresented: $commViewModel.isShowingCommListSheet) {
                    CommJoinedListView(isPresented: $commViewModel.isShowingCommListSheet, isPresentedAddCommView: $isPresentedAddCommView, isPresentedRequestCommView: $isPresentedRequestCommView)
                }
                .navigationDestination(isPresented: $isPresentedAddCommView) {
                    CommSettingView(editMode: .addNew)
                }
                .navigationDestination(isPresented: $isPresentedRequestCommView) {
                    CommRequestListView()
                }
            } else {
                ProgressView()
                    .tint(.mainColor)
            }
        }
        .hideKeyboardOnTap()
        .tint(.ggullungColor)
        .overlay(
            CommSideMenuView(
                isPresented: $isShowingHamburgerView,
                comm: commViewModel.currentComm ?? Community.dummy[0]
            )
        )
        .onChange(of: tabBarViewModel.selected) { _ in
            isShowingHamburgerView = false
        }
        .onChange(of: commViewModel.currentComm) { _ in
            isShowingUserSearchView = false
        }
    }
    
    var groupNameToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if let currentComm = commViewModel.currentComm {
                Button {
                    commViewModel.isShowingCommListSheet.toggle()
                } label: {
                    HStack {
                        Text(currentComm.name)
                            .foregroundColor(.primary)
                            .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 20))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                    }
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    var hamburgerToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                isShowingHamburgerView = true
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.leading)
            }
        }
    }
}

struct HomeMainView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var commViewModel: CommViewModel = .init()
        @StateObject private var zenoViewModel: ZenoViewModel = .init()
        @StateObject private var mypageViewModel: MypageViewModel = .init()
        @StateObject private var alarmViewModel: AlarmViewModel = .init()
        
        var body: some View {
            TabBarView()
                .edgesIgnoringSafeArea(.vertical)
                .environmentObject(commViewModel)
                .environmentObject(zenoViewModel)
                .environmentObject(mypageViewModel)
                .environmentObject(alarmViewModel)
                .onAppear {
                    Task {
                        let result = await FirebaseManager.shared.read(type: User.self, id: "neWZ4Vm1VsTH5qY5X5PQyXTNU8g2")
                        switch result {
                        case .success(let user):
                            commViewModel.userListenerHandler(user: user)
                        case .failure:
                            print("preview 유저로드 실패")
                        }
                    }
                }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
