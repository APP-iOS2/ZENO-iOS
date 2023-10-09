//
//  ZenoView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//
// TODO: 애니메이션 1초 -> 버튼 나누기 (친구 클릭하면 애니메이션 추가하는 방향) 
import SwiftUI
import Kingfisher

struct ZenoView: View {
    let zenoList: [Zeno]
    let allMyFriends: [User]
    let loggedUser: User = .dummy[0]
    
    @State private var users: [User] = []
    @State private var selected: Int = 0
    @State private var answer: [Alarm] = []
    
    @EnvironmentObject private var userViewModel: UserViewModel
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
                                selected += 1
                                resetUsers()
                            } label: {
                                HStack {
                                    ZenoKFImageView(user)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.black)
                                    Text(user.name)
                                        .foregroundColor(.black)
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
    }
}
