//
//  CommImagePicker.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import UIKit
import PhotosUI

/// 갤러리 이미지 선택창
struct CommImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images  // 여러종류가 있음. 사진첩의 폴더를 얘기함. 사진만, 동영상만, livePhoto만 등등
        configuration.selectionLimit = 1 // 유저가 선택할 수 있는 사진의 개수
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator   // picker의 기능들을 활용하고 view로 전달하기 위해 picker의 delegate(대리자)에 context(UIKit)의 coordinator를 할당한다.
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // Not needed for this implementation
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedImage: $selectedImage)
    }
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var selectedImage: UIImage?
        
        init(selectedImage: Binding<UIImage?>) {
            self._selectedImage = selectedImage
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let itemProvider = results.first?.itemProvider,  // 이미지갤러리에서 선택한 이미지 중 first 가져옴.
               itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [self] (image, _) in
                    if let image = image as? UIImage {
                        selectedImage = image  // 선택한 이미지를 바인딩 변수에 할당해준다.
                        print("image: \(String(describing: selectedImage))")
                    }
                }
            }
            picker.dismiss(animated: true)
        }
    }
}

// 이거 어디에 써야하지...
func checkPhotoLibraryAuthorizationStatus() {
    let status = PHPhotoLibrary.authorizationStatus()
    
    switch status {
    case .authorized:
        // 권한이 승인됨. 앨범에 접근 가능.
        print("앨범 접근 권한이 승인되었습니다.")
    case .denied, .restricted:
        // 권한이 거부되었거나 제한됨. 사용자에게 권한을 요청해야 함.
        print("앨범 접근 권한이 거부되었거나 제한됐습니다.")
    case .notDetermined:
        // 권한이 아직 결정되지 않음. 사용자에게 권한 요청 필요.
        PHPhotoLibrary.requestAuthorization { newStatus in
            if newStatus == .authorized {
                print("앨범 접근 권한이 승인되었습니다.")
            } else {
                print("앨범 접근 권한이 거부되었거나 제한됐습니다.")
            }
        }
    case .limited:
        print("앨범접근이 제한적으로 허용됨")
    @unknown default:
        break
    }
}

/// 카메라 켜기
struct GroupCameraPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> UIImagePickerController {
        // UIImagePickerController 인스턴스 반환
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera    // 이미지 소스 선택
        imagePicker.allowsEditing = false    // 이미지 편집기능 여부
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<Self>) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate {
    }
}
