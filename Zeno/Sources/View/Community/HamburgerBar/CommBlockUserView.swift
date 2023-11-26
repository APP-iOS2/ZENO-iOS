//
//  CommBlockUserView.swift
//  Zeno
//
//  Created by gnksbm on 2023/11/26.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommBlockUserView: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var commViewModel: CommViewModel
    
    @State private var isAlert: Bool = false
    @State private var selectedUser: User?
    
    var body: some View {
        ScrollView {
            ZenoNavigationBackBtn {
                dismiss()
            } tailingLabel: {
                HStack {
                    if commViewModel.currentCommMembers.isEmpty {
                        Text("차단할 유저가 없습니다")
                    } else {
                        Text("\(commViewModel.currentComm?.name ?? "") 유저 차단하기")
                    }
                    Spacer()
                }
                .font(.regular(16))
            }
            if !commViewModel.currentCommMembers.isEmpty {
                ForEach(commViewModel.currentCommMembers) { user in
                    HStack {
                        ZenoProfileVisibleCellView(item: user,
                                                   isBtnHidden: false,
                                                   isManager: commViewModel.checkManagerUser(user: user)) {
                            HStack(alignment: .bottom, spacing: 2) {
                                Image(systemName: "person.crop.square.filled.and.at.rectangle")
                                Text("차단하기")
                                    .font(.thin(12))
                            }
                        } interaction: { user in
                            selectedUser = user
                            isAlert = true
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .alert("\(selectedUser?.name ?? "")님이 차단됩니다.",
               isPresented: $isAlert) {
            Button("확인", role: .destructive) {
                Task {
                    if let selectedUser {
                        commViewModel.blockUser(user: selectedUser)
                    }
                    selectedUser = nil
                }
            }
            Button("취소", role: .cancel) {
                selectedUser = nil
            }
        }
    }
}

struct CommBlockUserView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var commViewModel: CommViewModel = .init()
        @State private var isPresented = false
        var body: some View {
            CommBlockUserView(isPresented: $isPresented)
                .environmentObject(commViewModel)
                .onAppear {
                    commViewModel.currentCommMembers = [
                        .fakeCurrentUser,
                        .fakeCurrentUser,
                        .fakeCurrentUser,
                    ]
                }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
