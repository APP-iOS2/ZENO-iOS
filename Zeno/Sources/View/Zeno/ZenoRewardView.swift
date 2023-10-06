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
        ZStack {
            VStack(alignment: .center) {
                LottieView(lottieFile: "Coin")
                
                Group {
                    Group {
                        Text("60 코인 획득")
                        Text("")
                    }
                    .font(ZenoFontFamily.NanumBarunGothicOTF.bold.swiftUIFont(size: 30))
                    Group {
                        Text("다음 문제 꾸러미는 ")
                        Text("15분 후에 풀 수 있어요")
                    }
                    .font(ZenoFontFamily.NanumBarunGothicOTF.regular.swiftUIFont(size: 16))
                }
                .offset(y: -.screenHeight * 0.2)
                Spacer()
                NavigationLink {
                    FinishZenoView()
                } label: {
                    WideButton(buttonName: "Get Coin", systemImage: "arrowshape.turn.up.forward.fill", isplay: true)
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
}

struct ZenoRewardView_Previews: PreviewProvider {
    static var previews: some View {
        ZenoRewardView()
    }
}
