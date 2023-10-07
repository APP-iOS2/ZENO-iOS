//
//  CommListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
/// 전체 커뮤니티 리스트 뷰
struct CommListView: View {
	@EnvironmentObject private var userViewModel: UserViewModel
	@EnvironmentObject private var commViewModel: CommViewModel
	@Binding var isPresented: Bool
	@State var isShowingSearchCommSheet: Bool = false
	
	var body: some View {
		NavigationStack {
			VStack {
				
				// 서치 바
				Button {
					isShowingSearchCommSheet = true
				} label: {
					searchBar
				}
				.fullScreenCover(isPresented: $isShowingSearchCommSheet) {
					CommSearchView(isShowingSearchCommSheet: $isShowingSearchCommSheet)
				}
				
				ScrollView {
					// 가입된 그룹이 없을때/있을때
					if commViewModel.joinedCommunities.isEmpty {
						VStack(alignment: .center) {
							Text("현재 가입된 그룹이 없습니다🥲")
								.font(.title2)
							Text("새로운 그룹을 탐색해 그룹에 가입하거나")
							Text("새로운 그룹을 만들어 보세요!")
						}
						.frame(maxWidth: .infinity)
						.padding(.vertical)
						.padding(.bottom, 25)
					} else {
						ForEach(Array(zip(commViewModel.searchedCommunity, commViewModel.searchedCommunity.indices)), id: \.1) { community, index in
							Button {
								if commViewModel.joinedCommunities.contains(community) {
									commViewModel.changeCommunity(index: index)
									isPresented = false
								} else {
									// TODO: 새로운 그룹 가입 뷰
								}
							} label: {
								HStack {
									VStack(alignment: .leading, spacing: 10) {
										Text("\(community.name)")
									}
									Spacer()
									Image(systemName: "chevron.forward")
								}
								.groupCell()
							}
						}
					}
					
					// 새로운 그룹 만들기
					NavigationLink {
					} label: {
						HStack {
							Image(systemName: "plus.circle")
							Text("새로운 그룹 만들기")
							Spacer()
						}
						
						.groupCell()
					}
				}
				.padding()
			}
			
		}
		.presentationDetents([.fraction(0.8)])
	}
}

extension CommListView {
	var searchBar: some View {
		HStack(spacing: 10) {
			Image(systemName: "magnifyingglass")
				.foregroundColor(Color(uiColor: .systemGray))
			Text("새로운 그룹 탐색하기")
				.foregroundColor(Color(uiColor: .systemGray))
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

struct GroupListView_Previews: PreviewProvider {
	@State static var isPresented = true
	@State static var userViewModel = UserViewModel(currentUser: .dummy[0])
	static var previews: some View {
		CommMainView()
			.sheet(isPresented: $isPresented) {
				CommListView(isPresented: $isPresented)
			}
			.environmentObject(userViewModel)
			.environmentObject(CommViewModel())
	}
}
