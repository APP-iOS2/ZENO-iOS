//
//  Alarm.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct Alarm: Identifiable, Codable, CanUseFirebase {
	let id: String
	/// 알림을 보낸 유저 ID
	let sendUserID: String
	/// 알림을 보낸 유저 이름
	let sendUserName: String // 편의를 위해 추가
	/// 알림을 받은 유저 ID
	let recieveUserID: String
	/// 알림을 받은 유저 이름
	let recieveUserName: String
    /// 커뮤니티 ID
    let communityID: String
	/// 제노 ID
	let zenoID: String
	/// 제노 내용
	let zenoString: String
	/// 제노 생성 일시
	var createdAt: Double
	
	init(id: String = UUID().uuidString, sendUserID: String, sendUserName: String, recieveUserID: String, recieveUserName: String, communityID: String, zenoID: String, zenoString: String, createdAt: Double) {
		self.id = id
		self.sendUserID = sendUserID
		self.sendUserName = sendUserName
		self.recieveUserID = recieveUserID
		self.recieveUserName = recieveUserName
		self.communityID = communityID
		self.zenoID = zenoID
		self.zenoString = zenoString
		self.createdAt = createdAt
	}
}

struct Nudge {
	/// 찌르기 보낸 유저 ID
	let sendUserID: String
	/// 찌르기 보낸 유저 이름
	let sendUserName: String // 편의를 위해 추가
	/// 찌르기 받은 유저 ID
	let recieveUserID: String
	/// 찌르기 받은 유저 이름
	let recieveUserName: String  // 편의를 위해 추가
	/// 찌르기 생성 일시
	var createdAt: Double
}
