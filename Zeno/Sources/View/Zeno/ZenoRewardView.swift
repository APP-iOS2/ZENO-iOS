//
//  ZenoRewardView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct ZenoRewardView: View {
    @EnvironmentObject private var userViewModel: UserViewModel

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                LottieView(lottieFile: "Coin")
                
                Group {
                    Group {
                        Text("20 코인 획득")
                        Text("")
                    }
                    .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 25))
                    
                    Group {
                        Text("다음 제노는")
                        Text("10분 후에 풀 수 있어요")
                    }
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 16))
                }
                .offset(y: -.screenHeight * 0.2)
                
                Spacer()
                
                NavigationLink {
                    FinishZenoView()
                } label: {
                    WideButton(buttonName: "Get Coin", systemImage: "arrowshape.turn.up.forward.fill", isplay: true)
                }
            }
        }
        .task {
            await userViewModel.updateUserCoin(to: 20)
        }
        .navigationBarBackButtonHidden()
    }
}

struct ZenoRewardView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var userViewModel: UserViewModel = .init()
        @StateObject private var commViewModel: CommViewModel = .init()
        @StateObject private var zenoViewModel: ZenoViewModel = .init()
        @StateObject private var mypageViewModel: MypageViewModel = .init()
        @StateObject private var alarmViewModel: AlarmViewModel = .init()
        
        var body: some View {
            TabBarView()
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
