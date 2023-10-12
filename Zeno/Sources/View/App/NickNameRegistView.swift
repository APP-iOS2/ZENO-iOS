//
//  NickNameRegistView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/10.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

/// 앱 설치 후 첫 회원가입시에만 사용하는 뷰 ( 실명 적는 란 )
struct NickNameRegistView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var fixedText: String = ""
    @State private var isNotHanguel: Bool = false
    @FocusState private var isTextFocused: Bool // ios 15이상에서만 동작
    private let textMaxCount: Int = 5
    private var debouncer: Debouncer = .init(delay: 0.5)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 30) {
                Text("이름을 입력해주세요")
                Spacer()
                Button {
                    if koreaLangCheck(fixedText) {
                        Task {
                            do {
                                if let user = userVM.currentUser {
                                    try await FirebaseManager.shared.update(data: user.self, value: \.name, to: fixedText)
                                    UserDefaults.standard.set(true, forKey: "nickNameChanged")
                                } else {
                                    print("🦕User정보가 없음..!! 관리자 호출")
                                }
                                dismiss()
                            } catch {
                                // toast를 띄워주면 될듯.
                                print("이름변경 Update 실패했음. 다시 시도시키기")
                            }
                        }
                    }
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
                          prompt: Text("실명을 입력해주세요. ex)홍길동, 선우정아"))
                .focused($isTextFocused)
                .textContentType(.name)
                .onChange(of: fixedText) { newValue in
                    if newValue.isEmpty {
                        isNotHanguel = false
                    } else {
                        if fixedText.count > textMaxCount {
                            fixedText = String(newValue.prefix(textMaxCount))
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
            
            if isNotHanguel {
                Text("한글로 입력바랍니다. 영어이름인경우 발음대로 입력.")
                    .foregroundStyle(Color.red.opacity(0.8))
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .hideKeyboardOnTap()
        .onAppear {
            isTextFocused = true
        }
    }
    
    /// 한글로 써져있는지 체크 (정규 표현식 패턴을 사용)
    func koreaLangCheck(_ input: String) -> Bool {
        let pattern = "^[가-힣]*$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: input.utf16.count)
            if regex.firstMatch(in: input, options: [], range: range) != nil {
                return true
            }
        }
        return false
    }
}

struct NickNameRegistView_Previews: PreviewProvider {
    static var previews: some View {
        NickNameRegistView()
    }
}
