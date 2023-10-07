//
//  CommJoinView.swift
//  Zeno
//
//  Created by Muker on 2023/10/06.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
/// 전체 커뮤니티 검색 뷰
struct CommSearchView: View {
	@EnvironmentObject private var userViewModel: UserViewModel
	@EnvironmentObject private var commViewModel: CommViewModel
	
	@Binding var isShowingSearchCommSheet: Bool
	
	var body: some View {
		NavigationStack {
			ZStack {
				VStack {
					// 서치바
					searchBar
					
					// 서치 리스트
					if commViewModel.userSearchTerm.isEmpty {
						recentSearch
					} else {
						ScrollView {
							ForEach(commViewModel.searchedComm) { item in
								ZenoSeachableCellView(item: item) {
								}
							}
						}
					}
					Spacer()
				}
			}
			.navigationTitle("커뮤니티 검색")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						isShowingSearchCommSheet = false
					} label: {
						Image(systemName: "xmark")
					}
				}
			}
		}
	}
}

extension CommSearchView {
	/// 전체 커뮤니티 검색 바
	var searchBar: some View {
		HStack {
			HStack(spacing: 10) {
				Image(systemName: "magnifyingglass")
					.foregroundColor(Color(uiColor: .gray))
				TextField(text: $commViewModel.userSearchTerm) {
					Text("커뮤니티 이름 검색")
				}
				.foregroundColor(Color(uiColor: .gray))
				.textInputAutocapitalization(.never)
				
				// 텍스트필드 초기화 버튼
				if !commViewModel.userSearchTerm.isEmpty {
					Button {
						commViewModel.userSearchTerm = ""
					} label: {
						Image(systemName: "x.circle")
							.foregroundColor(Color(uiColor: .gray))
					}
				}
				Spacer()
			}
			.frame(maxWidth: .infinity)
			.padding(.horizontal)
			.padding(.vertical, 11)
			.background(Color(uiColor: .systemGray6))
			.cornerRadius(10)
			.padding()
		}
	}
	///
	var recentSearch: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("최근 검색")
					.foregroundColor(.gray)
			}
			Spacer()
		}
		.padding(.leading, 25)
	}
}

struct CommJoinView_Previews: PreviewProvider {
	static var previews: some View {
		CommSearchView(isShowingSearchCommSheet: .constant(true))
			.environmentObject(UserViewModel())
			.environmentObject(CommViewModel())
	}
}
