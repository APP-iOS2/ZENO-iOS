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
    @StateObject private var mypageViewModel = MypageViewModel()
    
    var body: some View {
        NavigationStack {
            MypageNavigationView(mypageViewModel: mypageViewModel)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 유저 프로필
                    UserProfileView(mypageViewModel: mypageViewModel)
                    // 유저 이름
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink {
                            UserProfileEditView(mypageVM: mypageViewModel)
                        } label: {
                            HStack {
                                Text(mypageViewModel.userInfo?.name ?? "zeno")
                                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 16))
                                    .fontWeight(.semibold)
                                Image(systemName: "chevron.right")
                                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
                            }
                        }
                        // 유저 한줄소개
                        Text(mypageViewModel.userInfo?.description ?? "")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
                            .lineSpacing(6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .foregroundColor(.primary)
                    .padding(.bottom, 3)
                    // 유저 친구목록 및 뱃지 현황
                    GroupSelectView(mypageViewModel: mypageViewModel)
                }
            }
            .task {
                await mypageViewModel.getUserInfo()
                await mypageViewModel.fetchAllAlarmData()
                mypageViewModel.zenoStringCalculator()
            }
            .refreshable {
                Task {
                    await mypageViewModel.getUserInfo()
                    await mypageViewModel.fetchAllAlarmData()
                    mypageViewModel.zenoStringCalculator()
                }
            }
        }
        .overlay(
            LargeImageView(isTapped: $mypageViewModel.isTappedImage,
                           imageURL: mypageViewModel.selectImageURL)
        )
    }
}

private struct MypageNavigationView: View {
    @ObservedObject var mypageViewModel: MypageViewModel
    
    var body: some View {
        HStack {
            Text("마이페이지")
                .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 22))
                .font(.footnote)
                .padding(.vertical, 10)
            Spacer()
            NavigationLink {
                MypageSettingView(mypageVM: mypageViewModel)
            } label: {
                Image(systemName: "gearshape")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.light.swiftUIFont(size: 22))
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 15)
    }
}

private struct UserProfileView: View {
    @ObservedObject var mypageViewModel: MypageViewModel
    
    fileprivate var body: some View {
        HStack(spacing: 2) {
            // 유저 프로필 이미지 설정
            if mypageViewModel.userInfo?.imageURL != KakaoAuthService.shared.noneImageURL,
               let userImage = mypageViewModel.userInfo?.imageURL {
                KFImage(URL(string: userImage))
                    .cacheOriginalImage()
                    .placeholder {
                        Image(asset: ZenoAsset.Assets.zenoIcon)
                            .modifier(MypageImageModifier())
                    }
                    .resizable()
                    .imageCustomSizing()
                    .padding(.leading, 18)
            } else {
                ZenoKFImageView(User(name: "", gender: mypageViewModel.userInfo?.gender ?? .female, kakaoToken: "", coin: 0, megaphone: 0, showInitial: 0, requestComm: []),
                                ratio: .fit,
                                isRandom: false)
                .imageCustomSizing()
                .padding(.leading, 18)
            }
            /// 유저 재화 정보 뷰
            UserMoneyView(mypageViewModel: mypageViewModel)
                .frame(minHeight: UIScreen.main.bounds.height/9)
        }
        .frame(height: 150)
    }
}

struct MyPageMain_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyPageMain()
        }
    }
}
