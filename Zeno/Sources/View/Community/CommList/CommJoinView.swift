//
//  CommJoinView.swift
//  Zeno
//
//  Created by Muker on 2023/10/06.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommJoinView: View {
	@EnvironmentObject private var userViewModel: UserViewModel
	@EnvironmentObject private var commViewModel: CommViewModel
	
	@Binding var isShowingSearchCommSheet: Bool
	
	var body: some View {
		ZStack {
			VStack {
				// 툴바
				toolBar
				// 서치바
				searchBar
				// 서치 리스트
				if commViewModel.userSearchTerm.isEmpty {
					recentSearch
				} else {
					ScrollView {
						ForEach(commViewModel.searchedCommunity) { item in
							ZenoSeachableCellView(item: item) {
							}
						}
					}
				}
				Spacer()
			}
		}
	}
}

extension CommJoinView {
	/// 상단 툴바
	var toolBar: some View {
		HStack {
			Button {
				isShowingSearchCommSheet = false
			} label: {
				Image(systemName: "xmark")
			}
			.padding(.horizontal)
			Spacer()
		}
		.padding()
	}
	/// 전체 커뮤니티 검색 바
	var searchBar: some View {
		HStack(spacing: 5) {
			Image(systemName: "magnifyingglass")
				.foregroundColor(.white)
			TextField(text: $commViewModel.userSearchTerm) {
				Text("전체 커뮤니티 검색")
			}
			Spacer()
		}
		.frame(maxWidth: .infinity)
		.padding(.horizontal)
		.padding(.vertical, 10)
		.background(Color(uiColor: .systemGray4))
		.cornerRadius(5)
		.padding()
	}
	var recentSearch: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("최근 검색")
				
			}
			Spacer()
		}
		
		.padding(.horizontal)
	}
}

struct CommJoinView_Previews: PreviewProvider {
	static var previews: some View {
		CommJoinView(isShowingSearchCommSheet: .constant(true))
			.environmentObject(UserViewModel())
			.environmentObject(CommViewModel())
	}
}
