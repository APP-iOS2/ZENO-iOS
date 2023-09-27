//
//  ZenoRewardView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct ZenoRewardView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Group {
                Text("주어진 퀴즈를")
                Text("다푸셨군요!")
            }
            .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 30))
            ZenoAsset.Assets.coin.swiftUIImage
            Group {
                Text("20코인을 획득하셨습니다")
                Text("다음 문제 꾸러미는 20분 후에")
                Text("풀 수 있어요")
            }
            .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 15))
            Spacer()
            Button {
                // TODO: 코인 관련 메서드 추가
            } label: {
                Text("코인 받고 끝내기")
                    .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 20))
            }
            .padding(.vertical, 15)
            .frame(width: .screenWidth * 0.8)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke()
            )
        }
    }
}

struct ZenoRewardView_Previews: PreviewProvider {
    static var previews: some View {
        ZenoRewardView()
    }
}
