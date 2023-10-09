//
//  ZenoKFImageView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/09.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ZenoKFImageView<T: ZenoSearchable>: View {
    let item: T
    let ratio: SwiftUI.ContentMode
    
    var body: some View {
        if let urlStr = item.imageURL,
           let url = URL(string: urlStr) {
            KFImage(url)
                .resizable()
                .placeholder {
                    Image("Image1")
                        .resizable()
                }
                .aspectRatio(contentMode: ratio)
        }
    }
    /// 기본 인자로 ZenoSearchable 프로토콜을 채택한 값을 받으며
    /// 추가로 ratio 인자에 .fit으로 aspectRatio를 설정할 수 있고 기본값은 .fill
    init(_ item: T, ratio: SwiftUI.ContentMode = .fill) {
        self.item = item
        self.ratio = ratio
    }
}

struct ZenoKFImageView_Previews: PreviewProvider {
    static var previews: some View {
        ZenoKFImageView(User.fakeCurrentUser)
    }
}
