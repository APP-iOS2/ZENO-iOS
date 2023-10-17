//
//  CustomTabView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/13.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CustomTabView: View {
    @EnvironmentObject var tabBarViewModel: TabBarViewModel
    @State private var interval: CGFloat = 0
    
    var body: some View {
        HStack {
            ForEach(MainTab.allCases) { item in
                Button {
                    tabBarViewModel.selected = item
                } label: {
                    VStack {
                        Image(systemName: item.imageName)
                            .resizable()
                            .symbolVariant(.fill)
                            .frame(width: 25, height: 25)
                            .shake(tabBarViewModel.selected == item ? 0.8 : 0)
                        Text(item.title)
                            .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 10))
                    }
                    .scaleEffect(tabBarViewModel.selected == item ? 1.1 : 1.0)
                    .frame(
                        width: .screenWidth * 0.9 / CGFloat(MainTab.allCases.count),
                        height: 70
                    )
                    .tint(tabBarViewModel.selected == item ? .white : Color.purple2)
                }
            }
        }
        .frame(width: .screenWidth, height: 70)
        .padding(.bottom, 15)
        .background(
            Color.mainColor
        )
        .cornerRadius(.isIPhoneSE ? 20 : 30)
        .clipped()
        .shadow(radius: 5)
    }
}

struct CustomTabView_Previews: PreviewProvider {
    struct Preview: View {
        @State private var selected: MainTab = .alert
        
        var body: some View {
            CustomTabView()
                .environmentObject(TabBarViewModel())
        }
    }
    
    static var previews: some View {
        Preview()
    }
}

extension View {
    func shake(_ interval: CGFloat) -> some View {
        self.modifier(WarningEffect(interval))
            .animation(Animation.default.speed(2.5), value: interval)
    }
}

struct WarningEffect: GeometryEffect {
    var animatableData: CGFloat
    var amount: CGFloat = 1
    var shakeCount = 3
    
    init(_ interval: CGFloat) {
        self.animatableData = interval
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * CGFloat(shakeCount) * .pi), y: 0
            )
        )
    }
}
