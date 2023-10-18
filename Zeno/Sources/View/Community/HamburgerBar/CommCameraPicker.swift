//
//  CommCameraPicker.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/18.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

/// 카메라 켜기
struct CommCameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    // 방법 2
//    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> UIImagePickerController {
        // UIImagePickerController 인스턴스 반환
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera    // 이미지 소스 선택
        imagePicker.allowsEditing = false    // 이미지 편집기능 여부
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<Self>) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(imagePicker: self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let imagePicker: CommCameraPicker
        
        init(imagePicker: CommCameraPicker) {
            self.imagePicker = imagePicker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imagePicker.selectedImage = image
            }
            
            imagePicker.dismiss()
            // 방법 2
//            imagePicker.presentationMode.wrappedValue.dismiss()
        }
    }
}
