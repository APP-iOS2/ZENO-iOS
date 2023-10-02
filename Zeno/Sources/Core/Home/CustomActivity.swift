//
//  CustomActivity.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/02.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

// 커스텀 액티비티 클래스 생성
final class KakaoActivity: UIActivity {
    override class var activityCategory: UIActivity.Category {
        return .share
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("com.kakao.talk")
    }
    
    override var activityTitle: String? {
        return "카카오톡"
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "kakaotalk") ?? UIImage(systemName: "xmark.circle")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true // 언제나 수행 가능
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        // 커스텀 앱이 실행될 때 필요한 작업 수행
    }
    
    override func perform() {
        // 커스텀 앱 실행 로직
        if let kakaoURL = URL(string: "kakaotalk://") {
            if UIApplication.shared.canOpenURL(kakaoURL) {
                UIApplication.shared.open(kakaoURL, options: [:], completionHandler: nil)
            }
        }
        activityDidFinish(true)
    }
}

final class IGActivity: UIActivity {
    override class var activityCategory: UIActivity.Category {
        return .share
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("com.kakao.talk")
    }
    
    override var activityTitle: String? {
        return "인스타그램"
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "kakaotalk") ?? UIImage(systemName: "xmark.circle")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true // 언제나 수행 가능
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        // 커스텀 앱이 실행될 때 필요한 작업 수행
    }
    
    override func perform() {
        // 커스텀 앱 실행 로직
//        if let kakaoURL = URL(string: "kakaotalk://") {
//            if UIApplication.shared.canOpenURL(kakaoURL) {
//                UIApplication.shared.open(kakaoURL, options: [:], completionHandler: nil)
//            }
//        }
        activityDidFinish(true)
    }
}
