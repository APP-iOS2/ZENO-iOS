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
