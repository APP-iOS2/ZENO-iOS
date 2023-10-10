//
//  MyPageMain.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct MyPageMain: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var isShowingSettingView = false
    @State private var isShowingZenoCoin = true // 첫 번째 뷰부터 시작
    
    let coinView = CoinView()
    let megaphoneView = MegaphoneView()
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation {
                isShowingZenoCoin.toggle()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        AsyncImage(url: URL(string: (userViewModel.currentUser?.imageURL) ?? "https://k.kakaocdn.net/dn/dpk9l1/btqmGhA2lKL/Oz0wDuJn1YV2DIn92f6DVK/img_640x640.jpg")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .padding()
                        } placeholder: {
                            ProgressView()
                        }
//                        Image("\(userViewModel.currentUser?.imageURL)")
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 100, height: 100)
//                            .clipShape(RoundedRectangle(cornerRadius: 30))
//                            .padding()
                        VStack(alignment: .leading) {
                            HStack {
                                Text(userViewModel.currentUser?.name ?? "이름")
                                    .font(.system(.title3))
                                    .fontWeight(.semibold)
                                
                                NavigationLink {
                                    UserProfileEdit()
                                } label: {
                                    Image(systemName: "greaterthan")
                                }
                            }
                            Text("저는 사과러버에요.")
                        }
                        Spacer()
                        
                        //                        Spacer()
                    }
                    .foregroundColor(.black)
                    //					.padding(.bottom, 30)
                    
                    UserMoneyView()
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
                    GroupSelectView()
                        .foregroundColor(.black)
                }
            }
            .foregroundColor(.white)
            .navigationTitle("마이제노")
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        MypageSettingView()
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
                .environmentObject(UserViewModel())
        }
    }
}
