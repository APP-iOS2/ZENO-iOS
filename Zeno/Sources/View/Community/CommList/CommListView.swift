//
//  CommListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct CommListView: View {
	@EnvironmentObject private var userViewModel: UserViewModel
	@EnvironmentObject private var commViewModel: CommViewModel
	@Binding var isPresented: Bool
	@State var isShowingSearchCommSheet: Bool = false
	
	var body: some View {
		NavigationStack {
			ScrollView {
				
				// 서치 바
				searchBar
					.onTapGesture {
						isShowingSearchCommSheet = true
					}
					.fullScreenCover(isPresented: $isShowingSearchCommSheet) {
						CommJoinView(isShowingSearchCommSheet: $isShowingSearchCommSheet)
					}
				
				// 가입된 그룹이 없을때
				if commViewModel.joinedCommunities.isEmpty {
					VStack(alignment: .center) {
						Text("현재 가입된 그룹이 없습니다🥲")
							.font(.title2)
						Text("새로운 그룹을 탐색해 그룹에 가입하거나")
						Text("새로운 그룹을 만들어 보세요!")
					}
					.frame(maxWidth: .infinity)
					.groupCell()
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
									//                                HStack {
									//                                    // TODO: 새로운 알림으로 조건 변경
									//                                    if index == 2 || index == 4 {
									//                                        Circle()
									//                                            .frame(width: 5, height: 5)
									//                                            .foregroundColor(.red)
									//                                    }
									//                                    Text("새로운 알림\(index)")
									//                                        .font(.caption)
									//                                        .foregroundColor(.secondary)
									//                                }
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
		.presentationDetents([.fraction(0.8)])
	}
}

extension CommListView {
	var searchBar: some View {
		HStack(spacing: 5) {
			Image(systemName: "magnifyingglass")
				.foregroundColor(.white)
			Text("새로운 그룹 탐색하기")
				.foregroundColor(Color(uiColor: .systemGray5))
			Spacer()
		}
		.frame(maxWidth: .infinity)
		.padding(.horizontal)
		.padding(.vertical, 10)
		.background(Color(uiColor: .systemGray))
		.cornerRadius(5)
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
