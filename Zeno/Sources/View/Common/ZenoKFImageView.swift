//
//  ZenoKFImageView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/09.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ZenoKFImageView<T: ZenoProfileVisible>: View {
    private let item: T
    private let ratio: SwiftUI.ContentMode
    private let isRandom: Bool
    
    var body: some View {
        Group {
            if let urlStr = item.imageURL,
               let url = URL(string: urlStr) {
                KFImage(url)
                    .cacheOriginalImage()
                    .resizable()
                    .placeholder {
                        placeholderImg
                            .resizable()
                    }
            } else {
                placeholderImg
                    .resizable()
            }
        }
        .aspectRatio(contentMode: ratio)
    }
    
    private var placeholderImg: Image {
        if let user = item as? User,
           var manAsset = ["man1", "man2"].randomElement(),
           var womanAsset = ["woman1", "woman2"].randomElement() {
            if !isRandom {
                manAsset = "man2"
                womanAsset = "woman1"
            }
            switch user.gender {
            case .male:
                return Image(manAsset)
            case .female:
                return Image(womanAsset)
            }
        } else if (item as? Community) != nil {
            return Image("ZenoIcon")
        } else {
            return Image("ZenoIcon")
        }
    }
    /// 기본 인자로 ZenoSearchable 프로토콜을 채택한 값을 받으며
    /// 추가로 ratio 인자에 .fit으로 aspectRatio를 설정할 수 있고 기본값은 .fill
    /// 이미지 랜덤으로 띄울지 선택. 기본값은 true -> 화면이 다시 그려질때마다 랜덤으로 값을 들고 오기때문에 고정하기 위해 추가. (23.10.15)
    init(_ item: T, ratio: SwiftUI.ContentMode = .fill, isRandom: Bool = true) {
        self.item = item
        self.ratio = ratio
        self.isRandom = isRandom
    }
}

class ZenoCacheManager<T: AnyObject> {
    let shared = NSCache<NSString, T>()
    
    func saveImage(url: URL?, image: T) {
        guard let url else { return }
        shared.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    func loadImage(url: URL?) -> T? {
        guard let url else { return nil }
        return shared.object(forKey: url.absoluteString as NSString)
    }
}
