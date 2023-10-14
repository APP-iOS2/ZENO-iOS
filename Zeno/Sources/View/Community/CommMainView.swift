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
    
    @State private var isShowingCommListSheet = false
    @State private var isShowingUserSearchView = false
    @State private var isShowingHamburgerView = false
    @State private var isPresentedAddCommView = false
    
    @AppStorage("isShowingDetailNewBuddyToggle") private var isShowingDetailNewBuddyToggle = true
    
    var body: some View {
        NavigationStack {
            mainView
                .refreshable {
                    Task {
                        try? await userViewModel.loadUserData()
                        await commViewModel.fetchAllComm()
                    }
                }
                .toolbar {
                    // 커뮤니티 선택 버튼
                    groupNameToolbarItem
                    // 햄버거 바
                    if commViewModel.currentComm != nil {
                        hamburgerToolbarItem
                    }
                }
                .sheet(isPresented: $isShowingCommListSheet) {
                    CommListView(isPresented: $isShowingCommListSheet, isPresentedAddCommView: $isPresentedAddCommView)
                }
                .fullScreenCover(isPresented: $commViewModel.isJoinWithDeeplinkView) {
                    CommJoinWithDeeplinkView(isPresented: $commViewModel.isJoinWithDeeplinkView, comm: commViewModel.filterDeeplinkComm)
                }
                .navigationDestination(isPresented: $isPresentedAddCommView) {
                    CommSettingView(editMode: .addNew)
                }
                .onTapGesture {
                    isShowingHamburgerView = false
                }
        }
        .tint(.black)
        .overlay(
            CommSideMenuView(
                isPresented: $isShowingHamburgerView,
                comm: commViewModel.currentComm ?? Community.dummy[0]
            )
        )
        .onChange(of: commViewModel.allComm) { _ in
            commViewModel.filterJoinedComm()
        }
        .onChange(of: tabBarViewModel.selected) { _ in
            isShowingHamburgerView = false
        }
        .onChange(of: commViewModel.currentComm) { _ in
            Task {
                await commViewModel.fetchCurrentCommMembers()
            }
        }
    }
    
    @ViewBuilder
    var mainView: some View {
        if commViewModel.currentComm != nil {
            ScrollView {
                if commViewModel.currentComm != nil {
                    newUserView
                    userListView
                }
            }
        } else {
            AlarmEmptyView()
        }
    }
    
    var newUserView: some View {
        VStack {
            HStack {
                Text("새로 들어온 구성원 \(commViewModel.recentlyJoinedMembers.count)")
					.font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
                    .font(.footnote)
                Spacer()
                if !commViewModel.recentlyJoinedMembers.isEmpty {
                    Button {
                        isShowingDetailNewBuddyToggle.toggle()
                    } label: {
                        Image(systemName: isShowingDetailNewBuddyToggle ? "chevron.up" : "chevron.down")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
                    }
                }
            }
			.foregroundColor(.primary)
            if isShowingDetailNewBuddyToggle {
                ScrollView(.horizontal) {
                    HStack(spacing: 15) {
                        ForEach(commViewModel.recentlyJoinedMembers) { user in
                            VStack(spacing: 5) {
                                Circle()
                                    .stroke()
                                    .frame(width: 30, height: 30)
                                    .background(
                                        ZenoKFImageView(user)
                                            .clipShape(Circle())
                                    )
                                Text("\(user.name)")
									.foregroundColor(.primary)
									.font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 12))
                            }
                        }
                    }
                    .padding(1)
                }
                .scrollIndicators(.hidden)
            }
        }
        .modifier(HomeListModifier())
        .animation(.default, value: isShowingDetailNewBuddyToggle)
        .animation(.default, value: [isShowingDetailNewBuddyToggle, isShowingUserSearchView])
    }
    
    var userListView: some View {
        VStack {
            HStack {
                if isShowingUserSearchView {
                    TextField(text: $commViewModel.userSearchTerm) {
                        Text("구성원 찾기...")
                    }
					.font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
                } else {
                    Text("구성원 \(commViewModel.currentCommMembers.count)")
						.font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
                }
                Spacer()
                if !commViewModel.currentCommMembers.isEmpty {
                    Button {
                        isShowingUserSearchView.toggle()
                        commViewModel.userSearchTerm = ""
                    } label: {
                        if isShowingUserSearchView {
                            Text("취소")
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                    .font(.caption)
                }
            }
			.foregroundColor(.primary)
            if isShowingUserSearchView {
                ForEach(commViewModel.searchedUsers) { user in
                    userCell(user: user)
                }
            } else {
                ForEach(commViewModel.currentCommMembers) { user in
                    userCell(user: user)
                }
            }
        }
        .modifier(HomeListModifier())
        .animation(.default, value: [isShowingDetailNewBuddyToggle, isShowingUserSearchView])
    }
    
    func userCell(user: User) -> some View {
        HStack {
            Circle()
                .stroke()
                .frame(width: 30, height: 30)
                .background(
                    ZenoKFImageView(user)
                        .clipShape(Circle())
                )
			VStack(alignment: .leading, spacing: 2) {
                Text("\(user.name)")
					.foregroundColor(.primary)
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
                Text("\(user.description)")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 10))
                    .foregroundColor(Color(uiColor: .systemGray))
                    .lineLimit(1)
            }
            .padding(.leading, 4)
            Spacer()
            if !commViewModel.isFriend(user: user) {
                Button {
                    Task {
                        guard let comm = commViewModel.currentComm else { return }
                        await userViewModel.addFriend(user: user, comm: comm)
                    }
                } label: {
					HStack(alignment: .bottom, spacing: 2) {
						Image(systemName: "person.crop.circle.badge.plus")
						Text("친구추가")
					}
					.font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
					.foregroundColor(.white)
					.padding(5)
					.background(Color("MainColor"))
					.cornerRadius(6)
					.shadow(radius: 0.3)
                }
            }
        }
        .homeListCell()
    }
    
    var groupNameToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                isShowingCommListSheet.toggle()
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
	static var previews: some View {
		TabBarView()
			.environmentObject(UserViewModel())
            .environmentObject(CommViewModel())
            .environmentObject(ZenoViewModel())
            .environmentObject(AlarmViewModel())
			.environmentObject(MypageViewModel())
	}
}
