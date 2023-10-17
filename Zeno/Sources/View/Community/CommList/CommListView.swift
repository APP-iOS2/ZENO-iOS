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
	
	var body: some View {
		NavigationStack {
			VStack {
				Button {
                    commViewModel.isShowingSearchCommSheet = true
					commViewModel.commSearchTerm = .init()
				} label: {
					searchBar
				}
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        if commViewModel.joinedComm.isEmpty {
                            VStack(alignment: .center) {
								LottieView(lottieFile: "cry")
									.frame(width: .screenWidth * 0.3, height: .screenHeight * 0.1)
                                Text("현재 가입된 그룹이 없습니다")
									.foregroundColor(.primary)
									.font(.bold(20))
									.padding(.bottom, 5)
								Group {
									Text("새로운 그룹을 탐색해 그룹에 가입하거나")
									Text("새로운 그룹을 만들어 보세요!")
								}
								.font(.thin(14))
								.foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .padding(.bottom, 25)
                        } else {
                            ForEach(commViewModel.joinedComm) { comm in
                                Button {
                                    commViewModel.setCurrentID(id: comm.id)
                                    isPresented = false
                                } label: {
                                    HStack(alignment: .center) {
                                        Circle()
                                            .stroke()
                                            .frame(width: 35, height: 35)
                                            .background(
                                                ZenoKFImageView(comm)
                                                    .clipShape(Circle())
                                            )
										VStack(alignment: .leading, spacing: 4) {
											HStack(alignment: .center) {
												Text("\(comm.name)")
													.font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 16))
													.lineLimit(1)
													.foregroundColor(.primary)
												HStack(alignment: .lastTextBaseline, spacing: 1) {
													Image(systemName: "person.2.fill")
														.font(.regular(11))
													Text("\(comm.joinMembers.count)")
												}
												.font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 11))
												.foregroundColor(Color(uiColor: .systemGray3))
											}
											if !comm.description.isEmpty {
												Text("\(comm.description)")
													.font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 12))
													.foregroundColor(.gray)
													.lineLimit(1)
											}
                                        }
                                        .padding(.leading, 5)
                                        Spacer()
                                        Image(systemName: "chevron.forward")
                                            .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
											.foregroundColor(.gray)
                                    }
                                    .groupCell()
                                }
                            }
                            .padding(2)
                        }
                        Button {
                            isPresentedAddCommView = true
                            isPresented = false
                        } label: {
                            HStack {
                                Circle()
                                    .stroke()
                                    .frame(width: 35, height: 35)
                                    .background(
                                        Image(systemName: "plus")
                                            .clipShape(Circle())
                                            .bold()
                                    )
									.bold()
                                Text("새로운 그룹 만들기")
                                Spacer()
                            }
                            .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 16))
                                .padding(.bottom, 1)
                        }
                        .groupCell()
						.tint(.mainColor)
                        .padding(2)
                    }
                    .padding()
				}
			}
		}
        .fullScreenCover(isPresented: $commViewModel.isShowingSearchCommSheet) {
            CommSearchView(isShowingSearchCommSheet: $commViewModel.isShowingSearchCommSheet)
        }
	}
}

extension CommListView {
	var searchBar: some View {
		HStack(spacing: 10) {
			Image(systemName: "magnifyingglass")
			Text("새로운 그룹 탐색하기")
			Spacer()
		}
		.font(.regular(14))
		.frame(maxWidth: .infinity)
		.padding(.horizontal)
		.padding(.vertical, 11)
		.background(Color(uiColor: .systemGray6))
		.cornerRadius(10)
		.padding(.horizontal)
		.padding(.top)
		.foregroundColor(Color(uiColor: .systemGray))
	}
}

struct GroupListView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var tabBarViewModel: TabBarViewModel = .init()
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
                .environmentObject(tabBarViewModel)
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
