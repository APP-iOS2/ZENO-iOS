//
//  CommUserMgmtCellView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/27.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommUserMgmtCellView: View {
    @Binding var user: User
    let actionType: ActionType
    
    @EnvironmentObject private var commViewModel: CommViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "person.fill")
                .font(.largeTitle)
                .padding(.horizontal)
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                Text(user.description)
                    .font(.subheadline)
            }
            Spacer()
            Button(actionType.title) {
                Task {
                    switch actionType {
                    case .accept:
                        await commViewModel.acceptMember(user: user)
                    case .deport:
                        // TODO: 내보낸 유저에게 알람을 보냄
                        await commViewModel.deportMember(user: user)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    enum ActionType {
        case accept, deport
        
        var title: String {
            switch self {
            case .accept:
                return "수락"
            case .deport:
                return "추방"
            }
        }
    }
}

struct UserManagementCellView_Previews: PreviewProvider {
    static var previews: some View {
        CommUserMgmtCellView(user: .constant(.dummy[0]), actionType: .accept)
            .environmentObject(CommViewModel())
    }
}
