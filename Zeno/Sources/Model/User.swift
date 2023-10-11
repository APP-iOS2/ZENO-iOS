//
//  User.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct User: Identifiable, Hashable, Codable, FirebaseAvailable, ZenoSearchable {
	var id: String = UUID().uuidString
	/// 이름
	var name: String
	/// 성별
	let gender: String
	/// 프로필 이미지
	var imageURL: String?
	/// 한줄 소개
	var description: String = ""
	/// 카카오 로그인 시 생성된 토큰 저장 용도
	var kakaoToken: String
    /// 푸쉬 알람을 위해 현재 유저에게 발급된 token
    var fcmToken: String?
	/// 잔여 코인 횟수
	var coin: Int
	/// 메가폰 잔여 횟수
	var megaphone: Int
	/// 초성보기 사용권 잔여 횟수
	var showInitial: Int
	/// 제노 끝나는 시간
	var zenoEndAt: Double?
	/// 커뮤니티id, 친구관계, 커뮤니티알람
	var commInfoList: [joinedCommInfo] = []
	/// 가입신청한 커뮤니티 id
	var requestComm: [Community.ID]
	/// 제노 시작 시간
	var ZenoStartAt: Double = Date().timeIntervalSince1970
	/// 제노 시작 시간을 자동으로 변환해주는 연산 프로퍼티
	var ZenoStartDate: String {
		let dateOrderedAt: Date = Date(timeIntervalSince1970: ZenoStartAt)
		
		let dateFormatter: DateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "ko_kr")
		dateFormatter.timeZone = TimeZone(abbreviation: "KST")
		dateFormatter.dateFormat = "MM월dd일 HH:mm"
		return dateFormatter.string(from: dateOrderedAt)
	}
	
	struct joinedCommInfo: Hashable, Codable {
		var id: Community.ID
		var buddyList: [User.ID]
		var alert: Bool
	}
}

#if DEBUG
extension User {
    static let sampleDataForImageTest: User = .init(name: "", gender: "", kakaoToken: "", coin: 0, megaphone: 0, showInitial: 0, requestComm: [])
	static let dummy: [User] = [
		.init(name: "원강묵",
			  gender: "남",
			  imageURL: "person",
			  description: "하이",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  requestComm: []
			 ),
		.init(name: "김건섭",
			  gender: "남",
			  imageURL: "person",
			  description: "안녕하세용 건섭입니다",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  requestComm: []
			 ),
		.init(name: "유하은",
			  gender: "여",
			  imageURL: "person",
			  description: "유하~",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  requestComm: []
			 ),
		.init(name: "박서연",
			  gender: "여",
			  imageURL: "person",
			  description: "반갑습니다아~",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  requestComm: []
			 ),
		.init(name: "신우진",
			  gender: "남",
			  imageURL: "person",
			  description: "내 MBTI는 CUTE",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  requestComm: []
			 ),
		.init(name: "안효명",
			  gender: "남",
			  imageURL: "person",
			  description: "안효명하세용~",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  requestComm: []
			 ),
		.init(name: "함지수",
			  gender: "여",
			  imageURL: "person",
			  description: "둥둥둥~~둥둥둥~~이건 입에서나는 베이스소리가 아니여",
			  kakaoToken: "카카오토큰",
			  coin: 10,
			  megaphone: 10,
			  showInitial: 10,
			  requestComm: []
			 )
	]
}

extension User {
    static let fakeCurrentUser: User = User(
        name: "페이커",
        gender: "남자",
        imageURL: "https://k.kakaocdn.net/dn/dpk9l1/btqmGhA2lKL/Oz0wDuJn1YV2DIn92f6DVK/img_640x640.jpg",
        kakaoToken: "",
        coin: 140,
        megaphone: 0,
        showInitial: 10,
        commInfoList: [
            joinedCommInfo(
                id: "FFA9DF69-074D-47A1-9AF4-92D59C0ED66E",
                buddyList: [
                    "NllVob4bhGOvw5egfTgLuQM1f152",
                    "Y2A3j6rCL4MBS7ug2HzouTGeuyF3",
                    "Rlg7enYks5bNvCMvjXKA5yKPYJS2",
                    "viQRItRLLzMFIl8dvRGGH4WbMVt1"
                ],
                alert: true),
            joinedCommInfo(
                id: "FFA36B67-F94D-414C-A89A-7F70DDF641E4",
                buddyList: [
                    "NllVob4bhGOvw5egfTgLuQM1f152",
                    "Y2A3j6rCL4MBS7ug2HzouTGeuyF3",
                    "Rlg7enYks5bNvCMvjXKA5yKPYJS2",
                    "viQRItRLLzMFIl8dvRGGH4WbMVt1"]
                ,
                alert: false
            ),
            joinedCommInfo(
                id: "FFA36B67-F94D-414C-A89A-7F70DDF641E4",
                buddyList: [
                    "NllVob4bhGOvw5egfTgLuQM1f152",
                    "Y2A3j6rCL4MBS7ug2HzouTGeuyF3",
                    "Rlg7enYks5bNvCMvjXKA5yKPYJS2",
                    "viQRItRLLzMFIl8dvRGGH4WbMVt1"]
                ,
                alert: false
            ),
            joinedCommInfo(
                id: "FFA36B67-F94D-414C-A89A-7F70DDF641E4",
                buddyList: [
                    "NllVob4bhGOvw5egfTgLuQM1f152",
                    "Y2A3j6rCL4MBS7ug2HzouTGeuyF3",
                    "Rlg7enYks5bNvCMvjXKA5yKPYJS2",
                    "viQRItRLLzMFIl8dvRGGH4WbMVt1"]
                ,
                alert: false
            ),
            joinedCommInfo(
                id: "FFA36B67-F94D-414C-A89A-7F70DDF641E4",
                buddyList: [
                    "NllVob4bhGOvw5egfTgLuQM1f152",
                    "Y2A3j6rCL4MBS7ug2HzouTGeuyF3",
                    "Rlg7enYks5bNvCMvjXKA5yKPYJS2",
                    "viQRItRLLzMFIl8dvRGGH4WbMVt1"]
                ,
                alert: false
            ),
            joinedCommInfo(
                id: "F789A570-5DF0-4CE1-9CA4-278CF98CE025",
                buddyList: [
                    "NllVob4bhGOvw5egfTgLuQM1f152",
                    "Y2A3j6rCL4MBS7ug2HzouTGeuyF3",
                    "Rlg7enYks5bNvCMvjXKA5yKPYJS2",
                    "viQRItRLLzMFIl8dvRGGH4WbMVt1"
                ],
                alert: false
            )
        ],
        requestComm: []
    )
}
#endif
