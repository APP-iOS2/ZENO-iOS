//
//  UIApplication.swift
//  Zeno
//
//  Created by Muker on 2023/10/08.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import SwiftUI

extension UIApplication {
	func hideKeyboard() {
		guard let window = getWindowFirst() else { return }
		let tapRecognizer = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
		tapRecognizer.cancelsTouchesInView = false
		tapRecognizer.delegate = self
		window.addGestureRecognizer(tapRecognizer)
	}
	/// windows.first를 사용할 때 deprecated 경고를 보기 싫어서 사용
	func getWindowFirst() -> UIWindow? {
		UIApplication.shared.connectedScenes
			.filter { $0.activationState == .foregroundActive }
			.map { $0 as? UIWindowScene }
			.compactMap { $0 }
			.first?.windows
			.filter { $0.isKeyWindow }.first
	}
 }

extension UIApplication: UIGestureRecognizerDelegate {
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return false
	}
}
