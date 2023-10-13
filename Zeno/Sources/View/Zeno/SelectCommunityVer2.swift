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
    @Environment(\.colorScheme) var colorScheme
    
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
                        CardViewVer2(currentIndex: $currentIndex, isPlay: isPlay)
                            .confettiCannon(counter: $counter, num: 50, confettis: [.text("😈"), .text("💜")], openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: .screenWidth * 0.7)
                            .onChange(of: currentIndex) { _ in
                                withAnimation {
                                    ScrollViewProxy.scrollTo(currentIndex, anchor: .top)
                                }
                            }
                    }
                }
                /// 커뮤니티 리스트 뷰
                commuityListView
                    // 3 -> 4, 4 -> 3번째 아이템으로 넘어갈 때 스크롤 이상을 유발함
//                    .offset(y: currentIndex == 0 || currentIndex == 1 ? -.screenWidth * 0.09 : currentIndex == 2 ? -.screenWidth * 0.09 : 0)
                    .background(.clear)
            }
            .overlay {
                VStack {
                    Spacer()
                    VStack {
                        /// isPlay 상태에 따라 달라짐
                        switch isPlay {
                        case .success:
                            NavigationLink {
                                if let community {
                                    ZenoView(zenoList: Array(Zeno.ZenoQuestions.shuffled().prefix(10)), community: community, allMyFriends: allMyFriends)
                                }
                            } label: {
                                WideButton(buttonName: "START", isplay: true)
                            }
                        case .lessThanFour:
                            WideButton(buttonName: "START", isplay: false)
                                .disabled(isPlay != .success)
                        case .notSelected:
                            Text("그룹을 선택해주세요")
                                .foregroundColor(.secondary)
                            WideButton(buttonName: "START", isplay: false)
                                .disabled(isPlay != .success)
                        }
                    }
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 14))
                    .padding(.top, 10)
                    .frame(width: .screenWidth)
                    .background {
                        Blur(style: .light)
                            .opacity(0.8)
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
                        guard value.startLocation.y < .screenHeight * 0.4 else { return }
                        dragWidth = value.translation.width
                    }
                    .onEnded { value in
                        guard value.startLocation.y < .screenHeight * 0.4 else { return }
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
                        select(index: currentIndex)
                        dragWidth = 0
                    }
            )
        }
        .navigationBarBackButtonHidden()
    }
    
    var commuityListView: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(commViewModel.joinedComm.indices),
                        id: \.self) { index in
                    Button {
                        currentIndex = index
                        select(index: index)
                    } label: {
                        HStack {
                            ZenoKFImageView(commViewModel.joinedComm[index])
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .padding(.trailing, 10)
                            Text(commViewModel.joinedComm[index].name)
                                .font(selected == commViewModel.joinedComm[index].id ?
                                      ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 17) :
                                        ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 16))
                                .foregroundColor(.primary.opacity(0.7))
                            
                            Spacer()
                            
                            Image(systemName: "checkmark")
                                .opacity(selected == commViewModel.joinedComm[index].id ? 1 : 0)
                                .padding(.trailing, .screenWidth * 0.05)
                        }
                    }
                    .frame(width: .screenWidth * 0.9)
                    .listRowBackground(EmptyView())
                    .id(commViewModel.joinedComm[index].id)
                }
                Text("가라")
                    .padding()
                    .padding()
                    .foregroundColor(.clear)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .overlay {
                HStack {
                    Spacer()
                    Color.primary
                        .colorInvert()
                        .frame(width: .screenWidth * 0.055)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .onChange(of: currentIndex) { newValue in
                withAnimation {
                    proxy.scrollTo(commViewModel.joinedComm[newValue].id, anchor: .center)
                }
            }
        }
    }
    
    func select(index: Int) {
        selected = commViewModel.joinedComm[index].id
        community = commViewModel.joinedComm[index]
        
        if userViewModel.hasFourFriends(comm: commViewModel.joinedComm[index]) {
            isPlay = .success
        } else {
            isPlay = .lessThanFour
        }
        
        if useConfentti {
            counter += 1
            useConfentti = false
        }
    }
}

struct SelectCommunityVer2_Previews: PreviewProvider {
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
