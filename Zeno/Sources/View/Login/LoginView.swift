//
//  LoginView.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var emailLoginViewModel: EmailLoginViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject var appleLoginViewModel = AppleLoginViewModel()
    
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
                            HStack(spacing: 5) {
                                Image("kakaotalkLogo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                Text("카카오 로그인")
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .screenWidth * 0.78, maxHeight: .screenHeight/20)
                            .background(Color.hex("FAE100"))
                            .cornerRadius(10)
                        }
                        
                        SignInWithAppleButton { request in
                            appleLoginViewModel.handleSignInWithAppleRequest(request)
                        } onCompletion: { result in
                            appleLoginViewModel.result = result
                            Task {
                                await LoginManager(delegate: appleLoginViewModel).login()
                            }
//                            appleLoginViewModel.handleSignInWithAppleCompletion(result)
                        }
                        .frame(maxWidth: .screenWidth * 0.78, maxHeight: .screenHeight/20)
                        .padding(.bottom, .screenHeight / 7)
                        .cornerRadius(10)
                    }
                    .frame(width: .screenWidth, height: .screenHeight)
                    .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            appleLoginViewModel.userVM = userViewModel
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
