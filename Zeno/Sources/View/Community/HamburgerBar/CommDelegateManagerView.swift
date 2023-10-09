//
//  CommDelegateManagerView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/09.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommDelegateManagerView: View {
    @EnvironmentObject private var commViewModel: CommViewModel
    var body: some View {
        ScrollView {
            ForEach(commViewModel.currentCommMembers) { user in
                HStack {
                    ZenoSearchableCellView(item: user, actionTitle: "매니저 권한 위임") {
                        Task {
                            await commViewModel.delegateManager(user: user)
                        }
                    }
                }
            }
        }
    }
}

struct CommDelegateManagerView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var commViewModel: CommViewModel = .init()
        
        var body: some View {
            CommDelegateManagerView()
                .environmentObject(commViewModel)
                .onAppear {
                    commViewModel.currentCommMembers = [.fakeCurrentUser]
                }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
