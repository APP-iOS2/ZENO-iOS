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
	@State private var isShowingUserSearchView = false
	@State private var isShowingHamburgerView = false
	@State private var searchText = ""
	@AppStorage("isShowingDetailNewBuddyToggle") private var isShowingDetailNewBuddyToggle = true
	
	var body: some View {
		NavigationStack {
			ScrollView {
				newUserView
				userListView
			}
			.toolbar {
				groupNameToolbarItem
				hamburgerToolbarItem
			}
			.onTapGesture {
				isShowingHamburgerView = false
			}
			.sheet(isPresented: $isShowingGroupListSheet) {
				GroupListView(isPresented: $isShowingGroupListSheet)
			}
		}
		.tint(.black)
		.overlay(
			GroupSideBarView(isPresented: $isShowingHamburgerView, groupID: .constant("mutSa"))
		)
	}// body
}

extension HomeMainView {
	// MARK: - 메인 뷰
	
	/// 새로들어온 유저 뷰
	var newUserView: some View {
		VStack {
			HStack {
				Text("새로 들어온 친구 \(User.dummy[0..<5].count)")
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
				ScrollView(.horizontal) {
					HStack(spacing: 15) {
						ForEach(User.dummy[0..<5]) { user in
							VStack(spacing: 5) {
								Image(systemName: "person.circle")
									.resizable()
									.frame(width: 30, height: 30)
								Text("\(user.name)")
									.font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
							}
						}
					}
				}
				.scrollIndicators(.hidden)
			}
		}
		.modifier(HomeListModifier())
		.animation(.default, value: isShowingDetailNewBuddyToggle)
		.animation(.default, value: [isShowingDetailNewBuddyToggle, isShowingUserSearchView])
	}
	
	/// 그룹 내 유저 목록 뷰
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
					ForEach(User.dummy) { user in
						userCell(user: user)
					}
				}
			}
		}
		.modifier(HomeListModifier())
		.animation(.default, value: [isShowingDetailNewBuddyToggle, isShowingUserSearchView])
	}
	
	/// 유저 셀 뷰
	func userCell(user: User) -> some View {
		HStack {
			if user.profileImgUrlPath != nil {
				// 사용자 프로필이미지 들어가야함
				Image(systemName: "person.circle")
					.resizable()
					.frame(width: 30, height: 30)
			} else {
				Image(systemName: "person.circle")
					.resizable()
					.frame(width: 30, height: 30)
			}
			VStack(alignment: .leading) {
				// 유저 이름
				Text("\(user.name)")
					.font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 15))
					.padding(.bottom, 1)
				// 유저 한줄 소개
				Text("\(user.description)")
					.font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
					.foregroundColor(Color(uiColor: .systemGray4))
					.lineLimit(1)
			}
			.padding(.leading, 4)
			Spacer()
			Button {
				print("친구추가 버튼")
			} label: {
				Text("친구추가")
					.font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
			}
		}
		.modifier(HomeListCellModifier())
	}
	
	// MARK: - 툴바
	
	/// 그룹 이름 툴바아이템
	var groupNameToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				isShowingGroupListSheet.toggle()
			} label: {
				HStack {
					Text("\(Community.dummy[0].communityName)")
						.font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
					Image(systemName: "chevron.down")
						.font(.caption)
				}
			}
		}
	}
	
	/// 햄버거 툴바아이템
	var hamburgerToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarTrailing) {
			Button {
				isShowingHamburgerView = true
			} label: {
				Image(systemName: "line.3.horizontal")
					.fontWeight(.semibold)
			}
		}
	}
}

struct HomeMainView_Previews: PreviewProvider {
	static var previews: some View {
		HomeMainView()
	}
}
