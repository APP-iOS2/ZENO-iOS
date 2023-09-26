//
//  SelectCommunityView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct SelectCommunityView: View {
    private let communities = Community.CommunitySamples
    
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
                                .padding(.bottom, 20)
                            
                        } else {
                            VStack {
                                Text(communityName)
                                NavigationLink {
                                    ZenoView()
                                } label: {
                                    Text("Start")
                                        .padding(.leading, .screenWidth * 0.7)
                                        .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    
                    /// 그룹들 나오는 뷰
                    commuityListView()
                        .padding(.top,10)
                    
                    /// 카드 뷰
                    ScrollViewReader { ScrollViewProxy in
                        ZStack {
                            cardView()
                                .onChange(of: selected) { _ in
                                    print("onChanged")
                                    withAnimation {
                                        ScrollViewProxy.scrollTo(selected, anchor: .top)
                                }
                            }
                    
                            LottieView(lottieFile: "beforeZeno")
                                .frame(width: .screenWidth * 0.5, height: .screenHeight * 0.3)
                                .offset(x: -.screenWidth/3, y: .screenHeight/5.2)
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
        .frame(width: 100, height: 40 * CGFloat(communities.count + 4))
    }
    
    func cardView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(communities) { community in
                    GeometryReader { geometry in
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .opacity(0.7)
                            VStack {
                                Image(community.communityImage)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .scaledToFit()
                                Text(community.communityName)
                                    .padding(20)
                                    .foregroundColor(.white)
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
            .frame(width: CGFloat(Community.CommunitySamples.count) * 510 )
        }
    }
}

struct SelectCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        SelectCommunityView()
    }
}
