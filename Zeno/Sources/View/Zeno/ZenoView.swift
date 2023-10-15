//
//  ZenoView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct ZenoView: View {
    let zenoList: [Zeno]
    let community: Community
    let user: [User]
    
    @State private var myFriends: [User] = []
    @State private var selected: Int = 0
    @State private var answer: [Alarm] = []
    @State private var isAnimation: Bool = true
    
    @EnvironmentObject private var alarmViewModel: AlarmViewModel
    @EnvironmentObject private var commViewModel: CommViewModel
    @EnvironmentObject private var zenoViewModel: ZenoViewModel
    
    var body: some View {
        if selected < zenoList.count {
            ZStack {
                /// 백 그라운드 이미지 제트 스택으로 쌓아 둠
                Image(asset: ZenoImages(name: "ZenoBackgroundBasic"))
                    .frame(width: .screenWidth, height: .screenHeight - .screenHeight * 0.2)
                
                /// 로띠쀼
                LottieView(lottieFile: "Bigbubble")
                
                /// 프로그래스 바
                VStack(alignment: .center) {
                    ProgressView(value: Double(selected + 1), total: Double(zenoList.count)) {
                        Text("\(selected+1) / \(zenoList.count)")
                            .foregroundColor(.white)
                    }
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .bold()
                    
                    /// 랜덤 제노 퀘스쳔
                    Text(zenoList[selected].question)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 28))
                        .frame(width: .screenWidth * 0.88,
                               height: .screenHeight * 0.13)
                        .opacityAndWhite()
                        .animation(.easeOut, value: isAnimation)
                        
                    /// 랜덤 제노 이미지
                    Image(zenoList[selected].zenoImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: isAnimation ? .screenWidth * 0.95 : .screenWidth * 0.94
                               , height: .screenHeight * 0.32)
                        .animation(.interpolatingSpring(stiffness: 0.1, damping: 0.1), value: isAnimation)

                    Spacer()
                    
                    /// 친구들 버튼 창
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        ForEach(myFriends) { user in
                            Button {
                                /// 진동
                                HapticManager.instance.impact(style: .soft)
                                /// 제노 문제를 다 풀면 서버에 사용자가 제노를 다 푼 시간을 등록함
                                if selected == zenoList.count-1 {
                                    Task {
                                        await zenoViewModel.updateZenoTimer()
                                    }
                                }
                                
                                /// 버튼을 누를 때 마다 해당 사용자에게 알림이 감
                                Task {
                                    if let currentUser = zenoViewModel.currentUser {
                                        await alarmViewModel.pushAlarm(sendUser: currentUser, receiveUser: user, community: community, zeno: zenoList[selected-1])
                                    }
                                    debugPrint(user.name)
                                    debugPrint(zenoList[selected-1].question)
                                }
                                selected += 1
                                resetUsers()
                            } label: {
                                HStack {
                                    ZenoKFImageView(user)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .foregroundColor(.primary)
                                    Text(user.name)
                                        .foregroundColor(.primary)
                                }
                                .shake(0.8) // 애니메이션 동작 안함
                                .foregroundColor(.white)
                                .frame(width: .screenWidth * 0.33, height: .screenHeight / 30)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundColor(.white)
                                        .opacity(0.6)
                                )
                            }
                            .offset(y: -20)
                        }
                    }
                    /// 버튼 클릭 바뀌는 것 때문에 애니메이션 제어했음.
                    .transaction { view in
                        view.disablesAnimations = true
                    }
                    
                    /// 리셋 버튼
                    Button {
                        resetUsers()
                    } label: {
                        Image(systemName: "shuffle")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                    .offset(y: -5)
                }
                .padding()
            }
            .onAppear {
                resetUsers()
            }
            .navigationBarBackButtonHidden(true)
        } else {
            ZenoRewardView()
        }
    }
    
    func resetUsers() {
        if user.count >= 4 {
            myFriends = Array(user.shuffled().prefix(upTo: 4))
        }
    }
}

struct Zeno_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var userViewModel: UserViewModel = .init()
        @StateObject private var commViewModel: CommViewModel = .init()
        @StateObject private var zenoViewModel: ZenoViewModel = .init()
        @StateObject private var mypageViewModel: MypageViewModel = .init()
        @StateObject private var alarmViewModel: AlarmViewModel = .init()
        
        var body: some View {
            TabBarView()
                .edgesIgnoringSafeArea(.vertical)
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
