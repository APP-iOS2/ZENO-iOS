//
//  CommunityStory.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/12.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import SwiftUI

struct Story: Identifiable, FirebaseAvailable, Codable {
    /// 스토리아이디
    let id: String
    /// 유저 아이디
    var userid: String
    /// 커뮤니티 아이디
    var communityID: String
    /// 스토리 컬러
    let storyColor: Color
    /// 스토리 내용
    let content: String
    /// 익명인지 아닌지
    let anonymous: Bool
    /// 작성날짜
    var createdAt: Double = Date().timeIntervalSince1970
}
