//
//  ZenoProfileVisibleCellView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/05.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoProfileVisibleCellView<T: ZenoProfileVisible>: View {
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
                Text("\(item.name)")
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 15))
                    .padding(.bottom, 1)
                if !item.description.isEmpty {
                    Text("\(item.description)")
                        .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
                        .foregroundColor(Color(uiColor: .systemGray4))
                        .lineLimit(1)
                }
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