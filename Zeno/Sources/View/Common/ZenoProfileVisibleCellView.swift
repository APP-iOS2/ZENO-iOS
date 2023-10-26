//
//  ZenoProfileVisibleCellView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/05.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoProfileVisibleCellView<Item: ZenoProfileVisible, Label: View>: View {
    let item: Item
    let isBtnHidden: Bool
	let isManager: Bool
    let label: () -> Label
    let interaction: (Item) -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Circle()
                .stroke()
                .frame(width: 35, height: 35)
                .background(
                    ZenoKFImageView(item)
                        .clipShape(Circle())
                )
            VStack(alignment: .leading, spacing: 4) {
				HStack(alignment: .top) {
					Text("\(item.name)")
						.font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 15))
					if isManager {
						Image("crown")
							.resizable()
							.frame(width: 13, height: 13)
							.offset(x: -5)
					}
				}
                if !item.description.isEmpty {
                    Text("\(item.description)")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 10))
                        .foregroundColor(Color(uiColor: .systemGray2))
                        .lineLimit(1)
                }
            }
            .padding(.leading, 4)
            Spacer()
            if !isBtnHidden {
                Button {
                    interaction(item)
                } label: {
                    label()
                        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color("MainColor"))
                        .cornerRadius(6)
                        .shadow(radius: 0.3)
                }
            }
        }
        .homeListCell()
    }
}
