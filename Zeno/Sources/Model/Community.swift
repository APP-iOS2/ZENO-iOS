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
	var communityName: String
	/// 커뮤니티 소개
	var description: String
    /// 커뮤니티 인원
    var personnel: Int = 30
    /// 검색 가능 여부
    var isSearchable: Bool = true
    var communityImage: String {
        return "LLLogo"
    } // 임시로 만들어놨음
	// var communityUserId: [String] // 소속된 유저 아이디, 변수명 변경 필요

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
    static let CommunitySamples: [Community] = [Community(communityName: "멋쟁이 사자처럼", description: "세계 최고 부트 캠프 멋쟁이 사자처럼입니다~", createdAt: 20230603), Community(communityName: "새싹 영등포 2기", description: "지구 최고 부트 캠프 새싹 입니다~", createdAt: 20230203), Community(communityName: "야곰 부트캠프 3기", description: "우주 최고 부트캠프 야곰 부트캠프 입니다 ~", createdAt: 20240705)]
}
#endif
