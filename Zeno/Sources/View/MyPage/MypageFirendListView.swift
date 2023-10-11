//
//  MypageFirendListView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

enum GroupName: String, CaseIterable, Hashable {
    case all = "전체"
    case likelion = "멋쟁이 사자처럼"
    case yagom = "야곰"
    case codings = "코딩스파르타"
    case zenoTest = "제노그룹"
}

struct TestPerson: Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var image: UIImage
    var groupinfo: String
}

struct MypageFriendListView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    
    private var testData = [
        TestPerson(name: "박서연", description: "안농하세여. 사과 러버에여.", image: UIImage(named: "Sample") ?? UIImage(), groupinfo: GroupName.likelion.rawValue),
        TestPerson(name: "원강묵", description: "나는야 포비, 원강묵", image: UIImage(named: "profile") ?? UIImage(), groupinfo: GroupName.likelion.rawValue),
        TestPerson(name: "신우진", description: "에디를 닮은 INFP", image: UIImage(named: "profile") ?? UIImage(), groupinfo: GroupName.yagom.rawValue),
        TestPerson(name: "김건섭", description: "하얀 멍뭉이 닮은 건섭", image: UIImage(named: "profile") ?? UIImage(), groupinfo: GroupName.zenoTest.rawValue),
        TestPerson(name: "함지수", description: "라디오 앵커 지수님", image: UIImage(named: "profile") ?? UIImage(), groupinfo: GroupName.codings.rawValue),
        TestPerson(name: "유하은", description: "완전힙 그자체 하은", image: UIImage(named: "profile") ?? UIImage(), groupinfo: GroupName.zenoTest.rawValue)
    ]
    
    @State private var selectedGroup = GroupName.all.rawValue
    
    var body: some View {
        VStack(alignment: .trailing) {
            Picker("피커테스트", selection: $selectedGroup) {
                ForEach(GroupName.allCases, id: \.self) { group in
                    Text(group.rawValue)
                        .tag(group.rawValue)
                }
            }.tint(.black)

            VStack(alignment: .leading) {
                ForEach(testData) { friend in
                    if friend.groupinfo == selectedGroup {
                        HStack(spacing: 10) {
                            Image(uiImage: friend.image)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .scaledToFit()
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 10) {
                                Text(friend.name)
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                Text(friend.description)
                            }
                            Spacer()
                        }
                    } else if selectedGroup == GroupName.all.rawValue {
                        HStack(spacing: 10) {
                            Image(uiImage: friend.image)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .scaledToFit()
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 10) {
                                Text(friend.name)
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                Text(friend.description)
                            }
                            Spacer()
                        }
                    }
                }
//                ForEach(filteredData, id: \.self) { friend in
//                    HStack(spacing: 10) {
//                        Image(uiImage: friend.image)
//                            .resizable()
//                            .frame(width: 80, height: 80)
//                            .scaledToFit()
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text(friend.name)
//                                .font(.system(size: 20))
//                                .fontWeight(.semibold)
//                            Text(friend.description)
//                        }
//                    }
//                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }
}

struct MypageFirendListView_Previews: PreviewProvider {
    static var previews: some View {
        MypageFriendListView()
    }
}
