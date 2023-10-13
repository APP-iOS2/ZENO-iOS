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
        ZStack {
            LottieView(lottieFile: "bubbles")
            
            VStack {
                Image(systemName: "person.fill.xmark")
                    .resizable()
                    .frame(width: 80, height: 54)
                    .foregroundColor(.ggullungColor)
                    .padding(.bottom, 3)
                
                Text("가입된 커뮤니티가 없습니다")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 17))
                    .foregroundColor(.ggullungColor)
            }
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
