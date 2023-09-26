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
	var communityId: String
	var communityName: String
	var buddyId: [String]
}
