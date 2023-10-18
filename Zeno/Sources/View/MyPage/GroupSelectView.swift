//
//  GroupSelectView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

enum UserChoice: String, CaseIterable {
    case friends = "친구 목록"
    case badge = "뱃지 현황"
}

struct GroupSelectView: View {
    @EnvironmentObject private var mypageViewModel: MypageViewModel
    @State var userSelected: UserChoice = .friends
    
    var body: some View {
        LazyVGrid(columns: [.init()],
                  alignment: .trailing,
                  pinnedViews: .sectionHeaders) {
            Section {
                if userSelected.rawValue == "친구 목록" {
                    MypageFriendListView()
                        .environmentObject(mypageViewModel)
                } else {
                    BadgeView()
                        .environmentObject(mypageViewModel)
                }
            } header: {
                HStack {
                    ForEach(UserChoice.allCases, id: \.self) { choiced in
                        VStack {
                            Button {
                                userSelected = choiced
                            } label: {
                                Text("\(choiced.rawValue)")
                                    .frame(minWidth: UIScreen.main.bounds.width / 2)
                            }
                            .frame(height: 40)
                            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                            .fontWeight(choiced.rawValue == userSelected.rawValue ? .bold : .thin)
                            .foregroundColor(.primary)
                            
                            if choiced.rawValue == userSelected.rawValue {
                                Capsule()
                                    .foregroundColor(.primary)
                                    .frame(height: 3)
                            } else {
                                Capsule()
                                    .foregroundColor(.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                }
                .background(Color(uiColor: .systemBackground))
            }
        }
    }
}

struct GroupSelectView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSelectView()
            .environmentObject(MypageViewModel())
    }
}
