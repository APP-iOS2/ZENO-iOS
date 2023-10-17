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
                    
                    Text("제노는어쩌구저쩌구야")
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
                                await userViewModel.startWithKakao()
                            }
                        } label: {
                            loginButtonLabel(title: "카카오톡 로그인", tintColor: .white, backgroundColor: .yellow)
                        }
                        NavigationLink {
                            EmailLoginView()
                        } label: {
                            loginButtonLabel(title: "이메일 로그인", tintColor: .black, backgroundColor: Color(.systemGray5))
                        }
                        .padding(.bottom, .isIPhoneSE ? 30 : 50)
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
