//
//  MakeStoryView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/12.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct MakeStoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selected: Color = .purple3
    @State private var anonymous: Bool = false
    @State private var isImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @State private var content: String = ""
    
    private let colorPalette: [Color] = [.purple2, .mainColor, .purple3, .indigo, .blue, .teal, .mint, .yellow, .orange, .pink, .red, .white, .gray2, .gray3]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(colorPalette, id: \.self) { color in
                                Button {
                                    selected = color
                                } label: {
                                    Rectangle()
                                        .frame(width: 35, height: 35)
                                        .foregroundColor(color)
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    Button {
                        anonymous.toggle()
                    } label: {
                        if anonymous {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.primary)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.primary)
                        }
                    }
                    Text("익명 사용하기")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 13))
                }
                .padding(10)
                
                ZStack {
                    Rectangle()
                        .frame(width: .screenWidth-20, height: 300)
                        .cornerRadius(10)
                        .foregroundColor(selected)
                        .padding(.leading, 10)
                    
                    TextField("여기다 내용을 입력하세요", text: $content)
                        .padding(10)
                        .frame(width: .screenWidth-40)
                        .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 30))
                    
                    Button {
                        isImagePicker = true
                    } label: {
                        ExView()
                    }
                    .offset(x: 10, y: 200)
                }
            }
            .overlay(
                ImageMenuView(title: "스토리 사진 등록",
                              isPresented: $isImagePicker,
                              selectedImage: $selectedImage)
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Text("확인")
                        .onTapGesture {
                            dismiss()
                        }
                    // TODO: 파베 코드 넣기
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "xmark")
                        .onTapGesture {
                            dismiss()
                    }
                }
            }
        }
    }
    
    func backgroundView(selectedColor: Color) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(selectedColor)
        }
    }
}

struct MakeStoryView_Previews: PreviewProvider {
    static var previews: some View {
        MakeStoryView()
    }
}
