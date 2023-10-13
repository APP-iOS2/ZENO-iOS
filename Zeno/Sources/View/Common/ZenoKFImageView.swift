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
    let item: T
    let ratio: SwiftUI.ContentMode
    
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
    
    var placeholderImg: Image {
        if let user = item as? User,
           let manAsset = ["man1", "man2"].randomElement(),
           let womanAsset = ["woman1", "woman2"].randomElement() {
            switch user.gender {
            case .male:
                return Image(manAsset)
            case .female:
                return Image(womanAsset)
            }
        } else if (item as? Community) != nil {
            return Image(CommAsset.team1.rawValue)
        } else {
            return Image("ZenoIcon")
        }
    }
    /// 기본 인자로 ZenoSearchable 프로토콜을 채택한 값을 받으며
    /// 추가로 ratio 인자에 .fit으로 aspectRatio를 설정할 수 있고 기본값은 .fill
    init(_ item: T, ratio: SwiftUI.ContentMode = .fill) {
        self.item = item
        self.ratio = ratio
    }
    
    private enum UserAsset: String, CaseIterable {
        case man1, man2, woman1, woman2
    }
    
    private enum CommAsset: String, CaseIterable {
        case team1, team2, team3, team4
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
