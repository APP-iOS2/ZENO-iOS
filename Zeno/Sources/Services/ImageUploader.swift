//
//  ImageUploader.swift
//  Zeno
//
//  Created by Muker on 2023/10/07.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import UIKit
import FirebaseStorage

struct ImageUploader {
	/// UIImage를 넣으면 해당 이미지를 Storage에 저장하고 사용할 수 있는 ImageURL을 반환
	static func uploadImage(image: UIImage) async throws -> String? {
		guard let imageData = image.jpegData(compressionQuality: 0.25) else { return nil }
		
		let filename = UUID().uuidString
		let ref = Storage.storage().reference(withPath: "/images/\(filename)")
		
		do {
			try await ref.putDataAsync(imageData)
			let url = try await ref.downloadURL()

			return url.absoluteString
		} catch {
			print("🔴이미지 업로드 실패: \(error.localizedDescription)")
			return nil
		}
	}
}
