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
    /// picker에서 선택된 그룹의 id 값 저장을 위함 @State 변수
    @State private var selectedGroupID = ""
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Picker("그룹선택", selection: $selectedGroup) {
                Text("전체").tag("all")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 14))
                ForEach(mypageViewModel.commArray.indices, id: \.self) { group in
                    Text(mypageViewModel.commArray[group].name)
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 14))
                        .tag(mypageViewModel.commArray[group].id)
                }
            }
            .tint(.primary)
            .onChange(of: selectedGroup) { newValue in
                self.selectedGroupID = newValue
                mypageViewModel.friendInfo = []
                mypageViewModel.allMyPageFriendInfo = []
                if newValue == "all" {
                    Task {
                        await mypageViewModel.getAllFriends()
                        mypageViewModel.friendInfo = mypageViewModel.allMyPageFriendInfo.removeDuplicates()
                    }
                } // else {
//                    Task {
//                        mypageViewModel.friendInfo = []
//                        mypageViewModel.returnFriendInfo(selectedGroupID: selectedGroupID)
//                    }
//                }
                mypageViewModel.returnFriendInfo(selectedGroupID: selectedGroupID)
            }
            
            VStack(alignment: .leading) {
                Text("친구 \(mypageViewModel.friendInfo.count)명")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14.5))
                    .foregroundColor(.primary)
                if mypageViewModel.friendInfo.isEmpty {
                    VStack {
                        LottieView(lottieFile: "friendNone")
                            .frame(width: .screenWidth * 0.5, height: .screenHeight * 0.2)
                            .opacity(0.7)
                        Text("아직 추가된 친구가 없어요!")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                        Text("그룹에서 친구를 추가해보세요.")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.light.swiftUIFont(size: 13))
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                } else {
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
                                        .clipShape(Circle())
                                        .padding(8)
                                } else {
                                    ZenoKFImageView(User(name: "", gender: friendInfo.gender, kakaoToken: "", coin: 0, megaphone: 0, showInitial: 0, requestComm: []), ratio: .fit, isRandom: false)
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                        .padding(8)
                                }
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(friendInfo.name)
                                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(friendInfo.description)
                                        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                Spacer()
                            }
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .onAppear {
                self.selectedGroup = "all"
            }
            .task {
                /// 유저의 gorupList, groupIDList, userInfo, friendIDList 가져오기
                await mypageViewModel.getUserInfo()
                print("💡 [MyPage] 유저 친구값 가져오기 성공")
                guard let groupFriendID = mypageViewModel.friendIDList else { return }
                print("💭 [groupFriendID] : \(groupFriendID)")
                mypageViewModel.groupFirendList = groupFriendID.removeDuplicates()
                print("❤️‍🩹💙mypageViewModel.groupFirendList : \(mypageViewModel.groupFirendList)")
                print("❤️‍🩹💙mypageViewModel.allMyPageFriendInfo : \(mypageViewModel.allMyPageFriendInfo)")
                mypageViewModel.allMyPageFriendInfo = []
                print("❤️‍🩹💙\(mypageViewModel.allMyPageFriendInfo.count)")
                await mypageViewModel.getAllFriends()
                
                mypageViewModel.friendInfo =  mypageViewModel.allMyPageFriendInfo.removeDuplicates()
//                if await mypageViewModel.userFriendIDList() {
//
//                }
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
        for item in self where !result.contains(item) {
            result.append(item)
        }
        return result
    }
}
