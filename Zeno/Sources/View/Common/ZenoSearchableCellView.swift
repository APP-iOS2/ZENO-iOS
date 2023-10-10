//
//  ZenoSearchableCellView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/05.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoSearchableCellView<T: ZenoSearchable>: View {
    let item: T
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Circle()
                .stroke()
                .frame(width: 30, height: 30)
                .background(
                    ZenoKFImageView(item)
                        .clipShape(Circle())
                )
            VStack(alignment: .leading) {
                // 유저 이름
                Text("\(item.name)")
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 15))
                    .padding(.bottom, 1)
                // 유저 한줄 소개
                Text("\(item.description)")
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
                    .foregroundColor(Color(uiColor: .systemGray4))
                    .lineLimit(1)
            }
            .padding(.leading, 4)
            Spacer()
            Button {
                action()
            } label: {
                Text(actionTitle)
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
            }
        }
        .homeListCell()
    }
}