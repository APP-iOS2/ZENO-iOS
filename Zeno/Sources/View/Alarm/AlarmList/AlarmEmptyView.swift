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
    @State private var isPresented: Bool = true
    
    var body: some View {
        ZStack {
            if isPresented {
                Rectangle()
                    .fill(.black.opacity(0.5))
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
            }
            
            VStack {
                LottieView(lottieFile: "register2")
                    .frame(width: .screenWidth * 0.3, height: .screenHeight * 0.1)
                
                Text("가입된 커뮤니티가 없습니다")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 14))
                    .foregroundColor(.ggullungColor)
                    .padding(.top, 10)
            }
            
            LottieView(lottieFile: "click")
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(150))
                .offset(x: .screenWidth * 0.1, y: .screenHeight * 0.4)
                .opacity(isPresented ? 1 : 0)
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
