//
//  Alarm.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct Alarm: Identifiable, Codable, FirebaseAvailable {
	let id: String
	/// 알림을 보낸 유저 ID
	let sendUserID: String
	/// 알림을 보낸 유저 이름
    let sendUserName: String // 편의를 위해 추가
    /// 알림을 보낸 유저 FCM token
    let sendUserFcmToken: String
    /// 알림을 받은 유저 ID
	let receiveUserID: String
	/// 알림을 받은 유저 이름
    let receiveUserName: String
    /// 알림을 받은 유저 FCM token
    let receiveUserFcmToken: String
    /// 커뮤니티 ID
    let communityID: String
    /// nudge와 alarm 통합했을 때 필요. alarm 생성 시 recieveUserID 와 동일
    let showUserID: String // 편의성 10.04 추가
	/// 제노 ID
	let zenoID: String
	/// 제노 내용
	let zenoString: String
	/// 제노 생성 일시
	var createdAt: Double
    
    init(id: String = UUID().uuidString, sendUserID: String, sendUserName: String, sendUserFcmToken: String, receiveUserID: String, receiveUserName: String, receiveUserFcmToken: String, communityID: String, showUserID: String, zenoID: String, zenoString: String, createdAt: Double) {
        self.id = id
        self.sendUserID = sendUserID
        self.sendUserName = sendUserName
        self.sendUserFcmToken = sendUserFcmToken
        self.receiveUserID = receiveUserID
        self.receiveUserName = receiveUserName
        self.receiveUserFcmToken = receiveUserFcmToken
        self.communityID = communityID
        self.showUserID = showUserID
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
    /// 알림을 받은 유저 ID
    let receiveUserID: String
    /// 알림을 받은 유저 이름
    let receiveUserName: String
	/// 찌르기 생성 일시
	var createdAt: Double
}
