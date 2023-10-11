//
//  SelectCommunityView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

//import SwiftUI
//
//struct SelectCommunityView: View {
//    private let communities = Community.dummy
//    
//    @State private var isPlay: Bool = false
//    @State private var communityName: String = ""
//    @State private var selected = ""
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Image(asset: ZenoImages(name: "ZenoBackgroundBasic"))
//                VStack {
//                    ScrollViewReader { ScrollViewProxy in
//                        cardView()
//                            .onChange(of: selected) { _ in
//                                withAnimation {
//                                    ScrollViewProxy.scrollTo(selected, anchor: .top)
//                            }
//                        }
//                    }
//                    /// 그룹들 나오는 뷰
//                    commuityListView()
//                        .padding(.top, 10)
//                    
//                        Group {
//                            if isPlay == false {
//                                Text("제노를 플레이 할 그룹을 선택해주세요")
//                                    .selectCommunity2()
//                            } else {
//                                VStack {
//                                    ZStack {
//                                        Text(communityName)
//                                            .selectCommunity2()
//                                    }
//                                    NavigationLink {
//                                        ZenoView(zenoList: Array(Zeno.ZenoQuestions.shuffled().prefix(10)), allMyFriends: User.dummy)
//                                    } label: {
//                                        Text("Start")
//                                            .padding(.leading, .screenWidth * 0.7)
//                                            .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
//                                            .foregroundColor(.white)
//                                    }
//                                }
//                            }
//                        }
//                    ZStack {
//                        LottieView(lottieFile: "beforeZeno")
//                            .frame(width: .screenWidth * 0.5, height: .screenHeight * 0.3)
//                            .offset(x: -.screenWidth/3, y: -40)
//                    }
//                }
//            }
//            .offset(y: 100)
//            .onAppear {
//                isPlay = false
//            }
//        }
//    }
//   
//    func commuityListView() -> some View {
//        ScrollView(.vertical, showsIndicators: false) {
//            VStack {
//                ForEach(communities) { community in
//                    Button {
//                        isPlay = true
//                        selected = community.id
//                        communityName = community.name
//                    } label: {
//                        CommuintyCellView(community: community, isBold: false)
//                    }
//                }
//            }
//        }
//        .frame(width: .screenWidth/3, height: .screenHeight/3)
//    }
//    
//    func cardView() -> some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(communities) { community in
//                    GeometryReader { geometry in
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 20)
//                                .opacity(0.7)
//                            VStack {
//                                ZenoKFImageView(community, ratio: .fit)
//                                    .frame(width: 50, height: 50)
//                                Text(community.name)
//                                    .font(ZenoFontFamily.NanumBarunGothicOTF.regular
//                                        .swiftUIFont(size: 17))
//                                    .padding(20)
//                                    .foregroundColor(.white)
//                            }
//                        }
//                        .frame(width: 320, height: 200)
//                        .id(community.id)
//                        .rotation3DEffect(
//                            Angle(degrees: getPercentage(geo: geometry) * 40),
//                            axis: (x: 0.0, y: 0.1, z: 0.0)
//                        )
//                     }
//                    .frame(width: 320, height: 200)
//                    .padding()
//                }
//            }
//            .frame(width: CGFloat(Community.dummy.count) * 610 )
//        }
//        .frame(minWidth: CGFloat(Community.dummy.count) * 100)
//    }
//}
//
//struct SelectCommunityView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectCommunityView()
//    }
//}
