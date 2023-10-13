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
    
    @State private var isDeportAlert = false
    @State private var deportUser = User.emptyUser
    @State private var isWaitListFold = false
    @State private var isCurrentListFold = false
    
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
                ForEach(MGMTSection.allCases) { section in
                    switch section {
                    case .wait:
                        ZenoProfileVisibleListView(list: commViewModel.currentWaitApprovalMembers) {
                            Text("\(section.header) \(commViewModel.currentWaitApprovalMembers.count)")
                        } btnLabel: {
                            HStack(alignment: .bottom, spacing: 2) {
                                Image(systemName: "person.crop.circle.badge.plus")
                                Text("가입수락")
                            }
                        } interaction: { user in
                            Task {
                                await commViewModel.acceptMember(user: user)
                            }
                        }
                    case .general:
                        ZenoProfileVisibleListView(list: commViewModel.currentCommMembers) {
                            Text("\(section.header) \(commViewModel.currentCommMembers.count)")
                        } btnLabel: {
                            HStack(alignment: .bottom, spacing: 2) {
                                Image(systemName: "person.crop.circle.badge.minus")
                                Text("추방하기")
                            }
                        } interaction: { user in
                            deportUser = user
                            isDeportAlert = true
                        }
                    }
                }
            }
            .refreshable {
                Task {
                    await commViewModel.fetchCurrentCommMembers()
                }
            }
        }
        .tint(.black)
        .alert("\(deportUser.name)님을 내보낼까요?", isPresented: $isDeportAlert) {
            Button("내보내기", role: .destructive) {
                Task {
                    await commViewModel.deportMember(user: deportUser)
                }
            }
            Button("취소", role: .cancel) {
                deportUser = .emptyUser
            }
        }
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
