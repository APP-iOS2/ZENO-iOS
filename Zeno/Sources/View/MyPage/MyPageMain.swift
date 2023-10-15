//
//  MyPageMain.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct MyPageMain: View {
    @EnvironmentObject private var mypageViewModel: MypageViewModel
    
    @State private var isShowingSettingView = false
    @State private var isShowingZenoCoin = true // 첫 번째 뷰부터 시작
    @State private var timer: Timer?
    let coinView = CoinView()
    let megaphoneView = MegaphoneView()
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation {
                isShowingZenoCoin.toggle()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
//                    Text("마이페이지")
//                        .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 20))
//                        .font(.footnote)
//                        .foregroundColor(.primary)
                    HStack {
                        Text("마이페이지")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 22))
                            .font(.footnote)
                            .padding(.vertical, 10)
                        Spacer()
                        NavigationLink {
                            MypageSettingView()
                                .environmentObject(mypageViewModel)
                        } label: {
                            Image(systemName: "gearshape")
                                .font(ZenoFontFamily.NanumSquareNeoOTF.light.swiftUIFont(size: 22))
                        }
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 15)
                    HStack {
                        // 유저 프로필 이미지 설정
                        if let imageURLString = mypageViewModel.userInfo?.imageURL, let imageURL = URL(string: imageURLString) {
                            KFImage(imageURL)
                                .placeholder {
                                    Image("ZenoIcon")
                                        .resizable()
                                        .modifier(TextModifier())
                                }
                                .resizable()
                                .modifier(TextModifier())
                        } else {
                            Image("ZenoIcon")
                                .resizable()
                                .modifier(TextModifier())
                        }
                        
//                        Group {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack(spacing: 10) {
                                    Text(mypageViewModel.userInfo?.name ?? "홍길동")
                                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 19))
                                        .fontWeight(.semibold)
                                    
                                    NavigationLink {
                                        UserProfileEdit()
                                    } label: {
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                Text(mypageViewModel.userInfo?.description ?? "안녕하세요. 홍길동입니다.")
                                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                                HStack(spacing: 3) {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .foregroundColor(.red)
                                    Text("\(mypageViewModel.userInfo?.megaphone ?? 0)회   ")
                                    Text("Z")
                                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 18))
//                                        .foregroundColor(Color.purple2)
                                        .foregroundColor(Color.mainColor)
                                        .fontWeight(.bold)
                                    Text("\(mypageViewModel.userInfo?.showInitial ?? 0)회")
                                        .foregroundColor(.primary)
                                }.font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
                            }
//                        }
                        Spacer()
                    }
                    .frame(maxHeight: 120)
                    .foregroundColor(.primary)
                    
                    /// 유저 재화 정보 뷰
                    UserMoneyView()
                        .frame(minHeight: UIScreen.main.bounds.height/9)
                        .padding(.horizontal, 17)

//                    /// 재화정보 스크롤뷰
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 0) {
//                            if isShowingZenoCoin {
//                                coinView
//                            } else {
//                                megaphoneView
//                            }
//                        }
//                        .frame(width: UIScreen.main.bounds.width, height: 60)
//                    }
//                    .background(Color.black)
//                    .onAppear {
//                        startTimer()
//                    }
//                    .onDisappear {
//                        print("⏰ 타이머 끝")
//                        stopTimer()
//                    }
                    GroupSelectView()
                }
            }
            .task {
                await mypageViewModel.getUserInfo()
            }
            .environmentObject(mypageViewModel)
            .foregroundColor(.white)
//            .navigationTitle("마이페이지")
//            .toolbar {
//                ToolbarItem {
//                    NavigationLink {
//                        MypageSettingView()
//                            .environmentObject(mypageViewModel)
//                    } label: {
//                        Image(systemName: "gearshape")
//                            .foregroundColor(.black)
//                    }
//                }
//            }
//            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MyPageMain_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyPageMain()
                .environmentObject(MypageViewModel()) // MypageViewModel 환경 객체 제공
        }
    }
}

struct TextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .frame(width: 120, height: 120)
//            .clipShape(RoundedRectangle(cornerRadius: 30))
            .clipShape(Circle())
            .padding()
    }
}
