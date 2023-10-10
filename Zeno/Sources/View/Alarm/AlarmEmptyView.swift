//
//  AlarmEmptyView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 10/8/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmEmptyView: View {
    @EnvironmentObject var commViewModel: CommViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Image(systemName: "bell.slash")
                .font(.largeTitle)
                .padding()
            
            Text("가입된 커뮤니티가 없습니다.")
                .font(.title3)
        }
        .onAppear {
            if !commViewModel.joinedComm.isEmpty {
                dismiss()
            }
        }
    }
}

struct AlarmEmptyView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmEmptyView()
            .environmentObject(CommViewModel())
    }
}
