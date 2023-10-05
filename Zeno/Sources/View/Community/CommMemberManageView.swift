//
//  CommMemberManageView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommMemberManageView: View {
    @Environment(\.dismiss) var dismiss
    
    let groupMembers: [String] = .init(repeating: "김찬형", count: 10)  // 추후 데이터 변경
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }, label: {
                    Image(systemName: "chevron.left")
                        .padding(.trailing, 30)
                })
                .tint(.black)
                
                Text("구성원 관리")
                
                Spacer()
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading) {
                    Section {
                        ForEach(groupMembers, id: \.hash) { value in
                            HStack {
                                Text(value)
                                Spacer()
                                Button(action: {}, label: {
                                    Text("수락")
                                })
                            }
                            .padding(10)
                        }
                    } header: {
                        Text("새로 신청한 유저")
                            .font(.title3)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct GroupMemberManageView_Preview: PreviewProvider {
    static var previews: some View {
        CommMemberManageView()
    }
}
