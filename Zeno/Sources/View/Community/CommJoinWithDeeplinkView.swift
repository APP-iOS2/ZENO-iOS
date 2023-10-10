//
//  CommJoinWithDeeplinkView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/09.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommJoinWithDeeplinkView: View {
    @Binding var isPresented: Bool
    let comm: Community
    
    @EnvironmentObject private var commViewModel: CommViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            ZenoKFImageView(comm)
            Text(comm.name)
                .font(.headline)
            Text("\(comm.joinMembers.count)명 참여중")
                .font(.caption)
            HStack(alignment: .center) {
                Button("가입하기", role: ButtonRole.destructive) {
                    Task {
                        await commViewModel.joinCommWithDeeplink(commID: comm.id)
                        try? await userViewModel.loadUserData()
                    }
                    isPresented = false
                }
                Button("취소", role: .cancel) {
                    isPresented = false
                }
            }
        }
    }
}

struct CommJoinWithDeeplinkView_Previews: PreviewProvider {
    static var previews: some View {
        CommJoinWithDeeplinkView(isPresented: .constant(true), comm: .emptyComm)
            .environmentObject(CommViewModel())
    }
}
