//
//  CommuintyCellView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct CommuintyCellView: View {
    let community: Community
    var body: some View {
        HStack {
            Spacer()
            Image(asset: ZenoImages(name: community.communityImage))
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .padding(.trailing, 10)
            Text(community.communityName)
                //.font(ZenoFontFamily.NanumBarunGothicOTF.bold.swiftUIFont(size: 20))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
        }
        .frame(width: .screenWidth * 0.8, height: .screenHeight * 0.06)
        .padding(20)
        .background(Color.black.opacity(0.2))
        .cornerRadius(20)
    }
}

struct CommuintyCellView_Previews: PreviewProvider {
    static var previews: some View {
        CommuintyCellView(community: Community(communityName: "멋쟁이 사자처럼", description: "세계 최고 부트 캠프 멋쟁이 사자처럼입니다~ ", createdAt: 20230603))
    }
}
