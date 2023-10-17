//
//  ImageMenuView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ImageMenuView: View {
    let title: String
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
				.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 30) {
                Text(title)
                    .font(.headline)
                ForEach(ImageBtn.allCases) { btn in
                    Button {
                        isPresented = false
                        switch btn {
                        case .album:
                            isImagePicker = true
                        case .camera:
                            isCameraPicker = true
                        }
                    } label: {
                        Text(btn.title)
                    }
                }
            }
            .font(.subheadline)
            .tint(Color.primary)
            .padding()
            .frame(width: 250, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.background)
            }
        }
        .opacity(isPresented ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isPresented)
        .fullScreenCover(isPresented: $isImagePicker) {
            CommImagePicker(selectedImage: $selectedImage)
        }
        .fullScreenCover(isPresented: $isCameraPicker) {
            // TODO: 카메라 띄우기
            CommCameraPicker()
        }
    }
    
    enum ImageBtn: Identifiable, CaseIterable {
        case album, camera
        
        var title: String {
            switch self {
            case .album:
                return "앨범에서 사진 선택"
            case .camera:
                return "사진 촬영"
            }
        }
        
        var id: Self { self }
    }
}

struct ImageMenuView_Preview: PreviewProvider {
    static var previews: some View {
        ImageMenuView(title: "프로필 사진 등록",
            isPresented: .constant(true), selectedImage: .constant(nil))
    }
}
