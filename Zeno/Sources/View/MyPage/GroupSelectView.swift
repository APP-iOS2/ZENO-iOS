//
//  GroupSelectView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

enum UserChoice: String, CaseIterable {
    case firends = "친구 목록"
    case badge = "뱃지 현황"
}

struct GroupSelectView: View {
    @State var userSelected: UserChoice = .firends
    private var testData = ["박서연", "신우진", "김하은", "김건섭", "원강묵"]
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(UserChoice.allCases, id: \.self) { choiced in
                            VStack {
                                Button {
                                    userSelected = choiced
                                    print("userSelected : \(userSelected)")
                                    print("choiced : \(choiced)")
                                } label: {
                                    Text("\(choiced.rawValue)")
                                        .frame(minWidth: UIScreen.main.bounds.width / 2)
                                }
                                .frame(height: 50)
                                .font(.system(size: 17, weight: choiced.rawValue == userSelected.rawValue ? .bold : .thin))
                                .foregroundColor(.primary)
                                
                                if choiced.rawValue == userSelected.rawValue {
                                    Capsule()
                                        .foregroundColor(.black)
                                        .frame(height: 3)
                                } else {
                                    Capsule()
                                        .foregroundColor(.clear)
                                        .frame(height: 3)
                                }
                            }
                        }
                    }
                    .overlay(
                        Divider().offset(x: 0, y: 30)
                    )
                }
                Spacer()
                
                if userSelected.rawValue == "친구 목록" {
                    MypageFriendListView()
                }
                Spacer()
            }
        }
    }
}
struct GroupSelectView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSelectView()
    }
}
