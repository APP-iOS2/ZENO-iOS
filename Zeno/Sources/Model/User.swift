//
//  User.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct User: Identifiable, Hashable, Codable, CanUseFirebase {
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
	/// 잔여 코인 횟수
	var coin: Int
	/// 메가폰 잔여 횟수
	var megaphone: Int
	/// 초성보기 사용권 잔여 횟수
	var showInitial: Int
	/// 친구관계 -> [커뮤니티ID: [친구 유저 id1, 친구 유저 id2, 친구 유저 id3]
	var buddyList: [Community.ID: [User.ID]]
    /// 제노를 했는지 안했는지 여부
    var startZeno: Bool = false
    /// 제노 시작 시간
    var zenoStartAt: Double = 0
    /// 제노 시작 시간을 자동으로 변환해주는 연산 프로퍼티
    var zenoStartDate: String {
        let dateOrderedAt: Date = Date(timeIntervalSince1970: zenoStartAt)
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "MM월dd일 HH:mm"
        return dateFormatter.string(from: dateOrderedAt)
    }
}

#if DEBUG
extension User {
	static let dummy: [User] = [
		.init(name: "원강묵",
			  gender: "남",
			  profileImgUrlPath: "person",
			  description: "하이",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": ["친구1", "친구2", "친구3"],
				"커뮤니티2ID": ["친구1", "친구2", "친구3"]
			  ]),
		.init(name: "김건섭",
			  gender: "남",
			  profileImgUrlPath: "person",
			  description: "안녕하세용 건섭입니다",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": ["친구1", "친구2", "친구3"],
				"커뮤니티2ID": ["친구1", "친구2", "친구3"]
			  ]),
		.init(name: "유하은",
			  gender: "여",
			  profileImgUrlPath: "person",
			  description: "유하~",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": ["친구1", "친구2", "친구3"],
				"커뮤니티2ID": ["친구1", "친구2", "친구3"]
			  ]),
		.init(name: "박서연",
			  gender: "여",
			  profileImgUrlPath: "person",
			  description: "반갑습니다아~",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": ["친구1", "친구2", "친구3"],
				"커뮤니티2ID": ["친구1", "친구2", "친구3"]
			  ]),
		.init(name: "신우진",
			  gender: "남",
			  profileImgUrlPath: "person",
			  description: "내 MBTI는 CUTE",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": ["친구1", "친구2", "친구3"],
				"커뮤니티2ID": ["친구1", "친구2", "친구3"]
			  ]),
		.init(name: "안효명",
			  gender: "남",
			  profileImgUrlPath: "person",
			  description: "안효명하세용~",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": ["친구1", "친구2", "친구3"],
				"커뮤니티2ID": ["친구1", "친구2", "친구3"]
			  ]),
		.init(name: "함지수",
			  gender: "여",
			  profileImgUrlPath: "person",
			  description: "둥둥둥~~둥둥둥~~이건 입에서나는 베이스소리가 아니여",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": ["친구1", "친구2", "친구3"],
				"커뮤니티2ID": ["친구1", "친구2", "친구3"]
			  ])
	]
}
#endif
