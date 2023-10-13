//
//  CommDelegateManagerView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/09.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommDelegateManagerView: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var commViewModel: CommViewModel
    
    @State private var isAlert: Bool = false
    @State private var selectedUser: User?
    
    var body: some View {
        ScrollView {
            HStack {
                ZenoNavigationBackBtn {
                    dismiss()
                }
                Group {
                    if commViewModel.currentCommMembers.isEmpty {
                        Text("가입된 유저가 없습니다")
                    } else {
                        Text("\(commViewModel.currentComm?.name ?? "커뮤니티") 유저 목록")
                    }
                }
                .padding(.leading, 30)
                Spacer()
            }
            .padding()
            .tint(.primary)
            if !commViewModel.currentCommMembers.isEmpty {
                ForEach(commViewModel.currentCommMembers) { user in
                    HStack {
                        ZenoProfileVisibleCellView(item: user) {
                            HStack(alignment: .bottom, spacing: 2) {
                                Image(systemName: "person.crop.square.filled.and.at.rectangle")
                                Text("매니저 권한 위임")
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
        .alert("매니저 권한이 변경됩니다.",
               isPresented: $isAlert) {
            Button("변경", role: .destructive) {
                Task {
                    if let selectedUser {
                        await commViewModel.delegateManager(user: selectedUser)
                    }
                }
            }
            Button("취소", role: .cancel) {
                selectedUser = nil
            }
        }
    }
}

struct CommDelegateManagerView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var commViewModel: CommViewModel = .init()
        @State private var isPresented = false
        var body: some View {
            CommDelegateManagerView(isPresented: $isPresented)
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
