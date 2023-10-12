//
//  SelectCommunityVer2.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/04.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import ConfettiSwiftUI

// MARK: ZVM에 넣어야함
enum PlayStatus {
    case success
    case lessThanFour
    case notSelected
}

struct SelectCommunityVer2: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var commViewModel: CommViewModel
    
    @State private var stack = NavigationPath()
    @State private var isPlay: PlayStatus = .notSelected
    @State private var community: Community?
    @State private var allMyFriends: [User] = []
    @State private var selected = ""
    @State private var currentIndex: Int = 0
    @State private var counter: Int = 0
    @State private var useConfentti: Bool = true
    @State private var dragWidth: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { ScrollViewProxy in
                    ZStack {
                        LottieView(lottieFile: "wave")
                            .offset(y: -20)
                        
                        CardViewVer2(currentIndex: $currentIndex)
                            .offset(y: -.screenHeight * 0.03)
                            .confettiCannon(counter: $counter, num: 50, confettis: [.text("😈"), .text("💜")], openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: .screenWidth * 0.7)
                            .onChange(of: currentIndex) { _ in
                                withAnimation {
                                    ScrollViewProxy.scrollTo(currentIndex, anchor: .top)
                                }
                            }
                    }
                    .frame(height: .screenHeight * 0.35)
                }
                
                commuityListView()
                    .frame(height: .screenHeight * 0.3)
                    .background(.clear)
                
                Spacer()
                
                VStack {
                    switch isPlay {
                    case .success:
                        NavigationLink {
                            ZenoView(zenoList: Array(Zeno.ZenoQuestions.shuffled().prefix(10)), community: community!, allMyFriends: allMyFriends)
                        } label: {
                            WideButton(buttonName: "START", isplay: true)
                        }
                    case .lessThanFour:
                        Text("그룹 내 친구 수가 4명을 넘지 않습니다")
                            .foregroundColor(.red)
                            .offset(y: -20)
                        WideButton(buttonName: "START", isplay: false)
                            .disabled(isPlay != .success)
                    case .notSelected:
                        Text("그룹을 선택해주세요")
                            .foregroundColor(.secondary)
                            .offset(y: -20)
                        WideButton(buttonName: "START", isplay: false)
                            .disabled(isPlay != .success)
                    }
                }
            }
            .onAppear {
                currentIndex = 0
                selected = ""
                isPlay = .notSelected
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard value.startLocation.y < .screenHeight * 0.3 else { return }
                        dragWidth = value.translation.width
                    }
                    .onEnded { value in
                        guard value.startLocation.y < .screenHeight * 0.3 else { return }
                        if value.translation.width > 0 {
                            guard currentIndex > 0 else { return }
                            currentIndex -= 1
                        } else if value.translation.width < 0 {
                            guard currentIndex < commViewModel.joinedComm.count - 1 else { return }
                            currentIndex += 1
                        } else {
                            currentIndex = currentIndex
                            return
                        }
                        selected = commViewModel.joinedComm[currentIndex].id
                        community = commViewModel.joinedComm[currentIndex]
                        dragWidth = 0
                        if userViewModel.hasFourFriends(comm: commViewModel.joinedComm[currentIndex]) {
                            isPlay = .success
                        } else {
                            isPlay = .lessThanFour
                        }
                        
                        if useConfentti {
                            counter += 1
                            useConfentti = false
                        }
                    }
            )
        }
        .navigationBarBackButtonHidden()
    }
    
    func commuityListView() -> some View {
        List(Array(commViewModel.joinedComm.indices), id: \.self) { index in
            Button {
                selected = commViewModel.joinedComm[index].id
                community = commViewModel.joinedComm[index]
                currentIndex = index
//                Task {
//                    allMyFriends = await userViewModel.IDArrayToUserArrary(idArray: userViewModel.getFriendsInComm(comm: community ?? Community.dummy[1]))
//                }
                if userViewModel.hasFourFriends(comm: commViewModel.joinedComm[index]) {
                    isPlay = .success
                } else {
                    isPlay = .lessThanFour
                }
                
                if useConfentti {
                    counter += 1
                    useConfentti = false
                }
            } label: {
                HStack {
                    ZenoKFImageView(commViewModel.joinedComm[index])
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.trailing, 10)
                    Text(commViewModel.joinedComm[index].name)
                        .font(selected == commViewModel.joinedComm[index].id ? ZenoFontFamily.NanumBarunGothicOTF.bold.swiftUIFont(size: 17) : ZenoFontFamily.NanumBarunGothicOTF.regular.swiftUIFont(size: 15))
                        .foregroundColor(.primary.opacity(0.7))
                    
                    Spacer()
                    
                    Image(systemName: "checkmark")
                        .opacity(selected == commViewModel.joinedComm[index].id ? 1 : 0)
                        .offset(x: 31)
                }
                .frame(width: .screenWidth * 0.8)
            }
            .listRowBackground(EmptyView())
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct SelectCommunityVer2_Previews: PreviewProvider {
    @EnvironmentObject private var userViewModel: UserViewModel
    
    static var previews: some View {
        SelectCommunityVer2()
            .environmentObject(UserViewModel())
            .environmentObject(CommViewModel())
            .onAppear {
                UserViewModel.init(currentUser: User.fakeCurrentUser)
            }
    }
}
