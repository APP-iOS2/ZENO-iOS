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
    
    @State private var isShowingCommListSheet = false
    @State private var isShowingUserSearchView = false
    @State private var isShowingHamburgerView = false
    
    @AppStorage("isShowingDetailNewBuddyToggle") private var isShowingDetailNewBuddyToggle = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if commViewModel.currentComm != nil {
                    newUserView
                    userListView
                }
            }
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
                CommListView(isPresented: $isShowingCommListSheet)
            }
            .fullScreenCover(isPresented: $commViewModel.isJoinWithDeeplinkView) {
                CommJoinWithDeeplinkView(isPresented: $commViewModel.isJoinWithDeeplinkView, comm: commViewModel.filterDeeplinkComm)
            }
            .onTapGesture {
                isShowingHamburgerView = false
            }
        }
        .tint(.black)
        .overlay(
            SideMenuView(
                isPresented: $isShowingHamburgerView,
                comm: commViewModel.currentComm ?? Community.dummy[0]
            )
        )
        .onChange(of: commViewModel.allComm) { _ in
            commViewModel.filterJoinedComm()
        }
        .onChange(of: commViewModel.currentComm) { _ in
            Task {
                await commViewModel.fetchCurrentCommMembers()
            }
        }
        .onOpenURL { url in
            Task {
                await commViewModel.handleInviteURL(url)
            }
        }
    }
    /// 새로들어온 유저 뷰
    var newUserView: some View {
        VStack {
            HStack {
                Text("새로 들어온 친구 \(commViewModel.recentlyJoinedMembers.count)")
                    .font(.footnote)
                Spacer()
                Button {
                    isShowingDetailNewBuddyToggle.toggle()
                } label: {
                    Image(systemName: isShowingDetailNewBuddyToggle ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                }
            }
            if isShowingDetailNewBuddyToggle {
                ScrollView(.horizontal) {
                    HStack(spacing: 15) {
                        ForEach(commViewModel.recentlyJoinedMembers) { user in
                            VStack(spacing: 5) {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("\(user.name)")
                                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .modifier(HomeListModifier())
        .animation(.default, value: isShowingDetailNewBuddyToggle)
        .animation(.default, value: [isShowingDetailNewBuddyToggle, isShowingUserSearchView])
    }
    /// 그룹 내 유저 목록 뷰
    var userListView: some View {
        VStack {
            HStack {
                if isShowingUserSearchView {
                    TextField(text: $commViewModel.userSearchTerm) {
                        Text("친구 찾기...")
                            .font(.footnote)
                    }
                } else {
                    Text("친구 \(commViewModel.currentCommMembers.count)")
                        .font(.footnote)
                }
                Spacer()
                Button {
                    isShowingUserSearchView.toggle()
                    commViewModel.userSearchTerm = ""
                } label: {
                    if isShowingUserSearchView {
                        Text("취소")
                            .font(.caption)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                    }
                }
            }
            if isShowingUserSearchView {
                ForEach(commViewModel.searchedUsers) { user in
                    userCell(user: user)
                }
            } else {
                VStack {
                    ForEach(commViewModel.currentCommMembers) { user in
                        userCell(user: user)
                    }
                }
            }
        }
        .modifier(HomeListModifier())
        .animation(.default, value: [isShowingDetailNewBuddyToggle, isShowingUserSearchView])
    }
    
    /// 유저 셀 뷰
    func userCell(user: User) -> some View {
        HStack {
            ZenoKFImageView(user)
                .frame(width: 30, height: 30)
            VStack(alignment: .leading) {
                // 유저 이름
                Text("\(user.name)")
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 15))
                    .padding(.bottom, 1)
                // 유저 한줄 소개
                Text("\(user.description)")
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
                    .foregroundColor(Color(uiColor: .systemGray4))
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
                    Text("친구추가")
                        .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
                }
            }
        }
        .homeListCell()
    }
    
    // MARK: - 툴바
    
    /// 그룹 이름 툴바아이템
    var groupNameToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                isShowingCommListSheet.toggle()
            } label: {
                HStack {
                    Text(commViewModel.currentComm?.name ?? "가입된 커뮤니티가 없습니다")
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
            }
        }
    }
    
    /// 햄버거 툴바아이템
    var hamburgerToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                isShowingHamburgerView = true
            } label: {
                Image(systemName: "line.3.horizontal")
                    .fontWeight(.semibold)
            }
        }
    }
}

struct HomeMainView_Previews: PreviewProvider {
	static var previews: some View {
		/*HomeMainView()*/
		TabBarView()
			.environmentObject(UserViewModel(currentUser: .dummy[0]))
			.environmentObject(CommViewModel())
	}
}
