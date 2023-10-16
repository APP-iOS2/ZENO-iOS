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

/// 마이페이지 메인View
struct MyPageMain: View {
    @EnvironmentObject private var mypageViewModel: MypageViewModel
    
    @State private var isShowingSettingView = false
    @State private var isShowingZenoCoin = true // 첫 번째 뷰부터 시작
    @State private var timer: Timer?
    @State private var profileImageURL: String =  ""
    @State private var gender: Gender = .male
    @State private var name: String =  ""
    @State private var description: String = ""
    @State private var showInitial: Int = 0
    private let coinView = CoinView()
    private let megaphoneView = MegaphoneView()

    @ViewBuilder
    private var profileImage: some View {
        if profileImageURL != KakaoAuthService.shared.noneImageURL {
            KFImage(URL(string: profileImageURL))
                .cacheOriginalImage()
                .resizable()
                .placeholder {
                    Image(asset: ZenoAsset.Assets.zenoIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: 150, alignment: .center)
                .aspectRatio(contentMode: .fit)
        } else {
            ZenoKFImageView(User(name: "", gender: gender, kakaoToken: "", coin: 0, megaphone: 0, showInitial: 0, requestComm: []),
                            ratio: .fit,
                            isRandom: false)
            .frame(width: 150, alignment: .center)
        }
    }
    
    private func getUserData() {
        self.name = mypageViewModel.userInfo?.name ?? ""
        self.profileImageURL = mypageViewModel.userInfo?.imageURL ?? ""
        self.gender = mypageViewModel.userInfo?.gender ?? .male
        self.description = mypageViewModel.userInfo?.description ?? ""
        self.showInitial = mypageViewModel.userInfo?.showInitial ?? 0
    }
    
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
                        } label: {
                            Image(systemName: "gearshape")
                                .font(ZenoFontFamily.NanumSquareNeoOTF.light.swiftUIFont(size: 22))
                        }
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 15)
                    
                    HStack {
                        // 유저 프로필 이미지 설정
                        profileImage
                            .modifier(TextModifier())
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 10) {
                                NavigationLink {
                                    UserProfileEdit()
                                } label: {
                                    HStack {
                                        Text(name)
                                            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 19))
                                            .fontWeight(.semibold)
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            }
                            
                            Text(description)
                                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                            
                            HStack {
                                Button {
                                    print("Z 버튼 눌림 기능미정")
                                } label: {
                                    HStack(spacing: 3) {
                                        Text("Z")
                                            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 18))
                                            .foregroundColor(Color.mainColor)
                                            .fontWeight(.bold)
                                        Text("\(showInitial)회")
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
                getUserData()
                await mypageViewModel.fetchAllAlarmData()
                print("⏰⏰ \(mypageViewModel.allAlarmData)")
                print("😈😈 \(mypageViewModel.zenoStringAll)")
                mypageViewModel.zenoStringCalculator()
            }
            .environmentObject(mypageViewModel)
            .foregroundColor(.white)
            .refreshable {
                Task {
                    await mypageViewModel.getUserInfo()
                    getUserData()
                }
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
            .frame(width: 150, alignment: .center)
            .clipShape(Circle())
    }
}
