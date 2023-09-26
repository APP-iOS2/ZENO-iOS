//
//  SelectGroupView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct SelectGroupView: View {
    var body: some View {
        VStack {
            Text("제노 할 그룹을 선택하세요")
                .font(Font.custom("BMDOHYEON", size: 20))
            LottieView(lottieFile: "beforeZenoFirst")
        }
    }
}

func customScrollView() -> some View {
    return ScrollView(.horizontal, showsIndicators: false) {
        HStack {
            ForEach(0..<20) { _ in
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 20)
                        .rotation3DEffect(
                            Angle(degrees: getPercentage(geo: geometry) * 40),
                            axis: (x: 0.0, y: 0.1, z: 0.0)
                        )
                }
                .frame(width: 300, height: 250)
                .padding()
            }
        }
    }
}

func getPercentage(geo: GeometryProxy) -> Double {
    let maxDistance = UIScreen.main.bounds.width / 2
    let currentX = geo.frame(in: .global).midX
    return Double(currentX / maxDistance)
}

struct SelectGroupView_Previews: PreviewProvider {
    static var previews: some View {
        SelectGroupView()
    }
}
