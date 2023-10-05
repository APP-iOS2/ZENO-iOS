//
//  ZenoSeachableCellView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/05.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoSeachableCellView<T: ZenoSearchable>: View {
    let item: T
    let action: () -> Void
    
    var body: some View {
        HStack {
            if item.imageURL != nil {
                // 사용자 프로필이미지 들어가야함
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
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
                Text("친구추가")
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
            }
        }
        .modifier(HomeListCellModifier())
    }
}
