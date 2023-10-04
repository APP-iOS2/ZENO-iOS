//
//  ZenoSelectCommunityView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct ZenoSelectCommunityView: View {
    private let communities = Community.dummy
    
    @State private var isPlay: Bool = false
    @State private var communityName: String = ""
    @State private var selected = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image(asset: ZenoImages(name: "ZenoBackgroundBasic"))
                VStack {
                    Group {
                        LottieView(lottieFile: "nudgeDevil")
                            .frame(width: 50, height: 50)
                        if isPlay == false {
                            Text("제노를 플레이 할 그룹을 선택해주세요")
                        } else {
                            VStack {
                                Text(communityName)
                                NavigationLink {
                                    ZenoView(zenoList: Array(Zeno.ZenoQuestions.shuffled().prefix(10)), allMyFriends: User.dummy)
                                } label: {
                                    Text("Start")
                                        .padding(.leading, .screenWidth * 0.7)
                                        .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    /// 그룹들 나오는 뷰
                    commuityListView()
                    
                    /// 카드 뷰
                    ScrollViewReader { ScrollViewProxy in
                        cardView()
                            .onChange(of: selected) { _ in
                                print("onChanged")
                                withAnimation {
                                    ScrollViewProxy.scrollTo(selected, anchor: .top)
                            }
                        }
                    }
                }
            }
            .onAppear {
                isPlay = false
            }
        }
    }
    
    func commuityListView() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(communities) { community in
                    Button {
                        isPlay = true
                        selected = community.id
                        communityName = community.communityName
                    } label: {
                        CommuintyCellView(community: community)
                    }
                }
            }
        }
        .frame(width: 100, height: .screenHeight * 0.4)
    }
    
    func cardView() -> some View {
            TabView {
                ForEach(Community.dummy) { community in
                    GeometryReader { geometry in
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .opacity(0.7)
                            VStack {
                                Text(community.communityName)
                                    .padding(20)
                                    .foregroundColor(.white)
                                Image(community.communityImage)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .scaledToFit()
                            }
                        }
                        .frame(width: 180, height: 150)
                        .id(community.id)
                        .rotation3DEffect(
                            Angle(degrees: getPercentage(geo: geometry) * 40),
                            axis: (x: 0.0, y: 0.1, z: 0.0)
                        )
                    }
                    .frame(width: 180, height: 150)
                    .padding()
                }
            }
            .frame(width: .screenWidth, height: .screenHeight * 0.3)
            .tabViewStyle(PageTabViewStyle())
        }
    }

struct ZenoSelectCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        ZenoSelectCommunityView()
    }
}
