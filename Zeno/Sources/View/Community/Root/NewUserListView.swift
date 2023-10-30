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
    
    @Binding var isShowingDetailNewBuddyToggle: Bool
    
    var body: some View {
        LazyVStack {
            Section {
                if isShowingDetailNewBuddyToggle && !commViewModel.recentlyJoinedMembers.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 14) {
                            ForEach(commViewModel.recentlyJoinedMembers) { user in
                                VStack(spacing: 5) {
                                    Circle()
                                        .stroke()
                                        .frame(width: 35, height: 35)
                                        .background(
                                            ZenoKFImageView(user)
                                                .clipShape(Circle())
                                        )
                                    Text("\(user.name)")
										.lineLimit(1)
                                        .foregroundColor(.primary)
                                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 11))
										.frame(width: 40)
                                }
                            }
                        }
                        .padding(1)
                    }
                    .scrollIndicators(.hidden)
                }
            } header: {
                HStack(alignment: .center) {
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
