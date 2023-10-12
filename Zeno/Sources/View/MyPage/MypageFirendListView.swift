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
    let db = Firestore.firestore()
    @EnvironmentObject private var mypageViewModel: MypageViewModel
    @State private var selectedGroup = "all"
    /// picker에서 선택된 그룹의 id 값 저장을 위함 @State 변수
    @State private var selectedGroupID = ""
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Picker("그룹선택", selection: $selectedGroup) {
                Text("전체").tag("all")
                ForEach(mypageViewModel.commArray.indices, id: \.self) { group in
                    Text(mypageViewModel.commArray[group].name)
                        .tag(mypageViewModel.commArray[group].id)
                }
            }
            .font(.system(size: 12))
            .tint(.black)
            .onChange(of: selectedGroup) { newValue in
                self.selectedGroupID = newValue
                mypageViewModel.friendInfo = []
                mypageViewModel.allMyPageFriendInfo = []
                if newValue == "all" {
                    Task {
                        await mypageViewModel.getAllFriends()
                        mypageViewModel.friendInfo = mypageViewModel.allMyPageFriendInfo.removeDuplicates()
                    }
                }
                mypageViewModel.returnFriendInfo(selectedGroupID: selectedGroupID)
            }
            
            VStack {
                ForEach(mypageViewModel.friendInfo, id: \.self) { friend in
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
                                    .frame(width: 70, height: 70)
//                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .clipShape(Circle())
                                    .padding(8)
                            } else {
                                Image("ZenoIcon")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
//                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .clipShape(Circle())
                                    .padding(8)
                            }
                            VStack(alignment: .leading, spacing: 20) {
                                Text(friendInfo.name)
                                    .font(.system(size: 15))
//                                    .background(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(friendInfo.description)
                                    .font(.system(size: 13))
//                                    .background(.yellow)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
//                            .background(.blue)
                            Spacer()
                        }
//                        .background(.purple)
//                        .padding(5)
//                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.7))
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 20)
            .task {
                /// 유저의 commInfo의 id값 가져오기 (유저가 속한 그룹의 id값)
                if await mypageViewModel.userFriendIDList() {
                    print("💡 [MyPage] 유저 친구값 가져오기 성공")
                    guard let groupFriendID = mypageViewModel.friendIDList else { return }
                    mypageViewModel.groupFirendList = groupFriendID
                    await mypageViewModel.getAllFriends()
                    mypageViewModel.friendInfo =  mypageViewModel.allMyPageFriendInfo.removeDuplicates()
                }
                await mypageViewModel.getCommunityInfo() // 유저가 속한 전체 그룹의 이가져오는 함수 실행
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
