//
//  User.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct User: Identifiable, Codable {
	var id: String = UUID().uuidString
	let name: String // 실명 직접받고
	let gender: String
	/// 프로필 이미지
	var profileImgUrlPath: String?
	/// 카카오 로그인 시 생성된 토큰 저장 용도
	var kakaoToken: String
	/// 잔요 코인 횟수
	var coin: Int
	/// 메가폰 잔여 횟수
	var megaphone: Int
	/// 초성보기 사용권 잔여 횟수
	var showInitial: Int
}

#if DEBUG
extension User {
    static let dummy: [User] = [
        .init(name: "김건섭", gender: "남", kakaoToken: "토큰", coin: 10, megaphone: 1, showInitial: 10),
        .init(name: "원강묵", gender: "남", kakaoToken: "토큰", coin: 20, megaphone: 2, showInitial: 10),
        .init(name: "신우진", gender: "남", kakaoToken: "토큰", coin: 30, megaphone: 3, showInitial: 10),
        .init(name: "안효명", gender: "남", kakaoToken: "토큰", coin: 40, megaphone: 4, showInitial: 10),
        .init(name: "함지수", gender: "여", kakaoToken: "토큰", coin: 50, megaphone: 5, showInitial: 10),
        .init(name: "박서연", gender: "여", kakaoToken: "토큰", coin: 60, megaphone: 6, showInitial: 10),
        .init(name: "유하은", gender: "여", kakaoToken: "토큰", coin: 70, megaphone: 7, showInitial: 10)
    ]
}
#endif
