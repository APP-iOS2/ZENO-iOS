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
                Image(asset: ZenoImages(name: "ZenoBackgroundBasic"))
                    .frame(width: .screenWidth, height: .screenHeight - .screenHeight * 0.2)
                
                VStack(alignment: .center) {
                    ProgressView(value: Double(selected + 1), total: Double(zenoList.count)) {
                        Text("\(selected+1) / \(zenoList.count)")
                    }
                    .opacityAndWhite()
                    .bold()
                    
                    Text(zenoList[selected].question)
                        .fixedSize(horizontal: false, vertical: true)
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
                                    Task {
                                        await userViewModel.updateZenoTimer()
                                    }
                                }
                                
                                Task {
                                    await alarmViewModel.pushAlarm(sendUser: userViewModel.currentUser!, receiveUser: user, community: community, zeno: zenoList[selected-1])
                                    debugPrint(user.name)
                                    debugPrint(zenoList[selected-1].question)
                                }
                                
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
                    // MARK: 제노 뷰
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

//   (.init(sendUserID: loggedUser.id, sendUserName: loggedUser.name, recieveUserID: user.id, recieveUserName: user.name, communityID: Community.dummy[0].id, zenoID: zenoList[selected].id, zenoString: zenoList[selected].question, createdAt: Date.timeIntervalSinceReferenceDate))

//struct ZenoView_pro: PreviewProvider {
//    static var previews: some View {
//        ZenoView(zenoList: Array(Zeno.ZenoQuestions.shuffled().prefix(10)), allMyFriends: User.dummy, community: Community.emptyComm)
//            .environmentObject(UserViewModel())
//            .environmentObject(AlarmViewModel())
//    }
//}
