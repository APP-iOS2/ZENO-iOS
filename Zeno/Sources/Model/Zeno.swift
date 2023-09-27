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
	var zenoDescription: String { return "" }
}

#if DEBUG
extension Zeno {
    static let ZenoQuestions: [Zeno] = [
        Zeno(question: "혼자 밑도끝도 없이 망상을 할 것 같은 사람.", zenoImage: "image1"),
        Zeno(question: "유튜버 하면 잘할 것 같은 사람.", zenoImage: "image2"),
        Zeno(question: "노출을 즐길 것 같은 사람.", zenoImage: "image3"),
        Zeno(question: "갑자기 놀래키면 심장마비 걸릴거 같은 사람.", zenoImage: "image4"),
        Zeno(question: "나만 바라보는 것 같은 사람.", zenoImage: "image5"),
        Zeno(question: "주머니에 항상 현금 3천원씩 가지고 다닐 것 같은 사람.", zenoImage: "image6"),
        Zeno(question: "같이 떡볶이 먹으러 가고 싶은 사람.", zenoImage: "image7"),
        Zeno(question: "뒤에서 잘할 것 같은 사람.", zenoImage: "image8"),
        Zeno(question: "패션센스를 닮고 싶은 사람.", zenoImage: "image9"),
        Zeno(question: "나보다 어린것 같은 사람.", zenoImage: "image10"),
        Zeno(question: "외적으로 닮고 싶은 사람.", zenoImage: "image11"),
        Zeno(question: "놀이공원에서 같이 교복입고 돌아다니고 싶은 사람.", zenoImage: "image12"),
        Zeno(question: "하루만 몸을 바꿔보고 싶은 사람.", zenoImage: "image13"),
        Zeno(question: "같이 찜질방 가고 싶은 사람.", zenoImage: "image14"),
        Zeno(question: "그룹에서 제일 힘이 쎌거 같은 사람.", zenoImage: "image15"),
        Zeno(question: "같이 취중진담 하고 싶은 사람.", zenoImage: "image16"),
        Zeno(question: "보면 볼수록 매력적인 사람.", zenoImage: "image17"),
        Zeno(question: "제일 이상형에 가까운 사람.", zenoImage: "image18"),
        Zeno(question: "무인도에서 제일 필요한 사람.", zenoImage: "image19"),
        Zeno(question: "성격이 나랑 제일 잘 맞는 사람.", zenoImage: "image20"),
        Zeno(question: "같이 산책하고 싶은 사람.", zenoImage: "image21"),
        Zeno(question: "같이 영화보고 싶은 사람.", zenoImage: "image22"),
        Zeno(question: "같이 운동하고 싶은 사람.", zenoImage: "image23"),
        Zeno(question: "어쩐지 재즈를 좋아할 것 같은 사람.", zenoImage: "image24"),
        Zeno(question: "나를 가장 많이 아는 사람.", zenoImage: "image25"),
        Zeno(question: "힘들때 믿고 의지할 수 있는 사람.", zenoImage: "image26"),
        Zeno(question: "나의 고민을 가장 잘 들어줄 것 같은 사람.", zenoImage: "image27"),
        Zeno(question: "그룹에서 가장 매력적인 사람.", zenoImage: "image28"),
        Zeno(question: "그룹에서 배려심이 가장 좋은 사람.", zenoImage: "image29"),
        Zeno(question: "새벽에 전화하고 싶은 사람.", zenoImage: "image30")
    ]
}
#endif
