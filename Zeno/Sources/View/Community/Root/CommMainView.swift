//
//  CommMainView.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct CommMainView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var commViewModel: CommViewModel
    @EnvironmentObject var tabBarViewModel: TabBarViewModel
    
    @State private var isShowingUserSearchView = false
    @State private var isShowingHamburgerView = false
    @State private var isPresentedAddCommView = false
	@State private var isPresentedRequestCommView = false
    
    @AppStorage("isShowingDetailNewBuddyToggle") private var isShowingDetailNewBuddyToggle = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if commViewModel.currentComm != nil {
                    ScrollView {
                        Group {
                            NewUserListView(isShowingDetailNewBuddyToggle: $isShowingDetailNewBuddyToggle)
                            SearchableUserListView(isShowingUserSearchView: $isShowingUserSearchView)
                        }
                        .modifier(HomeListModifier())
                        .animation(.default, value: [isShowingDetailNewBuddyToggle, isShowingUserSearchView])
                        if commViewModel.currentCommMembers.isEmpty {
                            Button {
                                commViewModel.kakao()
                            } label: {
                                VStack {
                                    LottieView(lottieFile: "invitePeople")
                                        .frame(width: .screenWidth * 0.6, height: .screenHeight * 0.3)
                                        .overlay {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 50))
												.foregroundColor(.mainColor)
                                                .offset(x: .screenWidth * 0.24, y: .screenHeight * 0.05)
                                        }
                                    Text("친구를 초대해보세요")
                                        .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 18))
										.foregroundColor(.primary)
                                        .offset(y: .screenHeight * -0.03)
                                }
                            }
                            .frame(height: .screenHeight * 0.55)
                        }
                    }
                } else {
					// 가입된 커뮤니티가 없을 때
					CommEmptyView {
                        commViewModel.isShowingCommListSheet.toggle()
					}
                }
            }
            .refreshable {
                Task {
                    try? await userViewModel.loadUserData()
                    await commViewModel.fetchAllComm()
                }
            }
            .toolbar {
                if commViewModel.currentComm != nil {
					// 커뮤니티 선택 버튼
					groupNameToolbarItem
					// 햄버거 바
                    hamburgerToolbarItem
                }
            }
            .sheet(isPresented: $commViewModel.isShowingCommListSheet) {
				CommListView(isPresented: $commViewModel.isShowingCommListSheet,
							 isPresentedAddCommView: $isPresentedAddCommView,
							 isPresentedRequestCommView: $isPresentedRequestCommView)
            }
            .navigationDestination(isPresented: $isPresentedAddCommView) {
                CommSettingView(editMode: .addNew)
            }
			.navigationDestination(isPresented: $isPresentedRequestCommView) {
				CommRequestListView()
			}
        }
        .tint(.ggullungColor)
        .overlay(
            CommSideMenuView(
                isPresented: $isShowingHamburgerView,
                comm: commViewModel.currentComm ?? Community.dummy[0]
            )
        )
//        .onChange(of: commViewModel.allComm) { _ in
//            commViewModel.joinedComm = commViewModel.allComm.filterJoined(user: commViewModel.currentUser)
//        }
        .onChange(of: tabBarViewModel.selected) { _ in
            isShowingHamburgerView = false
        }
//        .onChange(of: commViewModel.currentComm) { _ in
//            Task {
//                await commViewModel.fetchCurrentCommMembers()
//            }
//        }
//        .onChange(of: commViewModel.currentUser?.commInfoList) { _ in
//            Task {
//                await commViewModel.fetchJoinedComm()
//            }
//        }
    }
    
    var groupNameToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                commViewModel.isShowingCommListSheet.toggle()
            } label: {
                HStack {
                    Text(commViewModel.currentComm?.name ?? "가입된 커뮤니티가 없습니다")
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
        @StateObject private var userViewModel: UserViewModel = .init()
        @StateObject private var commViewModel: CommViewModel = .init()
        @StateObject private var zenoViewModel: ZenoViewModel = .init()
        @StateObject private var mypageViewModel: MypageViewModel = .init()
        @StateObject private var alarmViewModel: AlarmViewModel = .init()
        
        var body: some View {
            TabBarView()
                .edgesIgnoringSafeArea(.vertical)
                .environmentObject(userViewModel)
                .environmentObject(commViewModel)
                .environmentObject(zenoViewModel)
                .environmentObject(mypageViewModel)
                .environmentObject(alarmViewModel)
                .onAppear {
                    Task {
                        let result = await FirebaseManager.shared.read(type: User.self, id: "neWZ4Vm1VsTH5qY5X5PQyXTNU8g2")
                        switch result {
                        case .success(let user):
                            userViewModel.currentUser = user
                            commViewModel.updateCurrentUser(user: user)
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
