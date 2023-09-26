//
//  Zeno.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct Zeno: Identifiable {
	var id: String = UUID().uuidString
	let question: String
	let zenoImage: String
	let zenoDescription: String
	// 보류 var isApprove: Bool // 질문 추가시 관리자 승인 여부, true 인 것들만 zeno 에 나옴
}
