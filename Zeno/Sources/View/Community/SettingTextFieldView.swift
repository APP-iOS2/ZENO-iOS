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
    
    @State private var textCount: Int = 0
    @State private var textOriginal: String = ""
    @FocusState private var isTextFocused: Bool     // ios 15이상에서만 동작
    let textMaxCount: Int = 50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 30) {
                Button(action: {
                    value = textOriginal
                    dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .padding(.trailing, 30)
                })
                .tint(.black)
                
                Text(title)
                
                Spacer()
                
                Button(action: {
                    if value.isEmpty { value = textOriginal }
                    dismiss()
                }, label: {
                    Text("확인")
                })
                .tint(.black)
            }
            .padding()
            
            HStack {
                TextField("\(textOriginal)", text: $value)
                    .focused($isTextFocused)
                    .onChange(of: value) { newValue in
                        if value.count > textMaxCount {
                            value = String(newValue.prefix(textMaxCount))
                        }
                        textCount = value.count
                    }
                
                Button(action: {
                    value = ""
                    textCount = value.count
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray.opacity(0.5))
                })
                
                Text("\(textCount)/\(textMaxCount)")
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
            textCount = value.count
            textOriginal = "\(value)"
            isTextFocused = true
        }
    }
}

struct SettingTextFieldView_Preview: PreviewProvider {
    static var previews: some View {
        SettingTextFieldView(title: "그룹 이름", value: .constant("아아아아아"))
    }
}
