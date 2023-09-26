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
	/// 제노 질문
	let question: String
	/// 제노 이미지
	let zenoImage: String
	/// 제노 설명(이름)
	let zenoDescription: String // 이거 필요한가..?
}

#if DEBUG
extension Zeno {
	static let dummy: [Zeno] = [
		.init(question: "봉사정신이 뛰어난사람", zenoImage: "tempCat", zenoDescription: "하이"),
//		.init(question: "같이 드라이브가고 싶은 사람", zenoImage: <#T##String#>, zenoDescription: <#T##String#>),
//		.init(question: "같이 운동하고 싶은 사람", zenoImage: <#T##String#>, zenoDescription: <#T##String#>),
//		.init(question: "백허그 하고 싶은", zenoImage: <#T##String#>, zenoDescription: <#T##String#>),
//		.init(question: "드립이 야무진 친구", zenoImage: <#T##String#>, zenoDescription: <#T##String#>),
//		.init(question: "축잘알", zenoImage: <#T##String#>, zenoDescription: <#T##String#>),
	]
}
#endif
