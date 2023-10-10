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
    let allMyFriends: [User]
    let loggedUser: User = .dummy[0]
    
    @State private var users: [User] = []
    @State private var selected: Int = 0
    @State private var answer: [Alarm] = []
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var alarmViewModel: AlarmViewModel
    @StateObject private var zenoViewModel: ZenoViewModel = ZenoViewModel()
    
    var body: some View {
        if selected < zenoList.count {
            ZStack {
                Image(asset: ZenoImages(name: "ZenoBackgroundBasic"))
                    .frame(width: .screenWidth, height: .screenHeight - .screenHeight * 0.2)
                
                VStack(alignment: .center) {
                    ProgressView(value: Double(selected + 1), total: Double(zenoList.count)) {
                        Text("\(selected+1) / \(zenoList.count)")
                    }
                    .opacityAndWhite()
                    .bold()
                    
                    Text(zenoList[selected].question)
                        .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 28))
                        .opacityAndWhite()
                    
                    Image(zenoList[selected].zenoImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: .screenWidth * 0.8, height: .screenHeight * 0.4)
                        .padding([.top, .bottom], 10)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        ForEach(users) { user in
                            Button {
                                if selected == zenoList.count-1 {
                                    Task { // 뷰에서 사용할때는 Task블럭 안에서 async사용해야함
                                        await userViewModel.updateZenoTimer()
                                    }
                                }
                                // TODO: sendUser 는 로그인 된 현재 유저, receiveUser 는 퀴즈에서 선택한 유저, 현재 선택된 Community, 지금 풀고있는 zeno 를 입력해주시면 감사하겠습니다.
//                                Task {
//                                    await alarmViewModel.pushAlarm(sendUser: <#T##User#>, receiveUser: user, community: <#T##Community#>, zeno: <#T##Zeno#>)
//                                }
                                selected += 1
                                resetUsers()
                            } label: {
                                HStack {
                                    ZenoKFImageView(user)
                                        .frame(width: 40, height: 40)
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
                    resetUsers()
                }
            }
            .navigationBarBackButtonHidden(true)
        } else {
            ZenoRewardView()
        }
    }
    
    func resetUsers() {
        users = Array(allMyFriends.shuffled().prefix(upTo: 4))
    }
}

//   (.init(sendUserID: loggedUser.id, sendUserName: loggedUser.name, recieveUserID: user.id, recieveUserName: user.name, communityID: Community.dummy[0].id, zenoID: zenoList[selected].id, zenoString: zenoList[selected].question, createdAt: Date.timeIntervalSinceReferenceDate))

struct ZenoView_pro: PreviewProvider {
    static var previews: some View {
        ZenoView(zenoList: Array(Zeno.ZenoQuestions.shuffled().prefix(10)), allMyFriends: User.dummy)
            .environmentObject(UserViewModel())
            .environmentObject(AlarmViewModel())
    }
}
