//
//  RegistCustomTF.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/13.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

/// 회원가입 정보입력TextField
struct RegistCustomTF: View {
    let titleText: String
    let placeholderText: String
    @Binding var customText: String
    @Binding var isNotHanguel: Bool
    let textMaxCount: Int
    let isFocusing: Bool
    var isDelBtnAppear: Bool = true
    @FocusState var isTextFocused: Bool // ios 15이상에서만 동작
    var debouncer: Debouncer = .init(delay: 0.6)
    
    var body: some View {
        HStack {
            Text(titleText)
                .frame(width: 60, alignment: .leading)
            HStack {
                TextField("\(customText)",
                          text: $customText,
                          prompt: Text(placeholderText).font(.footnote))
                .focused($isTextFocused)
                .textContentType(.name)
                .onChange(of: customText) { newValue in
                    if newValue.isEmpty {
                        isNotHanguel = false
                    } else {
                        if customText.count > textMaxCount {
                            customText = String(newValue.prefix(textMaxCount))
                        }
                        debouncer.run {
                            if koreaLangCheck(newValue) {
                                isNotHanguel = false
                            } else {
                                isNotHanguel = true
                            }
                        }
                    }
                }
                
                Button {
                    customText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.gray)
                        .opacity(isDelBtnAppear ? customText.isEmpty ? 0 : 1.0 : 0.0)
                }
                
                Text("\(customText.count)/\(textMaxCount)")
                    .font(.caption2)
                    .foregroundStyle(.gray.opacity(0.5))
            }
            .padding(.bottom, 8)
            .overlay(alignment: .bottom) {
                Rectangle().frame(height: 1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .onAppear {
            isTextFocused = isFocusing
        }
    }
}

struct RegistCustomTF_Previews: PreviewProvider {
    static var previews: some View {
        RegistCustomTF(titleText: "한줄소개",
                       placeholderText: "실명을 입력해주세요. ex)홍길동, 선우정아",
                       customText: .constant(""),
                       isNotHanguel: .constant(false),
                       textMaxCount: 5,
                       isFocusing: true)
    }
}
