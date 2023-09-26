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
