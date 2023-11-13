//
//  LargeImageView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/20.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

/// 이미지 확대 View
struct LargeImageView: View {
    @Binding var isTapped: Bool
    let imageURL: String
    
    var body: some View {
        ZStack {
            Color.primary.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isTapped = false
                }
            
            KFImage(URL(string: imageURL))
                .cacheOriginalImage()
                .placeholder {
                    Image(asset: ZenoAsset.Assets.zenoIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        }
        .opacity(isTapped ? 1.0 : 0.0)
    }
}

struct LargeImageView_Previews: PreviewProvider {
    static var previews: some View {
        LargeImageView(isTapped: .constant(true),
                       imageURL: "https://wimg.mk.co.kr/meet/neds/2015/10/image_readtop_2015_945010_14437766262152924.jpg")
    }
}
