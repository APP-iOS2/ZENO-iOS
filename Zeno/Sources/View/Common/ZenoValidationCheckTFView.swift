//
//  ZenoValidationCheckTFView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/25.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoValidationCheckTFView: View {
    let titleKey: String
    @Binding var value: String
    @Binding var isValidWord: Bool
    @Binding var isValueChanged: Bool
    let options: [Option]
    let placeHolder: String
    let debouncer: Debouncer
    let maxCount: Int
    let minCount: Int
    
    @FocusState private var isTextFocused: Bool // ios 15이상에서만 동작
    @State private var text: String = ""
    @State private var validationState: ValidationState = .none
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TextField(titleKey,
                          text: $text,
                          prompt: Text(placeHolder))
                .font(.regular(16))
                .textInputAutocapitalization(.never)
                .focused($isTextFocused)
                .onChange(of: text) { newValue in
                    isValueChanged = text != value
                    guard !text.isEmpty else {
                        validationState = .none
                        return
                    }
                    if text.count > maxCount {
                        text = String(newValue.prefix(maxCount))
                    }
                    validationState = .checking
                    isValidWord = false
                    debouncer.run {
                        isValidWord = checkValidation(str: text, minCount: minCount)
                    }
                }
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray.opacity(0.5))
                    }
                }
                Text("\(text.count)/\(maxCount)")
                    .font(.thin(12))
                    .foregroundStyle(.gray.opacity(0.5))
            }
            .padding(.bottom, 8)
            .overlay(alignment: .bottom) {
                Rectangle().frame(height: 1)
            }
            .frame(maxWidth: .infinity)
            .padding()
            HStack {
                switch validationState {
                case .none:
                    Text(" ")
                case .checking:
                    Text("사용 가능 여부 확인중...")
                        .foregroundColor(.primary)
                case .possibility:
                    Text("사용 가능한 \(titleKey) 입니다.")
                        .foregroundColor(.blue)
                case .invailed(let opt):
                    Text(opt.warning)
                        .foregroundColor(.red)
                }
            }
            .font(.regular(14))
            .padding(.leading)
        }
        .contentShape(Rectangle())
        .tint(.mainColor)
        .onAppear {
            text = value
            isTextFocused = true
        }
    }
    
    enum Option: Equatable {
        case clear
        case badWord
        case gap
        case koreanLang
        case minCount(Int)
        
        var warning: String {
            switch self {
            case .clear:
                return " "
            case .badWord:
                return "적절하지 않은 문자가 포함되어 있습니다."
            case .gap:
                return "불필요한 공백이 포함되어 있습니다."
            case .koreanLang:
                return "한글로 입력해주세요. 영어 이름인 경우 발음대로 입력 (공백없이 입력)"
            case .minCount(let count):
                return "\(count)자 이상 입력해주세요."
            }
        }
        
        static func checkOpt(_ str: String, minCount: Int = 0) -> Self {
            // 앞뒤 공백을 제거한 문자열
            let realText = str.trimmingCharacters(in: .whitespaces)
            // 문자열 앞,뒤에 공백 && 공백으로만 된 문자열
            guard !realText.isEmpty && realText == str else {
                return .gap
            }
            guard str.checkKoreaLang else {
                return .koreanLang
            }
            guard str.count >= minCount else {
                return .minCount(minCount)
            }
            // 욕설이 포함되어 있는 문자열
            let checkBadWord = ZenoValidationCheckTFView.badWords.allSatisfy { !realText.contains($0) }
            guard checkBadWord else {
                return .badWord
            }
            return .clear
        }
    }
    
    enum ValidationState {
        case none
        case checking
        case invailed(Option)
        case possibility
    }
    
    init(titleKey: String,
         value: Binding<String>,
         isValidWord: Binding<Bool>,
         isValueChanged: Binding<Bool> = .constant(false),
         options: [Option],
         placeHolder: String = "",
         debouncer: Debouncer = .init(delay: 0.5),
         maxCount: Int = 15,
         minCount: Int = 0) {
        self.titleKey = titleKey
        self._value = value
        self.placeHolder = placeHolder
        self._isValidWord = isValidWord
        self._isValueChanged = isValueChanged
        self.debouncer = debouncer
        self.maxCount = maxCount
        self.minCount = minCount
        self.options = options
        self.isTextFocused = isTextFocused
        self.text = text
        self.validationState = validationState
    }
    
    init(titleKey: String,
         value: Binding<String>,
         isValidWord: Binding<Bool>,
         isValueChanged: Binding<Bool> = .constant(false),
         options: Option,
         placeHolder: String = "",
         debouncer: Debouncer = .init(delay: 0.5),
         maxCount: Int = 15,
         minCount: Int = 0) {
        self.titleKey = titleKey
        self._value = value
        self.placeHolder = placeHolder
        self._isValidWord = isValidWord
        self._isValueChanged = isValueChanged
        self.debouncer = debouncer
        self.maxCount = maxCount
        self.minCount = minCount
        self.options = [options]
        self.isTextFocused = isTextFocused
        self.text = text
        self.validationState = validationState
    }
    
    /// 문자열 유효성 검사
    func checkValidation(str: String, minCount: Int = 0) -> Bool {
        // 문자열이 비어있을 때
        guard !str.isEmpty else {
            validationState = .none
            return false
        }
        let result = Option.checkOpt(str, minCount: minCount)
        
        guard result == Option.clear,
              !options.contains(result) else {
            validationState = .invailed(result)
            return false
        }
        validationState = .possibility
        return true
    }
}

extension ZenoValidationCheckTFView {
    static let badWords = ["시발", "씨발", "개새끼", "병신", "시바", "엿먹어", "븅신", "ㅅㅂ", "ㅂㅅ", "ㅅㅂㄴ", "ㅂㅅㅅㄲ", "간나", "개씨발", "개쓰레기", "개년", "씨발년", "좆", "좆같은", "ㅆㅂ", "지랄", "개지랄", "미친년", "좆밥", "걸레", "등신", "쌍년", "쌍놈", "씹", "엠창"]
}

extension Array<ZenoValidationCheckTFView.Option> {
    static let all: Self = [
        .badWord,
        .gap,
        .koreanLang
//        , .minCount(0)
    ]
}

struct ZenoDebouncerTFView_Previews: PreviewProvider {
    struct Preview: View {
        @State private var bool = false
        @State private var bool2 = false
        @State private var str = ""
        
        var body: some View {
            VStack {
                ZenoValidationCheckTFView(
                    titleKey: "제목",
                    value: $str,
                    isValidWord: $bool,
                    isValueChanged: $bool, options: [.clear],
                    placeHolder: "문자열 검사기")
                Button("확인") {
                    
                }
                .disabled(!bool && !bool2)
            }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
