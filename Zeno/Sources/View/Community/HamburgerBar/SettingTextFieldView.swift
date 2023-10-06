//
//  SettingTextFieldView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

/// 그룹설정 TextField
struct SettingTextFieldView: View {
	@Environment(\.dismiss) var dismiss
	let title: String
	@Binding var value: String
	
    @State private var fixedText: String = ""
	@FocusState private var isTextFocused: Bool // ios 15이상에서만 동작
	let textMaxCount: Int = 50
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack(spacing: 30) {
                ZenoNavigationBackBtn {
                    dismiss()
                }
				Text(title)
				Spacer()
				Button {
					value = fixedText
					dismiss()
				} label: {
					Text("확인")
				}
                .disabled(fixedText.isEmpty)
			}
			.padding()
            .tint(.black)
			HStack {
				TextField("\(fixedText)",
                          text: $fixedText,
                          prompt: Text(title))
					.focused($isTextFocused)
					.onChange(of: fixedText) { newValue in
						if fixedText.count > textMaxCount {
                            fixedText = String(newValue.prefix(textMaxCount))
						}
					}
                if !fixedText.isEmpty {
                    Button {
                        fixedText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray.opacity(0.5))
                    }
                }
                Text("\(fixedText.count)/\(textMaxCount)")
					.font(.caption2)
					.foregroundStyle(.gray.opacity(0.5))
			}
			.padding(.bottom, 8)
			.overlay(alignment: .bottom) {
				Rectangle().frame(height: 1)
			}
			.frame(maxWidth: .infinity)
			.padding()
			Spacer()
		}
		.contentShape(Rectangle())
		.hideKeyboardOnTap()
		.onAppear {
			fixedText = value
			isTextFocused = true
		}
	}
}

struct SettingTextFieldView_Preview: PreviewProvider {
	static var previews: some View {
		SettingTextFieldView(title: "그룹 이름", value: .constant(""))
	}
}
