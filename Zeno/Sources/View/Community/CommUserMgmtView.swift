//
//  CommUserMgmtView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/27.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommUserMgmtView: View {
    @Binding var newUsers: [User]
    @Binding var existingUsers: [User]
    
    var body: some View {
        ScrollView {
            HStack {
                Text("새로 신청한 유저")
                    .gmTitle()
                Spacer()
            }
            ForEach($newUsers) { $user in
                HStack(alignment: .center) {
                    CommUserMgmtCellView(user: $user, actionType: .accept)
                }
            }
            HStack {
                Text("그룹에 가입된 유저")
                    .gmTitle()
                Spacer()
            }
            ForEach($existingUsers) { $user in
                CommUserMgmtCellView(user: $user, actionType: .deport)
            }
        }
        .padding(.horizontal)
    }
}

struct UserManagementView_Previews: PreviewProvider {
    static var previews: some View {
        CommUserMgmtView(
            newUsers: .constant(User.dummy),
            existingUsers: .constant(User.dummy)
        )
    }
}
