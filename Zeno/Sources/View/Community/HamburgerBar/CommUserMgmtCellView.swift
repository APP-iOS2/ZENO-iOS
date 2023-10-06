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
                switch actionType {
                case .accept:
                    break
                    // TODO: 그룹에 추가 메서드
                case .deport:
                    break
                    // TODO: 그룹에서 내보내기 메서드
                }
            }
            .padding(.horizontal)
        }
        .frame(width: .infinity)
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
    }
}
