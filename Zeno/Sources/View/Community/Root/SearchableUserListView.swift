//
//  SearchableUserListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/15.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct SearchableUserListView: View {
    @Binding var isShowingUserSearchView: Bool
    
    @EnvironmentObject private var commViewModel: CommViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @FocusState private var isFocusedKeyboard: Bool
    
    
    var body: some View {
        LazyVStack {
            Section {
                ForEach(isShowingUserSearchView ?
                        commViewModel.searchedUsers :
                            commViewModel.currentCommMembers) { user in
                    ZenoProfileVisibleCellView(item: user,
											   isBtnHidden: commViewModel.isFriend(user: user),
											   isManager: commViewModel.checkManagerUser(user: user)) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("친구추가")
                        }
                    } interaction: { user in
                        Task {
                            guard let comm = commViewModel.currentComm else { return }
                            await commViewModel.addFriend(user: user, comm: comm)
                        }
                    }
                }
            } header: {
                HStack {
                    if isShowingUserSearchView {
                        TextField(text: $commViewModel.userSearchTerm) {
                            Text("구성원 찾기...")
                        }
                        .focused($isFocusedKeyboard)
                    } else {
                        Text("구성원 \(commViewModel.currentCommMembers.count)")
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
                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
                .foregroundColor(.primary)
            }
        }
        .onChange(of: isShowingUserSearchView) { newValue in
            isFocusedKeyboard = newValue
        }
    }
}

struct SearchableUserListView_Previews: PreviewProvider {
    static var previews: some View {
        SearchableUserListView(isShowingUserSearchView: .constant(true))
            .environmentObject(CommViewModel())
            .environmentObject(UserViewModel())
    }
}
