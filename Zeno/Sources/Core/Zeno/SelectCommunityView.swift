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
//                RadialGradient(gradient: Gradient(colors: [.mainColor, .purple]), center: .center, startRadius: 3, endRadius: 600).ignoresSafeArea()
                
                VStack {
                    Group {
                        if isPlay == false {
                            Text("제노를 플레이 할 그룹을 선택해주세요")
                                .selectCommunity()
                        } else {
                            VStack {
                                Text(communityName)
                                    .selectCommunity()
                                NavigationLink {
                                    ZenoView()
                                } label: {
                                    Text("Start")
                                        .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                                        .foregroundColor(.white)
                                }
                                .padding(.top, 3)
                            }
                        }
                    }
                    
                    /// 카드 뷰
                    ScrollViewReader { ScrollViewProxy in
                        ZStack {
                            cardView()
                                .onChange(of: selected) { _ in
                                    withAnimation {
                                        ScrollViewProxy.scrollTo(selected, anchor: .top)
                                    }
                                }
                            
                            LottieView(lottieFile: "nudgeDevil")
                                .frame(width: 50, height: 50)
                                .offset(x: 150, y: -90)
                        }
                        
                        /// 그룹들 나오는 뷰
                        ZStack {
                            commuityListView()
                                .padding(.top, 10)
                                    
                            LottieView(lottieFile: "beforeZeno")
                                .frame(width: .screenWidth * 0.56, height: .screenHeight * 0.3)
                                .offset(x: -.screenWidth/3, y: .screenHeight/3.8)
                        }
                    }
                }
            }
            .offset(y: -30)
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
                                .foregroundColor(.white)
                                .opacity(0.8)
                            
                            HStack {
                                Image(community.communityImage)
                                    .resizable()
                                    .opacity(0.8)
                                    .frame(width: 100, height: 100)
                                    .scaledToFit()
                                VStack(alignment: .leading) {
                                    Text(community.communityName)
                                        .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 17))
                                        .padding(.bottom, 3)
                                    Text(wrapText(description: community.description, maxLineLength: 13))
                                        .font(ZenoFontFamily.NanumBarunGothicOTF.ultraLight.swiftUIFont(size: 15))
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        .frame(width: 300, height: 200)
                        .id(community.id)
                        .rotation3DEffect(
                            Angle(degrees: getPercentage(geo: geometry) * 40),
                            axis: (x: 0.0, y: 0.1, z: 0.0)
                        )
                    }
                    .frame(width: 300, height: 200)
                    .padding()
                }
            }
            .frame(width: CGFloat(Community.CommunitySamples.count) * 586 )
        }
    }
}

func wrapText(description: String, maxLineLength: Int) -> String {
    var result = ""
    var line = ""
    let words = description.components(separatedBy: " ")
    
    for word in words {
        if line.count + word.count <= maxLineLength {
            line += word + " "
        } else {
            result += line + "\n"
            line = word + " "
        }
    }
    
    if !line.isEmpty {
        result += line
    }
    
    return result
}

struct SelectCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        SelectCommunityView()
    }
}
