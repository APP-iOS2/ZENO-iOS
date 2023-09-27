//
//  MyPageMain.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct MyPageMain: View {
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
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Image("Sample")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .padding()
                    VStack(alignment: .leading) {
                        Text("박서연")
                            .font(.system(.title3))
                            .fontWeight(.semibold)
                        Text("저는 사과러버에요.")
                    }
                    Spacer()
                }
                .foregroundColor(.black)
                .padding(.bottom, 30)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        if isShowingZenoCoin {
                            coinView
                        } else {
                            megaphoneView
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 80)
                }
                .background(Color.black)
                .onAppear {
                    startTimer()
                }
                
                UserMoneyView()
                GroupSelectView()
                    .foregroundColor(.black)
            }
        }
        .foregroundColor(.white)
        .navigationTitle("마이페이지")
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
    }
}

struct MyPageMain_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyPageMain()
        }
    }
}
