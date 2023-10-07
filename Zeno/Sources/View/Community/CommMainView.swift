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
    }// body
}

extension CommMainView {
    // MARK: - 메인 뷰
    
    /// 새로들어온 유저 뷰
    var newUserView: some View {
        VStack {
            HStack {
                Text("새로 들어온 친구 \(commViewModel.generalMembers.count)")
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
            if isShowingUserSearchView {
                HStack {
                    TextField(text: $commViewModel.userSearchTerm) {
                        Text("친구 찾기...")
                            .font(.footnote)
                    }
                    Spacer()
                    Button {
                        isShowingUserSearchView = false
                        commViewModel.userSearchTerm = ""
                    } label: {
                        Text("취소")
                            .font(.caption)
                    }
                }
                ForEach(commViewModel.searchedUsers) { user in
                    userCell(user: user)
                }
            } else {
                HStack {
                    Text("친구 \(commViewModel.generalMembers.count)")
                        .font(.footnote)
                    Spacer()
                    Button {
                        isShowingUserSearchView = true
                        print("유저 리스트 뷰 보이기")
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                    }
                }
                VStack {
                    ForEach(commViewModel.generalMembers) { user in
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
            if user.imageURL != nil {
                // 사용자 프로필이미지 들어가야함
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
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
            Button {
                print("친구추가 버튼")
            } label: {
                Text("친구추가")
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
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
