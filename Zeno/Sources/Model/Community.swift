//
//  Community.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct Community: Identifiable {
	var id: String = UUID().uuidString
	/// 커뮤니티 이름
	let communityName: String
	/// 커뮤니티 소개
	var description: String
	/// 커뮤니티 생성일
	var createdAt: Double
}

#if DEBUG
extension Community {
	static let dummy: [Community] = [
		.init(communityName: "멋쟁이 사자처럼 iOS앱스쿨 2기", description: "멋쟁이 iOS개발자 되기위해 Deep Diving", createdAt: Date().timeIntervalSince1970),
		.init(communityName: "새싹 영등포 iOS 3기", description: "푸릇푸릇 자라나는 우리는 새싹", createdAt: Date().timeIntervalSince1970),
		.init(communityName: "앨런 스쿨 12기", description: "서로서로 의지하며 공부하기", createdAt: Date().timeIntervalSince1970),
		.init(communityName: "야곰 아카데미 iOS챌린지 5기", description: "야~~~곰", createdAt: Date().timeIntervalSince1970),
		.init(communityName: "할맥 모임 88기", description: "마셔마셔 먹고 죽어", createdAt: Date().timeIntervalSince1970),
	]
}
#endif
