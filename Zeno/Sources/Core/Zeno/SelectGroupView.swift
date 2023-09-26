//
//  SelectGroupView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct SelectGroupView: View {
    private let communities = Community.CommunitySamples
    @State private var isPlay: Bool = false
    @State private var communityName: String = ""
    
    var body: some View {
        ZStack {
            Image(asset: ZenoImages(name: "ZenoBackgroundBasic"))
            
            VStack {
                customScrollView(isplay: $isPlay, commuintyName: $communityName)
                if isPlay == false {
                    Text("제노를 플레이 할 그룹을 선택해주세요")
                        .selectCommunity()
                } else {
                    VStack{
                        Text(communityName)
                            .selectCommunity()
                        Button {
                            // 버튼 동작 추가
                        } label: {
                            Text("go")
                        }
                    }
                }
            }
            .offset(y: -40)
            
            LottieView(lottieFile: "beforeZeno")
                .frame(width: 300, height: 300)
                .offset(x: -.screenWidth/3, y: .screenHeight/2.7)
        }
        .ignoresSafeArea()
    }
}

@ViewBuilder
func customScrollView(isplay: Binding<Bool>, commuintyName: Binding<String>) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack {
            ForEach(0..<30, id: \.self) { index in
                GeometryReader { geometry in
                    let communityIndex = index % Community.CommunitySamples.count
                    let community = Community.CommunitySamples[communityIndex]
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                        VStack {
                            Text(community.communityName)
                                //.font(ZenoFontFamily.NanumBarunGothicOTF.bold.swiftUIFont(size: 30))
                                .padding(20)
                                .foregroundColor(.white)
                            Image(community.communityImage)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .scaledToFit()
                                .clipShape(Circle())
                        }
                    }
                    .onTapGesture {
                        isplay.wrappedValue = true
                        commuintyName.wrappedValue = community.communityName
                    }
                    .rotation3DEffect(
                        Angle(degrees: getPercentage(geo: geometry) * 40),
                        axis: (x: 0.0, y: 0.1, z: 0.0)
                    )
                }
                .frame(width: 300, height: 250)
                .padding()
            }
        }
    }
}

func getPercentage(geo: GeometryProxy) -> Double {
    let maxDistance = UIScreen.main.bounds.width / 2
    let currentX = geo.frame(in: .global).midX
    return 1.0 - (currentX / maxDistance)
}

struct SelectGroupView_Previews: PreviewProvider {
    static var previews: some View {
        SelectGroupView()
    }
}
