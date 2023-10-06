//
//  CommUserMgmtView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/27.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommUserMgmtView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var commViewModel: CommViewModel
    
    var body: some View {
        VStack {
            HStack {
                ZenoNavigationBackBtn {
                    dismiss()
                }
                Text("구성원 관리")
                    .padding(.leading, 30)
                Spacer()
            }
            .padding()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Section {
                        ForEach($commViewModel.currentWaitApprovalMembers) { $user in
                            HStack(alignment: .center) {
                                CommUserMgmtCellView(user: $user, actionType: .accept)
                            }
                        }
                    } header: {
                        HStack {
                            Text("새로 신청한 유저")
                            Spacer()
                            Text("\(commViewModel.currentCommUsers.count) 명")
                        }
                    }
                    Section {
                        ForEach($commViewModel.currentCommUsers) { $user in
                            CommUserMgmtCellView(user: $user, actionType: .deport)
                        }
                    } header: {
                        HStack {
                            Text("그룹에 가입된 유저")
                            Spacer()
                            Text("\(commViewModel.currentCommUsers.count) 명")
                        }
                        .padding(.top)
                    }
                }
                .gmTitle()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
        }
        .tint(.black)
    }
}

struct UserManagementView_Previews: PreviewProvider {
    static var previews: some View {
        CommUserMgmtView()
        .environmentObject(CommViewModel())
    }
}
