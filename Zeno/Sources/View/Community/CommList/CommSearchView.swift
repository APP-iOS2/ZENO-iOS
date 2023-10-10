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
	@State private var currentViewSerachTerm = ""
	@FocusState private var isFocusedKeyboard: Bool
	
	var body: some View {
		NavigationStack {
			ZStack {
				VStack {
					// 서치바
					searchBar
						.focused($isFocusedKeyboard)
					
					if commViewModel.commSearchTerm.isEmpty {
						// 최근 검색
						recentSearch
							.onAppear {
								commViewModel.commSearchTerm = ""
							}
					} else {
						ScrollView {
							ForEach(commViewModel.searchedComm) { item in
								CommListCell(comm: item)
							}
						}
						.scrollDismissesKeyboard(.immediately)
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
		.onAppear {
			isFocusedKeyboard = true
		}
	}
}

extension CommSearchView {
	/// 전체 커뮤니티 검색 바
	var searchBar: some View {
		HStack {
			HStack(spacing: 10) {
				TextField(text: $currentViewSerachTerm) {
					Text("커뮤니티 이름 검색")
				}
				.submitLabel(.search)
				.foregroundColor(Color(uiColor: .gray))
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
				.onSubmit {
					commViewModel.commSearchTerm = currentViewSerachTerm
					print(commViewModel.joinedComm)
					print(commViewModel.searchedComm)
				}
				
				// 텍스트필드 초기화 버튼
				if !commViewModel.commSearchTerm.isEmpty {
					Button {
						commViewModel.commSearchTerm = ""
						currentViewSerachTerm = ""
						isFocusedKeyboard = true
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
				HStack {
					Text("최근 검색")
						.font(.footnote)
					Spacer()
					Text("전체 삭제")
						.font(.footnote)
						.foregroundColor(.gray)
						.onTapGesture {
							print("전체 삭제")
						}
				}
				.padding(.trailing)
				.padding(.bottom)
				ScrollView {
					ForEach(1..<6) { i in
						VStack {
							HStack(spacing: 10) {
								Image(systemName: "magnifyingglass")
									.foregroundColor(Color(uiColor: .gray))
								Text("검색한 커뮤니티 \(i)")
									.font(.callout)
								Spacer()
							}
							.padding([.top], 2)
							.frame(maxWidth: .infinity)
							.onTapGesture {
								commViewModel.commSearchTerm = "검색한 커뮤니티 \(i)"
							}
							Divider()
						}
					}
				}
				.scrollDismissesKeyboard(.immediately)
			}
			Spacer()
		}
		.padding(.leading, 25)
	}
}

//struct CommJoinView_Previews: PreviewProvider {
//	static var previews: some View {
//		CommSearchView(isShowingSearchCommSheet: .constant(true))
//			.environmentObject(UserViewModel())
//			.environmentObject(CommViewModel())
//	}
//}
