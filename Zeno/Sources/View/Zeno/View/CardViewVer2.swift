//
//  CardViewVer2.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CardViewVer2: View {
    @Binding var currentIndex: Int
    let isPlay: PlayStatus
    private let itemSize: CGFloat = 200

    @EnvironmentObject var commViewModel: CommViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(commViewModel.joinedComm.indices, id: \.self) { index in
                    VStack {
                        ZenoKFImageView(commViewModel.joinedComm[index])
                            .clipShape(Circle())
                            .frame(width: itemSize, height: itemSize)
                            .overlay {
                                if isPlay == .lessThanFour, currentIndex == index {
                                    ZStack {
                                        Color.black
                                            .opacity(0.65)
                                        Text("그룹 내 친구 수가 \n4명을 넘지 않습니다")
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.white)
                                            .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 16))
                                    }
                                    .clipShape(Circle())
                                }
                            }
                        //                        .overlay(alignment: .centerFirstTextBaseline) {
                        //                            Text(commViewModel.joinedComm[index].name)
                        //                                .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 23))
                        //                                .offset(y: 30)
                        //                                .frame(width: 200)
                        //                                .opacity(currentIndex == index ? 1.0 : 0.3)
                        //                        }
                            .scaleEffect(currentIndex == index ? 0.98 : 0.73)
                        Text(commViewModel.joinedComm[index].name)
                            .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 23))
                            .frame(width: 200)
                            .opacity(currentIndex == index ? 1.0 : 0.3)
                            .background {
                                Blur(style: .light)
                                    .opacity(0.8)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(
                                                colors: [
                                                    .white
                                                        .opacity(0.5),
                                                    .white
                                                        .opacity(0.95)
                                                ]
                                            ),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                    }
                }
            }
            .frame(width: CGFloat(commViewModel.joinedComm.count+1) * itemSize, height: .screenHeight * 0.4)
        }
        .disabled(true)
    }
}

struct CardViewVer2_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var userViewModel: UserViewModel = .init()
        @StateObject private var commViewModel: CommViewModel = .init()
        @StateObject private var zenoViewModel: ZenoViewModel = .init()
        @StateObject private var mypageViewModel: MypageViewModel = .init()
        @StateObject private var alarmViewModel: AlarmViewModel = .init()
        
        var body: some View {
            CardViewVer2(currentIndex: .constant(0), isPlay: .lessThanFour)
                .environmentObject(userViewModel)
                .environmentObject(commViewModel)
                .environmentObject(zenoViewModel)
                .environmentObject(mypageViewModel)
                .environmentObject(alarmViewModel)
                .onAppear {
                    Task {
                        let result = await FirebaseManager.shared.read(type: User.self, id: "neWZ4Vm1VsTH5qY5X5PQyXTNU8g2")
                        switch result {
                        case .success(let user):
                            userViewModel.currentUser = user
                            commViewModel.updateCurrentUser(user: user)
                        case .failure:
                            print("preview 유저로드 실패")
                        }
                    }
                }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
