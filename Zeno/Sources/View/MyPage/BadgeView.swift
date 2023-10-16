//
//  BadgeView.swift
//  Zeno
//
//  Created by 박서연 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

struct BadgeView: View {
    @EnvironmentObject private var mypageViewModel: MypageViewModel
    
    var body: some View {
        //        VStack {
        //            ForEach(mypageViewModel.itemRatios.sorted(by: { $0.value > $1.value }), id: \.key) { item, ratio in
        //                Text("\(item): \(String(format: "%.1f", ratio))%")
        //            }
        //        }
        //        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14))
        //        .foregroundColor(.primary)
        LazyVGrid(columns: Array(repeating: GridItem(), count: 2), spacing: 12) {
            ForEach(mypageViewModel.itemRatios.sorted(by: { $0.value > $1.value }).prefix(10), id: \.key) { item, ratio in
                VStack {
                    if let image = mypageViewModel.findZenoImage(forQuestion: item, in: Zeno.ZenoQuestions) {
                        Image("\(image)")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    VStack(spacing: 3) {
                        Text("\(String(format: "%.1f", ratio))%")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 10))
                            .foregroundColor(.primary)
                        Text("\(item)")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity/2, maxHeight: .infinity/2)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(uiColor: .systemGray5), lineWidth: 0.5)
                )
                .shadow(color: Color.purple2, radius: 10, x: 2, y: 2)
            }
            .padding(.horizontal, 3)
        }
        .padding(.horizontal, 15)
        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14))
        .foregroundColor(.primary)
    }
    
    /*
     Text("\(rank(forItem: item)).")
         .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14))
     */
    func rank(forItem item: String) -> Int {
        guard let index = mypageViewModel.itemRatios.keys.sorted(by: {
            mypageViewModel.itemRatios[$0]! > mypageViewModel.itemRatios[$1]!
        }).firstIndex(of: item) else {
            return -1
        }
        return index + 1
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeView()
            .environmentObject(MypageViewModel())
    }
}
