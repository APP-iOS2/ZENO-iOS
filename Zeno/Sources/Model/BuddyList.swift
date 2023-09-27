//
//  BuddyList.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct BuddyList: Identifiable {
	var id: String = UUID().uuidString
	/// 현재 유저(내가) 속한 커뮤니티 ID
	var communityId: String
	/// 현재 유저(내가) 속한 커뮤니티 이름
	var communityName: String
	/// 현재 커뮤니티 내의 친구(유저ID) 목록
	var buddyId: [String]
}
