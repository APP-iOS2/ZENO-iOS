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
        title: String,
        content: String,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void
    ) -> some View {
        return modifier(
            CashAlertModifier(
                isPresented: isPresented,
                title: title,
                content: content,
                primaryButtonTitle: primaryButtonTitle,
                primaryAction: primaryAction
            )
        )
    }
    func initialButtonBackgroundModifier(fontColor: Color, color: Color) -> some View {
        modifier(InitialButtonBackgroundModifier(color: color, fontColor: fontColor))
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
}
