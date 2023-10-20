//
//  View.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

extension View {
    func cashAlert(
        isPresented: Binding<Bool>,
        imageTitle: String?,
        title: String,
        content: String,
        retainPoint: Int?,
        lackPoint: Int?,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void) -> some View {
        return modifier(
            CashAlertModifier(
                isPresented: isPresented,
                imageTitle: imageTitle,
                title: title,
                content: content,
                retainPoint: retainPoint,
                lackPoint: lackPoint,
                primaryButtonTitle: primaryButtonTitle,
                primaryAction: primaryAction
            )
        )
    }
    
    func backAlert(isPresented: Binding<Bool>,
                   title: String,
                   subTitle: String,
                   primaryAction1: @escaping () -> Void) -> some View {
        return modifier(
            AlarmBackBtnModifier(
                isPresented: isPresented,
                title: title,
                subTitle: subTitle,
                primaryAction1: primaryAction1
            )
        )
    }
    
    func goodsAlert(
        isPresented: Binding<Bool>,
        content1: String,
        content2: String,
        primaryButtonTitle1: String,
        primaryAction1: @escaping () -> Void,
        primaryButtonTitle2: String,
        primaryAction2: @escaping () -> Void) -> some View {
        return modifier(
            AlarmGoodsAlertModifier(
                isPresented: isPresented,
                content1: content1,
                content2: content2,
                primaryButtonTitle1: primaryButtonTitle1,
                primaryAction1: primaryAction1,
                primaryButtonTitle2: primaryButtonTitle2,
                primaryAction2: primaryAction2
            )
        )
    }
    
    func usingAlert(
        isPresented: Binding<Bool>,
        imageName: String,
        content: String,
        quantity: Int,
        usingGoods: Int,
        primaryAction1: @escaping () -> Void) -> some View {
        return modifier(
            AlarmAlertBtnModifier(
                isPresented: isPresented,
                imageName: imageName,
                content: content,
                quantity: quantity,
                usingGoods: usingGoods,
                primaryAction1: primaryAction1
            )
        )
    }
    
    func initialButtonBackgroundModifier(fontColor: Color, color: Color) -> some View {
        modifier(InitialButtonBackgroundModifier(color: color, fontColor: fontColor))
    }
    
    /// 다른 부분 터치시 키보드 숨기기
    func hideKeyboardOnTap() -> some View {
        self.modifier(HideKeyboardOnTap())
    }
}

/// 다른 부분 터치시 키보드 숨기기
struct HideKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
    }
}

/// 로그인버튼라벨
func loginButtonLabel(title: String, tintColor: Color, backgroundColor: Color) -> some View {
    Text(title)
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 6)
        .tint(tintColor)
}
