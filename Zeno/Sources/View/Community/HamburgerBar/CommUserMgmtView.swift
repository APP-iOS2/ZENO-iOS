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
                                ForEach(commViewModel.currentWaitApprovalMembers) { user in
                                    ZenoProfileVisibleCellView(item: user, actionTitle: "가입수락") {
                                        Task {
                                            await commViewModel.acceptMember(user: user)
                                        }
                                    }
                                }
                            case .general:
                                ForEach(commViewModel.currentCommMembers) { user in
                                    ZenoProfileVisibleCellView(item: user, actionTitle: "추방하기") {
                                        deportUser = user
                                        isDeportAlert = true
                                    }
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
