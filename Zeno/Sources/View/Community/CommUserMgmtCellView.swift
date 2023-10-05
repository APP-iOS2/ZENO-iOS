//
//  CommUserMgmtCellView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/27.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommUserMgmtCellView: View {
    enum ActionType {
        case accept, deport
        
        var title: String {
            switch self {
            case .accept:
                return "수락"
            case .deport:
                return "강퇴"
            }
        }
    }
    
    @Binding var user: User
    let actionType: ActionType
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "person.fill")
                .font(.largeTitle)
            Spacer()
            VStack {
                Text("소속그룹 프로퍼티??")
                Text(user.name)
                Text("자기소개 프로퍼티??")
            }
            Spacer()
            // TODO: db의 친구 리스트에 있는지 여부로 조건 변경
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
        }
        .frame(width: .infinity)
        .padding(.vertical)
    }
}

struct UserManagementCellView_Previews: PreviewProvider {
    static var previews: some View {
        CommUserMgmtCellView(user: .constant(.dummy[0]), actionType: .accept)
    }
}
