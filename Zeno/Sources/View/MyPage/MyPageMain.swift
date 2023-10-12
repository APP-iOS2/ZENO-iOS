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
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 5) {
                                Text(mypageViewModel.userInfo?.name ?? "홍길동")
                                    .font(.system(.title2))
                                    .fontWeight(.semibold)
                                
                                NavigationLink {
                                    UserProfileEdit()
                                } label: {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            Text(mypageViewModel.userInfo?.description ?? "안녕하세요. 홍길동입니다.")
                                .font(.system(size: 18))
                        }
                        Spacer()
                    }
                    .foregroundColor(.black)
                    /// 유저 재화 정보 뷰
                    UserMoneyView()
                        .frame(minHeight: UIScreen.main.bounds.height/9)

                    /// 재화정보 스크롤뷰
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            if isShowingZenoCoin {
                                coinView
                            } else {
                                megaphoneView
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 60)
                    }
                    .background(Color.black)
                    .onAppear {
                        startTimer()
                    }
                    .onDisappear {
                        print("⏰ 타이머 끝")
                        stopTimer()
                    }
                    GroupSelectView()
                }
            }
            .task {
                await mypageViewModel.getUserInfo()
            }
            .environmentObject(mypageViewModel)
            .foregroundColor(.white)
            .navigationTitle("마이페이지")
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        MypageSettingView()
                            .environmentObject(mypageViewModel)
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.black)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding()
    }
}
