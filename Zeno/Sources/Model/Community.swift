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
	let communityName: String
	var description: String
	var createdAt: Double  // 생성일
	
	// var communityUserId: [String] // 소속된 유저 아이디, 변수명 변경 필요
}
