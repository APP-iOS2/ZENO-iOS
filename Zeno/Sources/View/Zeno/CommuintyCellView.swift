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
    let isBold: Bool
    
    var body: some View {
        HStack {
            Image(asset: ZenoImages(name: community.communityImage))
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .padding(.trailing, 10)
            Text(community.communityName)
                .font(isBold ? ZenoFontFamily.NanumBarunGothicOTF.bold.swiftUIFont(size: 15) : ZenoFontFamily.NanumBarunGothicOTF.regular.swiftUIFont(size: 15))
                .foregroundColor(.black.opacity(0.7))
                .bold()
            Spacer()
        }
        .frame(width: .screenWidth * 0.8)
    }
}

struct CommuintyCellView_Previews: PreviewProvider {
    static var previews: some View {
        CommuintyCellView(community: Community.dummy[0], isBold: true)
    }
}
