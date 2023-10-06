//
//  Zeno.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import Foundation

struct Zeno: Identifiable, Codable, FirebaseAvailable {
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
        Zeno(question: "혼자 밑도끝도 없이 망상을 할 것 같은 사람", zenoImage: "Image1"),
        Zeno(question: "먹방 유튜버 하면 잘할 것 같은 사람", zenoImage: "Image2"),
        Zeno(question: "집중하는 모습이 멋있는 사람", zenoImage: "Image3"),
        Zeno(question: "용건 없이도 따로 통화하고 싶은 사람", zenoImage: "Image4"),
        Zeno(question: "자꾸 눈이 마주치는 사람", zenoImage: "Image5"),
        Zeno(question: "주머니에 항상 현금 3천원씩 가지고 다닐 것 같은 사람", zenoImage: "Image6"),
        Zeno(question: "같이 떡볶이 먹으러 가고 싶은 사람", zenoImage: "ddeokbbokki"),
        Zeno(question: "자신감이 매력적인 사람", zenoImage: "confidence"),
        Zeno(question: "하루동안 옷장을 바꿔보고 싶은 사람", zenoImage: "Style"),
        Zeno(question: "나이를 도무지 가늠 할 수 없는 사람", zenoImage: "questionary"),
        Zeno(question: "외적으로 닮고 싶은 사람", zenoImage: "Image11"),
        Zeno(question: "놀이공원에서 같이 교복입고 돌아다니면 재밌을 거 같은 사람", zenoImage: "Image12"),
        Zeno(question: "하루만 몸을 바꿔보고 싶은 사람", zenoImage: "Image13"),
        Zeno(question: "같이 찜질방 가고 싶은 사람", zenoImage: "Image14"),
        Zeno(question: "그룹에서 제일 힘이 쎌거 같은 사람", zenoImage: "Image15"),
        Zeno(question: "같이 취중진담 하고 싶은 사람", zenoImage: "Image16"),
        Zeno(question: "보면 볼수록 매력적인 사람", zenoImage: "Image17"),
        Zeno(question: "제일 이상형에 가까운 사람", zenoImage: "Image18"),
        Zeno(question: "무인도에 가게 된다면 꼭 데려가고 싶은 사람", zenoImage: "Image19"),
        Zeno(question: "성격이 나랑 제일 잘 맞는거 같은 사람", zenoImage: "Image20"),
        Zeno(question: "고양이 같은 사람", zenoImage: "sitting"),
        Zeno(question: "이번에 나온 신작 영화를 같이 보고싶은 사람", zenoImage: "Image22"),
        Zeno(question: "같이 스케이트타러 가고 싶은 사람", zenoImage: "Image23"),
        Zeno(question: "취향이 가장 잘 맞는 사람", zenoImage: "Image24"),
        Zeno(question: "생일을 같이 보내고 싶은 사람", zenoImage: "Image25"),
        Zeno(question: "힘들때 믿고 의지할 수 있는 사람", zenoImage: "Image26"),
        Zeno(question: "나의 고민을 가장 잘 들어줄 것 같은 사람", zenoImage: "Image27"),
        Zeno(question: "눈빛만으로 대화가 가능할거 같은 사람", zenoImage: "Image28"),
        Zeno(question: "배려심이 가장 좋은 사람", zenoImage: "Image29"),
        Zeno(question: "새벽에 전화하고 싶은 사람", zenoImage: "Image30"),
        Zeno(question: "알면 알수록 흥미로운 사람", zenoImage: "interesting"),
        Zeno(question: "페스티벌에 같이 가고 싶은 사람", zenoImage: "party"),
        Zeno(question: "어떤 향수를 쓰는지 궁금한 사람", zenoImage: "perfume"),
        Zeno(question: "누가 봐도 파워 E인 사람", zenoImage: "dancer"),
        Zeno(question: "첫인상과 현인상이 많이 다른 사람", zenoImage: "warmPeople"),
        Zeno(question: "에어팟이 없다는 가정 하에, 줄 이어폰 나눠낄 수 있는 사람", zenoImage: "earphone"),
        Zeno(question: "맛집 탐방 갈 때, 이 사람 만큼은 꼭 같이 가야 한다", zenoImage: "restaurant"),
        Zeno(question: "공포영화 못볼거 같은 사람", zenoImage: "entertainment"),
        Zeno(question: "인스타 좋아요가 끊이지 않을거 같은 사람", zenoImage: "instagram"),
        Zeno(question: "아직 대화를 많이 나누지 못해서 더 친해져보고 싶은 사람", zenoImage: "hi"),
        Zeno(question: "창의적인 생각이 돋보이는 사람", zenoImage: "creativity"),
    ]
}
#endif
