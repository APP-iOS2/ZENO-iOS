//
//  ImageMenuView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ImageMenuView: View {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    
    @State private var isImagePicker: Bool = false
    @State private var isCameraPicker: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(alignment: .leading, spacing: 30) {
                Text("프로필 사진 등록")
                    .font(.headline)
                Button(action: {
                    isPresented = false
                    isImagePicker = true
                }, label: {
                    Text("앨범에서 사진 선택")
                })
                Button(action: {
                    isPresented = false
                    isCameraPicker = true
                }, label: {
                    Text("사진 촬영")
                })
            }
            .font(.subheadline)
            .tint(Color.black)
            .padding()
            .frame(width: 250, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            }
        }
        .opacity(isPresented ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isPresented)
        .fullScreenCover(isPresented: $isImagePicker, content: {
            GroupImagePicker(selectedImage: $selectedImage)
        })
        .fullScreenCover(isPresented: $isCameraPicker, content: {
            // TODO: 카메라 띄우기
            GroupCameraPicker()
        })
    }
}

struct ImageMenuView_Preview: PreviewProvider {
    static var previews: some View {
        ImageMenuView(isPresented: .constant(true), selectedImage: .constant(nil))
    }
}
