//
//  Alarm.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct Alarm: Identifiable {
	var id: String = UUID().uuidString
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
	/// 제노
	var isPaid: Bool
	/// 제노 생성 일시
	var createdAt: Double
}
// [알람] -> [제노id: 3, 제노id: 5].filter { $0.value >= 3 } -> [제노: 3] key -> [제노ID,제노ID,제노ID]

struct Nudge {
	/// 찌르기 보낸 유저 ID
	let sendUserID: String
	/// 찌르기 보낸 유저 이름
	let sendUserName: String // 편의를 위해 추가
	/// 찌르기 받은 유저 ID
	let recieveUserID: String
	/// 찌르기 받은 유저 이름
	let recieveUserName: String  // 편의를 위해 추가
	/// 찌르기 문구
	let message: String // 찌르기 문구
	/// 찌르기
	var isPaid: Bool    // 찌르기 기능이 초성보기 구매하면 세트로 동작 가능하면 좋을 것 같다는 의견 있음
	/// 찌르기 생성 일시
	var createdAt: Double
}
