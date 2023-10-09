//
//  Community.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct Community: Identifiable, Codable, Hashable, FirebaseAvailable, ZenoSearchable {
	var id: String = UUID().uuidString
	/// 커뮤니티 이름
	var name: String
	/// 커뮤니티 소개
	var description: String
	/// 커뮤니티 이미지 URL
	var imageURL: String?
	/// 커뮤니티 생성일
	var createdAt: Double
	/// 커뮤니티 인원
	var personnel: Int
	/// 검색 가능 여부
	var isSearchable: Bool = true
	/// 커뮤니티 그룹장
	var managerID: User.ID
	/// 커뮤니티에 가입된 유저
	var joinMembers: [Member]
	/// 커뮤니티 가입 신청 후 승인 대기중인 유저
	var waitApprovalMemberIDs: [User.ID] = []
	/// 커뮤니티에 가입된 유저 구조체
	struct Member: Codable, Identifiable, Hashable {
		/// 유저 ID
		var id: String
		/// 커뮤니티에 가입된 날짜
		let joinedAt: Double
	}
}

extension Community {
	static let emptyComm = Community(name: "", description: "", imageURL: nil, createdAt: Date().timeIntervalSince1970, personnel: 6, isSearchable: true, manager: "", joinMembers: [], waitApprovalMemberIDs: [])
}
#if DEBUG
extension Community {
	static let dummy: [Community] = [
		.init(name: "멋쟁이 사자처럼 iOS앱스쿨 2기",
			  description: "멋쟁이 iOS개발자 되기위해 Deep Diving", imageURL: "LLLogo",
			  createdAt: Date().timeIntervalSince1970,
			  personnel: 100,
			  isSearchable: true,
			  managerID: "매니저",
			  joinMembers: [
				.init(id: "유저1", joinedAt: Date().timeIntervalSince1970),
				.init(id: "유저2", joinedAt: Date().timeIntervalSince1970),
				.init(id: "유저3", joinedAt: Date().timeIntervalSince1970),
				.init(id: "유저4", joinedAt: Date().timeIntervalSince1970),
				.init(id: "유저5", joinedAt: Date().timeIntervalSince1970),
			  ]),
		.init(name: "새싹 영등포 iOS 3기",
			  description: "푸릇푸릇 자라나는 우리는 새싹", imageURL: "sesac",
			  createdAt: Date().timeIntervalSince1970,
			  personnel: 30,
			  isSearchable: true,
			  managerID: "매니저",
			  joinMembers: []),
		.init(name: "앨런 스쿨 12기",
			  description: "서로서로 의지하며 공부하기", imageURL: "allon",
			  createdAt: Date().timeIntervalSince1970,
			  personnel: 20,
			  isSearchable: true,
			  managerID: "매니저",
			  joinMembers: []),
		.init(name: "야곰 아카데미 iOS챌린지 5기",
			  description: "야~~~곰", imageURL: "yagom",
			  createdAt: Date().timeIntervalSince1970,
			  personnel: 100,
			  isSearchable: true,
			  managerID: "매니저",
			  joinMembers: [])
	]
}
#endif
