//
//  TextFieldModifier.swift
//  Zeno
//
//  Created by Muker on 2023/10/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct LoginTextFieldModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.textInputAutocapitalization(.never)
			.font(.subheadline)
			.padding(12)
			.background(Color(.systemGray6))
			.cornerRadius(10)
			.padding(.horizontal)
	}
}
