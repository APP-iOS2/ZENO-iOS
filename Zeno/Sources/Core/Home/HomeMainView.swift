//
//  HomeMainView.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct HomeMainView: View {
	@State private var isShowingGroupListSheet = false
	@AppStorage("isShowingDetailNewBuddyToggle") private var isShowingDetailNewBuddyToggle = true
	@State private var isShowingUserSearchView = false
	@State private var searchText = ""
	
	var body: some View {
		NavigationStack {
			ZStack {
				ScrollView {
					newUserView
					userListView
				}
			}
			.toolbar {
				groupNameToolbarItem
				hamburgerToolbarItem
			}
		}
		.tint(Color("MainPurple1"))
	}// body
}

extension HomeMainView {
	/// 새로들어온 유저 뷰
	@ViewBuilder
	var newUserView: some View {
		VStack {
			HStack {
				Text("새로 들어온 친구 \(User.dummy[0...1].count)")
					.font(.footnote)
				Spacer()
				Button {
					isShowingDetailNewBuddyToggle.toggle()
				} label: {
					isShowingDetailNewBuddyToggle ?
					Image(systemName: "chevron.up")
						.font(.caption2) :
					Image(systemName: "chevron.down")
						.font(.caption2)
				}
			}
			if isShowingDetailNewBuddyToggle {
				VStack {
					ForEach(User.dummy[0...1]) { user in
						userCell(user: user)
					}
				}
			}
		}
		.padding()
//		.background(Color("MainPink3"))
		.cornerRadius(10)
		.padding(.horizontal)
		.animation(.default, value: isShowingDetailNewBuddyToggle)
		.animation(.default, value: [isShowingDetailNewBuddyToggle, isShowingUserSearchView])
	}
	/// 그룹 내 유저 목록 뷰
	@ViewBuilder
	var userListView: some View {
		VStack {
			if isShowingUserSearchView {
				HStack {
					TextField(text: $searchText) {
						Text("친구 찾기...")
							.font(.footnote)
					}
					Spacer()
					Button {
						isShowingUserSearchView = false
						searchText = ""
					} label: {
						Text("취소")
							.font(.caption)
					}
				}
			} else {
				HStack {
					Text("친구 \(10)")
						.font(.footnote)
					Spacer()
					Button {
						isShowingUserSearchView = true
						print("유저 리스트 뷰 보이기")
					} label: {
						Image(systemName: "magnifyingglass")
							.font(.caption)
					}
				}
				VStack {
					ForEach(User.dummy+User.dummy) { user in
						userCell(user: user)
					}
				}
			}
		}
		.padding()
//		.background(Color("MainPink3"))
		.cornerRadius(10)
		.padding(.horizontal)
		.animation(.default, value: [isShowingDetailNewBuddyToggle, isShowingUserSearchView])
	}
	/// 유저 셀 뷰
	func userCell(user: User) -> some View {
		HStack {
			if let image = user.profileImgUrlPath {
				Image(systemName: "person.circle") // 사용자 프로필이미지 들어가야함
			} else {
				Image(systemName: "person.circle")
			}
			Text("\(user.name)")
			Spacer()
			Button {
				print("친구추가 버튼")
			} label: {
				Text("친구추가")
					.font(.system(size: 10))
			}
		}
		.padding()
		.background(Color("MainPink2"))
		.cornerRadius(10)
	}
	/// 그룹 이름 툴바아이템
	var groupNameToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				print("그룹 뷰 시트 오픈 액션")
				isShowingGroupListSheet.toggle()
			} label: {
				HStack {
					Text("멋쟁이 사자처럼 iOS 2기")
						.font(.title2)
					Image(systemName: "chevron.down")
						.font(.caption)
				}
			}
			
			Text("멋쟁이 사자처럼 2기")
				.font(.title2)
		}
	}
	/// 햄버거 툴바아이템
	var hamburgerToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarTrailing) {
			Button {
				print("햄버거 뷰 오픈 액션")
			} label: {
				Image(systemName: "line.3.horizontal")
			}
		}
	}
}

struct HomeMainView_Previews: PreviewProvider {
	static var previews: some View {
		HomeMainView()
	}
}
