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
	/// 최소한의 친구 구조체
	struct MinUserData: Codable { // 최소한의 유저 데이터를 가지고 있는 구조체. 해당 구조체로 id를 따로 검색하지 않아도 되지만 값이 수정된다면 해당하는 객체마다 값을 바꿔줘야함
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
		.init(name: "원강묵",
			  gender: "남",
			  profileImgUrlPath: "이미지URL",
			  description: "하이",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남")],
				"커뮤니티2ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남"),
					.init(id: "친구1ID", name: "버디1", gender: "남")],
			  ]),
		.init(name: "김건섭",
			  gender: "남",
			  profileImgUrlPath: "이미지URL",
			  description: "안녕하세용 건섭입니다",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남")],
				"커뮤니티2ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남"),
					.init(id: "친구1ID", name: "버디1", gender: "남")],
			  ]),
		.init(name: "유하은",
			  gender: "여",
			  profileImgUrlPath: "이미지URL",
			  description: "유하~",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남")],
				"커뮤니티2ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남"),
					.init(id: "친구1ID", name: "버디1", gender: "남")],
			  ]),
		.init(name: "박서연",
			  gender: "여",
			  profileImgUrlPath: "이미지URL",
			  description: "반갑습니다아~",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남")],
				"커뮤니티2ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남"),
					.init(id: "친구1ID", name: "버디1", gender: "남")],
			  ]),
		.init(name: "신우진",
			  gender: "남",
			  profileImgUrlPath: "이미지URL",
			  description: "내 MBTI는 CUTE",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남")],
				"커뮤니티2ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남"),
					.init(id: "친구1ID", name: "버디1", gender: "남")],
			  ]),
		.init(name: "안효명",
			  gender: "남",
			  profileImgUrlPath: "이미지URL",
			  description: "안효명하세용~",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남")],
				"커뮤니티2ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남"),
					.init(id: "친구1ID", name: "버디1", gender: "남")],
			  ]),
		.init(name: "함지수",
			  gender: "여",
			  profileImgUrlPath: "이미지URL",
			  description: "둥둥둥~~둥둥둥~~이건 입에서나는 베이스소리가 아니여",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  buddyList: [
				"커뮤니티1ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남")],
				"커뮤니티2ID": [
					.init(id: "친구1ID", name: "버디1", gender: "남"),
					.init(id: "친구1ID", name: "버디1", gender: "남")],
			  ]),
    ]
}
#endif
