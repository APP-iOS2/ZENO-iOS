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

  var communityImage: String {
        return "LLLogo" } // 임 시로만들어놨음
	// var communityUserId: [String] // 소속된 유저 아이디, 변수명 변경 필요

	/// 커뮤니티 생성일
	var createdAt: Double
}

extension Community {
    static let CommunitySamples: [Community] = [Community(communityName: "멋쟁이 사자처럼", description: "세계 최고 부트 캠프 멋쟁이 사자처럼입니다~", createdAt: 20230603), Community(communityName: "새싹 영등포 2기", description: "지구 최고 부트 캠프 새싹 입니다~", createdAt: 20230203), Community(communityName: "야곰 부트캠프 3기", description: "우주 최고 부트캠프 야곰 부트캠프 입니다 ~", createdAt: 20240705)]
}
