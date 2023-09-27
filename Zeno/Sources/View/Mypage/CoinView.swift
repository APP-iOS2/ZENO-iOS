//
//  CoinView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct CoinView: View {
    var body: some View {
        VStack {
//            GeometryReader{ geometry in
                HStack {
                    Text("Z")
                        .font(.system(size: 30))
                        .foregroundColor(.purple)
                        .fontWeight(.bold)
                    Text("제노 확인권이 7회 남았어요.")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
//                .frame(width: geometry.size.width, height: 120)
                .frame(width: UIScreen.main.bounds.width, height: 80)
                .background(.black)
//            }
        }
    }
}

struct CoinView_Previews: PreviewProvider {
    static var previews: some View {
        CoinView()
    }
}
