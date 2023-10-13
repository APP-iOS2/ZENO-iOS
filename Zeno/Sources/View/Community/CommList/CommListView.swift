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
    @Binding var isPresented: Bool
    @Binding var isPresentedAddCommView: Bool
    
	@EnvironmentObject private var userViewModel: UserViewModel
	@EnvironmentObject private var commViewModel: CommViewModel
	
    @State private var isShowingSearchCommSheet: Bool = false
	
	var body: some View {
		NavigationStack {
			VStack {
				// 서치 바
				Button {
					isShowingSearchCommSheet = true
					commViewModel.commSearchTerm = .init()
				} label: {
					searchBar
				}
				.fullScreenCover(isPresented: $isShowingSearchCommSheet) {
					CommSearchView(isShowingSearchCommSheet: $isShowingSearchCommSheet)
				}
				
				ScrollView {
					// 가입된 그룹이 없을때/있을때
					if commViewModel.joinedComm.isEmpty {
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
						ForEach(Array(zip(commViewModel.joinedComm, commViewModel.joinedComm.indices)), id: \.1) { community, index in
                            Button {
                                commViewModel.changeSelectedComm(index: index)
                                isPresented = false
                            } label: {
                                HStack(alignment: .center) {
                                    Circle()
                                        .stroke()
                                        .frame(width: 30, height: 30)
                                        .background(
                                            ZenoKFImageView(community)
                                                .clipShape(Circle())
                                        )
                                    VStack(alignment: .leading) {
                                        Text("\(community.name)")
                                            .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 15))
                                            .padding(.bottom, 1)
                                        if !community.description.isEmpty {
                                            Text("\(community.description)")
                                                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
                                                .foregroundColor(Color(uiColor: .systemGray4))
                                                .lineLimit(1)
                                        }
                                    }
                                    .padding(.leading, 4)
                                    Spacer()
                                    Image(systemName: "chevron.forward")
                                        .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
                                }
                                .homeListCell()
                            }
						}
                        .padding(2)
					}
					Button {
                        isPresentedAddCommView = true
                        isPresented = false
					} label: {
						HStack {
							Image(systemName: "plus.circle")
							Text("새로운 그룹 만들기")
							Spacer()
						}
						.groupCell()
					}
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 16))
                    .tint(.purple2)
				}
				.padding()
			}
		}
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
		.padding(.horizontal)
		.padding(.top)
	}
}

struct GroupListView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var userViewModel: UserViewModel = .init()
        @StateObject private var commViewModel: CommViewModel = .init()
        @StateObject private var zenoViewModel: ZenoViewModel = .init()
        @StateObject private var mypageViewModel: MypageViewModel = .init()
        @StateObject private var alarmViewModel: AlarmViewModel = .init()
        @State private var isPresented = true
        
        var body: some View {
            CommMainView()
                .sheet(isPresented: $isPresented) {
                    CommListView(isPresented: $isPresented, isPresentedAddCommView: .constant(false))
                }
                .environmentObject(userViewModel)
                .environmentObject(commViewModel)
                .environmentObject(zenoViewModel)
                .environmentObject(mypageViewModel)
                .environmentObject(alarmViewModel)
                .onAppear {
                    Task {
                        let result = await FirebaseManager.shared.read(type: User.self, id: "neWZ4Vm1VsTH5qY5X5PQyXTNU8g2")
                        switch result {
                        case .success(let user):
                            userViewModel.currentUser = user
                            commViewModel.updateCurrentUser(user: user)
                        case .failure:
                            print("preview 유저로드 실패")
                        }
                    }
                }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
