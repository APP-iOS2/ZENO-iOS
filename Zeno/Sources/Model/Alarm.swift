//
//  Alarm.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct Alarm {
	let sendUserID: String
	let sendUserName: String // 편의를 위해 추가
	/// 알림을 받은 유저 ID
	let recieveUserID: String
	/// 알림을 받은 유저 이름
	let recieveUserName: String
	let zenoID: String // 제노 Id
	let zenoString: String // 제노 내용
	var isPaid: Bool
	var createdAt: Double
}
// [알람] -> [제노id: 3, 제노id: 5].filter { $0.value >= 3 } -> [제노: 3] key -> [제노ID,제노ID,제노ID]

struct Nudge {
	let sendUserID: String
	let sendUserName: String // 편의를 위해 추가
	let recieveUserID: String
	let recieveUserName: String  // 편의를 위해 추가
	let message: String // 찌르기 문구
	var isPaid: Bool    // 찌르기 기능이 초성보기 구매하면 세트로 동작 가능하면 좋을 것 같다는 의견 있음
	var createdAt: Double
}
