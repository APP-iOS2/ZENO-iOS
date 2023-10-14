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
	@EnvironmentObject private var commViewModel: CommViewModel
	@Environment(\.dismiss) var dismiss
	let title: String
	@Binding var value: String
	@State private var isValidGroupName: Bool = false
    @State private var fixedText: String = ""
	@FocusState private var isTextFocused: Bool // ios 15이상에서만 동작
	let textMaxCount: Int = 15
	private let debouncer: Debouncer = .init(delay: 0.5)
	@State private var notificationStatement = "" // 텍스트 필드 밑 알림문구
	@State private var duplicationState: DuplicationState = .none
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			
			// 전체 툴바 버튼 확인버튼 아니면 모든 영역이 뒤로가기 기능
			HStack {
				ZenoNavigationBackBtn {
					dismiss()
				} label: {
					HStack {
						Text(title)
						Spacer()
					}
				}
				Button {
					value = fixedText
				} label: {
					Text("확인")
						.font(.bold(16))
				}
				.padding(.trailing)
				.disabled(!isValidGroupName || fixedText.isEmpty)
			}
			.font(.regular(16))
			
			// 이름 텍스트필드 뷰
			HStack {
				TextField("\(fixedText)",
						  text: $fixedText,
						  prompt: Text(title))
				.font(.regular(16))
				.focused($isTextFocused)
				.onChange(of: fixedText) { newValue in
					// 텍스트 필드가 비었을 때
					guard !fixedText.isEmpty else {
						duplicationState = .none
						return
					}
					if fixedText.count > textMaxCount {
						fixedText = String(newValue.prefix(textMaxCount))
					}
					duplicationState = .checking
					isValidGroupName = false
					debouncer.run {
						isValidGroupName = checkValidation(str: fixedText)
					}
				}
				if !fixedText.isEmpty {
					Button {
						fixedText = ""
							duplicationState = .none
					} label: {
						Image(systemName: "xmark.circle.fill")
							.foregroundStyle(.gray.opacity(0.5))
					}
				}
				Text("\(fixedText.count)/\(textMaxCount)")
					.font(.thin(12))
					.foregroundStyle(.gray.opacity(0.5))
			}
			.padding(.bottom, 8)
			.overlay(alignment: .bottom) {
				Rectangle().frame(height: 1)
			}
			.frame(maxWidth: .infinity)
			.padding()
			
			// 알림 문구 텍스트
			HStack {
				switch duplicationState {
				case .none:
					Text(" ")
				case .checking:
					Text("사용 가능 여부 확인중...")
						.foregroundColor(.primary)
				case .possibility:
					Text("사용 가능한 그룹명 입니다.")
						.foregroundColor(.blue)
				case .badWord:
					Text("적절하지 않은 문자가 포함되어 있습니다.")
						.foregroundColor(.red)
				case .gap:
					Text("불필요한 공백이 포함되어 있습니다.")
						.foregroundColor(.red)
				}
			}
			.font(.regular(14))
			.padding(.leading)
			
			Spacer()
		}
		.contentShape(Rectangle())
		.hideKeyboardOnTap()
		.onAppear {
			fixedText = value
			isTextFocused = true
		}
		.tint(.mainColor)
	}
	
	/// 그룹명, 소개 유효성 검사
	enum DuplicationState: String {
		case none
		case checking
		case badWord
		case gap
		case possibility
	}
	
	/// 문자열 유효성 검사
	func checkValidation(str: String) -> Bool {
		// 앞뒤 공백을 제거한 문자열
		let realText = str.trimmingCharacters(in: .whitespaces)
		// 문자열이 비어있을 때
		guard !str.isEmpty else {
			duplicationState = .none
			return false
		}
		// 문자열 앞,뒤에 공백 && 공백으로만 된 문자열
		guard !realText.isEmpty && realText == str else {
			duplicationState = .gap
			return false
		}
		// 욕설이 포함되어 있는 문자열
		let checkBadWord = Community.badWords.allSatisfy { !realText.contains($0) }
		guard checkBadWord else {
			duplicationState = .badWord
			return false
		}
		duplicationState = .possibility
		return true
	}
}

struct SettingTextFieldView_Preview: PreviewProvider {
	static var previews: some View {
		SettingTextFieldView(title: "그룹 이름", value: .constant(""))
	}
}
