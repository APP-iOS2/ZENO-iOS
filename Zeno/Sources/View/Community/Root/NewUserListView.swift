//
//  NewUserListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/15.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct NewUserListView: View {
    @EnvironmentObject private var commViewModel: CommViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @Binding var isShowingDetailNewBuddyToggle: Bool
    
    var body: some View {
        VStack {
            Section {
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
            } header: {
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
            }
        }
    }
}

struct NewUserListView_Previews: PreviewProvider {
    static var previews: some View {
        NewUserListView(isShowingDetailNewBuddyToggle: .constant(true))
    }
}
