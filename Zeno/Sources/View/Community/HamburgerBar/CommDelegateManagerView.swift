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
                ZenoKFImageView(user)
            }
        }
    }
}

struct CommDelegateManagerView_Previews: PreviewProvider {
    static var previews: some View {
        CommDelegateManagerView()
            .environmentObject(CommViewModel())
    }
}
