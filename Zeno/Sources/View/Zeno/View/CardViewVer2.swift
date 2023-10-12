//
//  CardViewVer2.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CardViewVer2: View {
    @Binding var currentIndex: Int
    private let itemSize: CGFloat = 200

    @EnvironmentObject var commViewModel: CommViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(commViewModel.joinedComm.indices, id: \.self) { index in
                    ZenoKFImageView(commViewModel.joinedComm[index])
                        .clipShape(Circle())
                        .frame(width: itemSize, height: itemSize)
                        .overlay(alignment: .centerFirstTextBaseline) {
                            Text(commViewModel.joinedComm[index].name)
                                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 21))
                                .offset(y: 30)
                                .frame(width: 200)
                                .opacity(currentIndex == index ? 1.0 : 0.3)
                        }
                        .scaleEffect(currentIndex == index ? 0.98 : 0.73)
                }
            }
            .frame(width: CGFloat(commViewModel.joinedComm.count+1) * itemSize, height: .screenHeight * 0.4)
        }
        .disabled(true)
    }
}

struct CardViewVer2_Previews: PreviewProvider {
    static var previews: some View {
        CardViewVer2(currentIndex: .constant(2))
    }
}
