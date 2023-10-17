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
                        .frame(width: 120, alignment: .center)
                }
                .frame(width: 120, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .padding(.leading, 18)
        } else {
            ZenoKFImageView(User(name: "", gender: gender, kakaoToken: "", coin: 0, megaphone: 0, showInitial: 0, requestComm: []),
                            ratio: .fit,
                            isRandom: false)
            .frame(width: 120, alignment: .center)
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .padding(.leading, 18)
        }
    }
    
    private func getUserData() {
        self.name = mypageViewModel.userInfo?.name ?? "박서연"
        self.profileImageURL = mypageViewModel.userInfo?.imageURL ?? ""
        self.gender = mypageViewModel.userInfo?.gender ?? .male
        self.description = mypageViewModel.userInfo?.description ?? "한줄소개테스트입니당 여러줄이면 어떻게 되는지 모르겠어요. 글자수 제한은 50자로 해도 될것 같아요!"
        self.showInitial = mypageViewModel.userInfo?.showInitial ?? 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
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
                    
                    HStack(spacing: 2) {
                        // 유저 프로필 이미지 설정
                        profileImage
                        /// 유저 재화 정보 뷰
                        UserMoneyView()
                            .frame(minHeight: UIScreen.main.bounds.height/9)
                    }
                    .frame(height: 150)
                    VStack(alignment: .leading, spacing: 8) {
                        // 유저 이름
                        HStack(spacing: 10) {
                            NavigationLink {
                                UserProfileEdit()
                            } label: {
                                HStack {
                                    Text(name)
                                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 16))
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
                                }
                            }
                        }
                        // 유저 한줄소개
                        Text(description)
                            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
                            .lineSpacing(6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .foregroundColor(.primary)
                    .onAppear {
                        print("💟 \(mypageViewModel.zenoStringImage)")
                    }
                    .padding(.bottom, 3)
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
