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
                    ForEach(MGMTSection.allCases) { section in
                        Section {
                            switch section {
                            case .wait:
                                ForEach($commViewModel.currentWaitApprovalMembers) { $user in
                                        CommUserMgmtCellView(user: $user, actionType: .accept)
                                }
                            case .general:
                                ForEach($commViewModel.currentCommMembers) { $user in
                                    CommUserMgmtCellView(user: $user, actionType: .deport)
                                }
                            }
                        } header: {
                            HStack {
                                Text(section.header)
                                    .font(.headline)
                                Spacer()
                                switch section {
                                case .wait:
                                    Text("\(commViewModel.currentWaitApprovalMembers.count) 명")
                                case .general:
                                    Text("\(commViewModel.currentCommMembers.count) 명")
                                }
                            }
                            .font(.footnote)
                        }
                    }
                }
                .gmTitle()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
        }
        .tint(.black)
    }
    
    private enum MGMTSection: CaseIterable, Identifiable {
        case wait, general
        
        var header: String {
            switch self {
            case .wait:
                return "새로 신청한 유저"
            case .general:
                return "그룹에 가입된 유저"
            }
        }
        
        var id: Self { self }
    }
}

struct UserManagementView_Previews: PreviewProvider {
    static var previews: some View {
        CommUserMgmtView()
            .environmentObject(CommViewModel())
    }
}
