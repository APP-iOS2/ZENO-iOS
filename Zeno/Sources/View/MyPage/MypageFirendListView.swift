//
//  MypageFirendListView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import Kingfisher

struct MypageFriendListView: View {
    @EnvironmentObject private var mypageViewModel: MypageViewModel
    
    @State private var selectedGroup = "all"
    @State private var selectedGroupID = ""
    /// user의 가지고 있는 전체 커뮤니의 목록을 담은 배열
    @State private var commArray: [Community] = []
    /// user의 그룹별 친구 id 값
    @State private var groupFirendList: [String] = []
    /// user의 그룹별 친구 이름값
    @State private var friendNameList: [String] = []
    /// 계속 불러올 친구의 user를 잠깐 담을 변수
    @State private var friendInfo: [User?] = []
    /// user의 모든 친구의 user 객체를 담을 변수
    @State private var allFriendInfo: [User?] = []
    
    let db = Firestore.firestore()
    
    /// 피커에서 선택한 그룹의 id와 유저가 가지고 있는 commInfo의 id 중 일치하는 그룹을 찾아서 해당 그룹의 buddyList(id)를 반환하는 함수
    func returnBuddyList() -> [User.ID] {
        return mypageViewModel.groupList?.first(where: { $0.id == selectedGroupID })?.buddyList ?? []
    }
    
    /// BuddyList에서 친구 객체 정보 반환 함수
    func returnFriendInfo() {
        for friend in returnBuddyList() {
            db.collection("User").document(friend).getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let user = try JSONDecoder().decode(User.self, from: jsonData)
                        self.friendInfo.append(user)
                        
                        print("💙[friendInfo] \(self.friendInfo)")
                    } catch {
                        print("json parsing Error \(error.localizedDescription)")
                    }
                } else {
                    print("firebase document 존재 오류")
                }
            }
        }
    }
    
    /// "전체" 그룹에 해당하는 전체 친구의 객체를 가져오는 함수
    func getAllFriends() async {
        for friend in self.groupFirendList {
            do {
                let document = try await db.collection("User").document(friend).getDocument()
                if document.exists {
                    let data = document.data()
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let user = try JSONDecoder().decode(User.self, from: jsonData)
                        self.allFriendInfo.append(user)
                        print("💙[allFriendInfo] \(self.allFriendInfo)")
                    } catch {
                        print("json parsing Error \(error.localizedDescription)")
                    }
                } else {
                    print("firebase document 존재 오류")
                }
            } catch {
                print("getAllFriends Error!! \(error.localizedDescription)")
            }
        }
    }

    
    func getCommunityInfo() async {
        guard let groupIDList = mypageViewModel.groupIDList else { return }
        for group in groupIDList {
            do {
                let document = try await db.collection("Community").document(group).getDocument()
                if document.exists {
                    let data = document.data()
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let user = try JSONDecoder().decode(Community.self, from: jsonData)
                        self.commArray.append(user)
                        print("💙[commArray] \(self.commArray)")
                    } catch {
                        print("json parsing Error \(error.localizedDescription)")
                    }
                } else {
                    print("firebase document 존재 오류")
                }
            } catch {
                print("getAllFriends Error!! \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            // 그룹을 선택하는 피커
            Picker("피커테스트", selection: $selectedGroup) {
                Text("전체").tag("all")
                ForEach(commArray.indices, id: \.self) { group in
                    Text(commArray[group].name)
                        .tag(commArray[group].id)
                }
            }
            .tint(.black)
            .onChange(of: selectedGroup) { newValue in
                self.selectedGroupID = newValue
                self.friendInfo = []
                self.allFriendInfo = []
                if newValue == "all" {
                    Task {
                        await getAllFriends()
                        print("☠️☠️\(allFriendInfo)")
                        self.friendInfo = self.allFriendInfo.removeDuplicates()
                        print("☠️\(self.friendInfo)")
                    }
                } else {
                    Task {
                        // 선택한 그룹에 해당하는 친구이름을 String array 넣어줌
                        self.friendNameList = await mypageViewModel.IDArrayToNameArray(idArray: returnBuddyList())
                    }
                }
                print("💖[친구 이름 String Array]\(friendNameList)")
                print("💖💖[그룹별 친구 id값]\(returnBuddyList())")
                self.returnFriendInfo()
            }
            
            VStack(alignment: .leading) {
                ForEach(friendInfo, id: \.self) { friend in
                    if let friendInfo = friend {
                        HStack {
                            if let imageURLString = friendInfo.imageURL,
                               let imageURL = URL(string: imageURLString) {
                                KFImage(imageURL)
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .padding()
                            } else {
                                KFImage(URL(string: "https://k.kakaocdn.net/dn/dpk9l1/btqmGhA2lKL/Oz0wDuJn1YV2DIn92f6DVK/img_640x640.jpg"))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .padding()
                            }
                            VStack(alignment: .leading) {
                                Text(friendInfo.name)
                                // 한줄소개
                                Text(friendInfo.description)
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .task {
                /// 유저가 속한 모든 그룹 정보 가져오기
//                commViewModel.filterJoinedComm()
                /// 유저의 commInfo의 id값 가져오기 (유저가 속한 그룹의 id값)
                mypageViewModel.userGroupIDList()
//                await mypageViewModel.getCommunityInfo() // 유저가 속한 전체 그룹의 이가져오는 함수 실행
                //                Task {
                if await mypageViewModel.userFriendIDList() {
                    print("🩵🩵🩵[mypageViewModel.friendIDList] \(mypageViewModel.friendIDList)")
                    guard let groupFriendID = mypageViewModel.friendIDList else { return }
                    self.groupFirendList = groupFriendID
                    print("🩵🩵🩵🩵[groupFriendID] \(self.groupFirendList)")
                    //                    }
                    
                    print("task 실행됨!!")
                    await getAllFriends()
                    print("☠️☠️\(allFriendInfo)")
                    self.friendInfo = self.allFriendInfo.removeDuplicates()
                    print("☠️\(self.friendInfo)")
                }
                await self.getCommunityInfo() // 유저가 속한 전체 그룹의 이가져오는 함수 실행
                /// 유저가 속한 모든 커뮤니티 정보 commArray에 넣어주기
//                commArray = commViewModel.joinedComm //mypageViewModel.commArray //
                print("🩵🩵[CommArray - 커뮤니티 전체 그룹] \(commArray)")
            }
            .onAppear {
                print("onappear 실행됨")
            }
            Spacer()
        }
    }
}

struct MypageFirendListView_Previews: PreviewProvider {
    static var previews: some View {
        MypageFriendListView()
            .environmentObject(MypageViewModel())
    }
}

// 중복 Array 제거하기
extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result: [Element] = []
        for item in self {
            if !result.contains(item) {
                result.append(item)
            }
        }
        return result
    }
}
