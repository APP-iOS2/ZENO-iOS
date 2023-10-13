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
    
    // TODO: private 붙이기
    @State var allMyFriends: [User]
    @State private var users: [User] = []
    @State private var selected: Int = 0
    @State private var answer: [Alarm] = []
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var alarmViewModel: AlarmViewModel
    @EnvironmentObject private var commViewModel: CommViewModel
    
    var body: some View {
        if selected < zenoList.count {
            ZStack {
                /// 백 그라운드 이미지 제트 스택으로 쌓아 둠
                Image(asset: ZenoImages(name: "ZenoBackgroundBasic"))
                    .frame(width: .screenWidth, height: .screenHeight - .screenHeight * 0.2)
                
                /// 프로그래스 바
                VStack(alignment: .center) {
                    ProgressView(value: Double(selected + 1), total: Double(zenoList.count)) {
                        Text("\(selected+1) / \(zenoList.count)")
                    }
                    .opacityAndWhite()
                    .bold()
                    
                    /// 랜덤 제노 퀘스쳔
                    Text(zenoList[selected].question)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 28))
                        .opacityAndWhite()
                        .fixedSize(horizontal: false, vertical: true)

                    /// 랜덤 제노 이미지
                    Image(zenoList[selected].zenoImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: .screenWidth * 0.8, height: .screenHeight * 0.4)
                        .padding([.top, .bottom], 10)
                    
                    Spacer()
                    
                    /// 친구들 버튼 창
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        ForEach(users) { user in
                            Button {
                                /// 제노 문제를 다 풀면 서버에 사용자가 제노를 다 푼 시간을 등록함
                                if selected == zenoList.count-1 {
                                    Task {
                                        await userViewModel.updateZenoTimer()
                                    }
                                }
                                
                                /// 버튼을 누를 때 마다 해당 사용자에게 알림이 감
                                Task {
                                    if let currentUser = userViewModel.currentUser {
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
                                .foregroundColor(.white)
                                .frame(width: .screenWidth * 0.33, height: .screenHeight / 30)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundColor(.white)
                                        .opacity(0.6)
                                )
                            }
                        }
                    }
                    .transaction { view in
                        view.disablesAnimations = true
                    }
                    
                    Button {
                        resetUsers()
                    } label: {
                        Image(systemName: "shuffle")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                    .padding(.top, 15)
                }
                .padding()
                .onAppear {
                    Task {
                        await
                        allMyFriends =
                        userViewModel.IDArrayToUserArrary(idArray: userViewModel.getFriendsInComm(comm: community))
                        resetUsers()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        } else {
            ZenoRewardView()
        }
    }
    
    func resetUsers() {
        if allMyFriends.count >= 4 {
            users = Array(allMyFriends.shuffled().prefix(upTo: 4))
        }
    }
}

struct ZenoView_pro: PreviewProvider {
    @StateObject private var userViewModel: UserViewModel = .init()
    @StateObject private var commViewModel: CommViewModel = .init()

    static var previews: some View {
        ZenoView(zenoList: Array(Zeno.ZenoQuestions.shuffled().prefix(10)), community: Community.emptyComm, allMyFriends: User.dummy)
            .environmentObject(UserViewModel())
            .environmentObject(AlarmViewModel())
            .environmentObject(CommViewModel())
            .onAppear {
                UserViewModel.init(currentUser: User.fakeCurrentUser)
        }
    }
}
