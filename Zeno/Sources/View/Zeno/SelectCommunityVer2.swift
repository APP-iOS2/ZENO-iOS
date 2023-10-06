//
//  SelectCommunityVer2.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/04.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import ConfettiSwiftUI

struct SelectCommunityVer2: View {
    @EnvironmentObject private var userViewModel: UserViewModel

    @State private var stack = NavigationPath()
    @State private var isPlay: Bool = false
    @State private var communityName: String = ""
    @State private var selected = ""
    @State private var currentIndex: Int = 0
    @State private var counter: Int = 0
    @State private var useConfentti: Bool = true
    @State var isSheetOn: Bool = false
    
    private let communities = Community.dummy
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { ScrollViewProxy in
                    CardViewVer2(currentIndex: currentIndex)
                        .confettiCannon(counter: $counter, num: 50, confettis: [.text("😈"), .text("💜")], openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: .screenWidth * 0.7)
                        .onChange(of: currentIndex) { _ in
                            withAnimation {
                                ScrollViewProxy.scrollTo(currentIndex, anchor: .top)
                            }
                        }
                        .offset(y: .screenHeight * 0.04)
                        .offset(x: currentIndex == 0 ? .screenWidth * 0.18 : 0 )
                        .offset(x: currentIndex == 5 ? -.screenWidth * 0.25 : 0 )
                }
                commuityListView()
                    .background(.clear)
                
                VStack {
                    if isPlay == false {
                        Text("그룹을 선택해주세요")
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                        WideButton(buttonName: "START", isplay: isPlay)
                    } else {
                        NavigationLink {
                            ZenoView(zenoList: Array(Zeno.ZenoQuestions.shuffled().prefix(10)), allMyFriends: User.dummy)
                        } label: {
                            WideButton(buttonName: "START", isplay: isPlay)
                        }
                    }
                }
                .offset(y: -20)
                .disabled(isPlay == false)
            }
        }
    }
    
    func commuityListView() -> some View {
        List(communities.indices) { index in
            Button {
                isPlay = true
                selected = communities[index].id
                communityName = communities[index].name
                currentIndex = index
                if useConfentti {
                    counter += 1
                    useConfentti = false
                }
            } label: {
                HStack {
                    Image(asset: ZenoImages(name: communities[index].imageURL ?? ""))
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.trailing, 10)
                    Text(communities[index].name)
                        .font(selected == communities[index].id ? ZenoFontFamily.NanumBarunGothicOTF.bold.swiftUIFont(size: 17) : ZenoFontFamily.NanumBarunGothicOTF.regular.swiftUIFont(size: 15))
                        .foregroundColor(.black.opacity(0.7))
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(selected == communities[index].id ? 1 : 0)
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
    static var previews: some View {
        SelectCommunityVer2()
            .environmentObject(UserViewModel())
    }
}
