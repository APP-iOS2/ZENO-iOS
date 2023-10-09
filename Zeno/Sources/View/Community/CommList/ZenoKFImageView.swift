//
//  ZenoKFImageView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/09.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ZenoKFImageView<T>: View where T: ZenoSearchable {
    let item: T
    let ratio: SwiftUI.ContentMode
    
    var body: some View {
        if let urlStr = item.imageURL,
           let url = URL(string: urlStr) {
            KFImage(url)
                .resizable()
                .aspectRatio(contentMode: ratio)
        }
    }
    
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
