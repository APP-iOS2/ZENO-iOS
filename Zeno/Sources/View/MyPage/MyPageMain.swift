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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
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
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 10) {
                                NavigationLink {
                                    UserProfileEdit()
                                } label: {
                                    Text(mypageViewModel.userInfo?.name ?? "홍길동")
                                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 19))
                                        .fontWeight(.semibold)
                                }
                                NavigationLink {
                                    UserProfileEdit()
                                } label: {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            Text(mypageViewModel.userInfo?.description ?? "안녕하세요. 홍길동입니다.")
                                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                            HStack {
                                Button {
                                    print("button tapped")
                                } label: {
                                    HStack(spacing: 3) {
                                        Text("Z")
                                            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 18))
                                            .foregroundColor(Color.mainColor)
                                            .fontWeight(.bold)
                                        Text("\(mypageViewModel.userInfo?.showInitial ?? 0)회")
                                            .foregroundColor(.primary)
                                    }.font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
                                }
                                Button {
                                    print("info button tapped!")
                                } label: {
                                    InformationButtonView()
                                }
                            }
                        }
                        Spacer()
                    }
                    .frame(maxHeight: 120)
                    .foregroundColor(.primary)
                    .onAppear {
//                        mypageViewModel.zenoImageArray()
                        print("💟 \(mypageViewModel.zenoStringImage)")
                    }
                    /// 유저 재화 정보 뷰
                    UserMoneyView()
                        .frame(minHeight: UIScreen.main.bounds.height/9)
                        .padding(.horizontal, 17)
                    GroupSelectView()
                }
            }
            .task {
                await mypageViewModel.getUserInfo()
                await mypageViewModel.fetchAllAlarmData()
                print("⏰⏰ \(mypageViewModel.allAlarmData)")
                print("😈😈 \(mypageViewModel.zenoStringAll)")
                mypageViewModel.zenoStringCalculator()
            }
            .environmentObject(mypageViewModel)
            .foregroundColor(.white)
            .refreshable {
                await mypageViewModel.getUserInfo()
            }
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
