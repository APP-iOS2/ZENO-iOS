//
//  User.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct User: Identifiable, Hashable, Codable, FirebaseAvailable, ZenoProfileVisible {
    var id: String = UUID().uuidString
    /// 이름
    var name: String
    /// 성별
    var gender: Gender
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

    struct joinedCommInfo: Hashable, Codable {
        var id: Community.ID
        var buddyList: [User.ID]
        var alert: Bool
    }
}

/// 성별 정보 열거형(내부용)
enum Gender: Codable, CaseIterable {
    case male, female
    
    var toString: String {
        switch self {
        case .male:
            return "남자"
        case .female:
            return "여자"
        }
    }
}

#if DEBUG
extension User {
    static let dummy: [User] = [
        .init(name: "원강묵",
              gender: .male,
              imageURL: "person",
              description: "하이",
              kakaoToken: "카카오토큰",
              coin: 10,
              megaphone: 10,
              showInitial: 10,
              requestComm: []
             ),
        .init(name: "김건섭",
              gender: .male,
              imageURL: "person",
              description: "안녕하세용 건섭입니다",
              kakaoToken: "카카오토큰",
              coin: 10,
              megaphone: 10,
              showInitial: 10,
              requestComm: []
             ),
        .init(name: "유하은",
              gender: .female,
              imageURL: "person",
              description: "유하~",
              kakaoToken: "카카오토큰",
              coin: 10,
              megaphone: 10,
              showInitial: 10,
              requestComm: []
             ),
        .init(name: "박서연",
              gender: .female,
              imageURL: "person",
              description: "반갑습니다아~",
              kakaoToken: "카카오토큰",
              coin: 10,
              megaphone: 10,
              showInitial: 10,
              requestComm: []
             ),
        .init(name: "신우진",
              gender: .male,
              imageURL: "person",
              description: "내 MBTI는 CUTE",
              kakaoToken: "카카오토큰",
              coin: 10,
              megaphone: 10,
              showInitial: 10,
              requestComm: []
             ),
        .init(name: "안효명",
              gender: .male,
              imageURL: "person",
              description: "안효명하세용~",
              kakaoToken: "카카오토큰",
              coin: 10,
              megaphone: 10,
              showInitial: 10,
              requestComm: []
             ),
        .init(name: "함지수",
              gender: .female,
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
        gender: .male,
        imageURL: "https://firebasestorage.googleapis.com/v0/b/zeno-8cf4b.appspot.com/o/images%2F0A608D67-02F8-4A16-B1EF-3144EC945B81?alt=media&token=9a7981f3-2c52-4b75-8e1d-44ca6aaf2179&_gl=1*x8sd1w*_ga*MTM1OTM4NTAwNi4xNjkyMzMxODc2*_ga_CW55HF8NVT*MTY5NjgyNDA5Ny43Mi4xLjE2OTY4MjQxMDcuNTAuMC4w",
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
