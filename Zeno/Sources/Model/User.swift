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
	/// 이름
	let name: String
	/// 성별
	let gender: String
	/// 프로필 이미지
	var profileImgUrlPath: String?
	/// 한줄 소개
	var description: String = ""
	/// 카카오 로그인 시 생성된 토큰 저장 용도
	var kakaoToken: String
	/// 잔요 코인 횟수
	var coin: Int
	/// 메가폰 잔여 횟수
	var megaphone: Int
	/// 초성보기 사용권 잔여 횟수
	var showInitial: Int
	/// 친구관계 -> [커뮤니티ID: [친구유저데이터1, 친구유저데이터2 ...]
	var buddyList: [Community.ID: [MinUserData]]
	
	struct MinUserData: Codable {
		let id: String
		var name: String
		let gender: String
		var profileImgUrlPath: String?
		var description: String = ""
	}
}

#if DEBUG
extension User {
    static let dummy: [User] = [
        .init(name: "김찬형", gender: "남", kakaoToken: "", coin: 5, megaphone: 10, showInitial: 10, buddyList: [
            "커뮤니티ID": [.init(id: "id", name: "유저A", gender: "남")],
            "커뮤니티ID2": [.init(id: "id", name: "유저B", gender: "여")],
        ])
    ]
}
#endif
