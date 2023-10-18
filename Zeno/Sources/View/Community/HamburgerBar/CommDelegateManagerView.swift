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
            ZenoNavigationBackBtn {
                dismiss()
            } tailingLabel: {
                HStack {
                    if commViewModel.currentCommMembers.isEmpty {
                        Text("가입된 유저가 없습니다")
                    } else {
                        Text("\(commViewModel.currentComm?.name ?? "커뮤니티") 유저 목록")
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
												   manager: commViewModel.checkManagerUser(user: user)) {
                            HStack(alignment: .bottom, spacing: 2) {
                                Image(systemName: "person.crop.square.filled.and.at.rectangle")
                                Text("매니저 권한 위임")
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
        .alert("매니저 권한이 변경됩니다.",
               isPresented: $isAlert) {
            Button("변경", role: .destructive) {
                Task {
                    if let selectedUser {
                        await delegateManager(user: selectedUser)
                    }
                }
            }
            Button("취소", role: .cancel) {
                selectedUser = nil
            }
        }
    }
    
    @MainActor
    func delegateManager(user: User) async {
        if commViewModel.isCurrentCommManager {
            guard let currentComm = commViewModel.currentComm else { return }
            do {
                try await FirebaseManager.shared.update(data: currentComm, value: \.managerID, to: user.id)
                guard let commIndex = commViewModel.allComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
                commViewModel.allComm[commIndex].managerID = user.id
				commViewModel.managerChangeWarning = true
				self.dismiss()
            } catch {
                print(#function + "매니저 권한 위임 업데이트 실패")
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
