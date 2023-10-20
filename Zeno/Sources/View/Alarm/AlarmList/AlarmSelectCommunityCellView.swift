//
//  AlarmSelectCommunityCellView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

struct AlarmSelectCommunityCellView: View {
    @Binding var selectedCommunityId: String
    let community: Community
    
    var body: some View {
        VStack {
            if let urlStr = community.imageURL,
                let url = URL(string: urlStr) {
                KFImage(url)
                    .cacheOriginalImage()
                    .resizable()
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .shadow(color: .ggullungColor.opacity(0.3), radius: 3)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                AngularGradient(gradient: Gradient(colors: [.red, .yellow, .purple, .red]), center: .center), lineWidth: 3
                            )
                            .opacity(community.id == selectedCommunityId ? 1 : 0)
                    )
                    .onTapGesture {
                        selectedCommunityId = community.id
                    }
            } else {
                Image("ZenoIcon")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(
                                AngularGradient(gradient: Gradient(colors: [.red, .yellow, .purple, .red]), center: .center), lineWidth: 3
                            )
                            .opacity(community.id == selectedCommunityId ? 1 : 0)
                    )
                    .onTapGesture {
                        selectedCommunityId = community.id
                    }
            }
            
            Text("\(community.name)")
                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 72)
        }
        .padding(.vertical)
    }
}

struct AlarmSelectCommunityCellView_Preview: PreviewProvider {
    static var previews: some View {
		AlarmSelectCommunityCellView(selectedCommunityId: .constant("aaa"), community: Community.dummy[0])
    }
}
