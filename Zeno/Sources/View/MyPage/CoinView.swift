//
//  CoinView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct CoinView: View {
    @EnvironmentObject private var mypageViewModel: MypageViewModel
    
    var body: some View {
        VStack {
                HStack {
                    Text("Z")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 25))
                        .foregroundColor(Color.purple2)
                        .fontWeight(.bold)
                    Text("제노 확인권이 \(mypageViewModel.userInfo?.showInitial ?? 0)회 남았어요.")
                        .foregroundColor(.white)
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 18))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 75)
                .background(.black)
        }
    }
}

struct CoinView_Previews: PreviewProvider {
    static var previews: some View {
        CoinView()
            .environmentObject(MypageViewModel())
    }
}
 
