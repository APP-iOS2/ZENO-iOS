//
//  LoginView.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var emailLoginViewModel: EmailLoginViewModel
    @EnvironmentObject private var userViewModel: UserViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Image("bubbleBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                LottieView(lottieFile: "bubbles")
                VStack {
                    Text("zeno")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 80))
                        .foregroundColor(.white)
                        .opacity(0.6)
                    
                    Text("제노로 마음 전달하기")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 18))
                        .foregroundColor(.white)
                        .opacity(0.6)
                        .padding(.bottom, 100)
                }
                .overlay {
                    VStack {
                        Spacer()
                        Button {
                            Task {
//                                await userViewModel.startWithKakao()
                                await LoginManager(delegate: userViewModel).login()
                            }
                        } label: {
                            Image("kakao_login_medium_wide")
                                .padding(.bottom, .screenHeight / 5)
                        }
                    }
                    .frame(width: .screenWidth, height: .screenHeight)
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserViewModel())
            .environmentObject(EmailLoginViewModel())
    }
}
