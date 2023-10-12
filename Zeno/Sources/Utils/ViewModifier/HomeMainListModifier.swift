//
//  HomeMainListModifier.swift
//  Zeno
//
//  Created by Muker on 2023/09/28.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct HomeListModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.padding()
			.background(Color(uiColor: .systemGray6))
			.cornerRadius(10)
			.padding(.horizontal)
	}
}

struct HomeListCellModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.padding()
			.background(.background)
			.cornerRadius(10)
			.shadow(radius: 1)
	}
}

extension View {
    func homeListCell() -> some View {
        modifier(HomeListCellModifier())
    }
}
