//
//  CommJoinedListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
/// 가입한 전체 커뮤니티 리스트 뷰
struct CommJoinedListView: View {
    @Binding var isPresented: Bool
    @Binding var isPresentedAddCommView: Bool
	@Binding var isPresentedRequestCommView: Bool
    
    @EnvironmentObject private var commViewModel: CommViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
				// 서치바 버튼
                Button {
                    commViewModel.isShowingSearchCommSheet = true
                    commViewModel.commSearchTerm = .init()
                } label: {
                    searchBar
                }
				// 가입신청 목록
				if let requestArr = commViewModel.currentUser?.requestComm {
					if !requestArr.isEmpty {
						Button {
							isPresented = false
							isPresentedRequestCommView = true
						} label: {
							HStack {
								Text("가입신청한 그룹 \(requestArr.count)개 보기")
									.font(.regular(14))
									.foregroundColor(Color.primary)
								Spacer()
								Image(systemName: "chevron.forward")
									.font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 10))
									.foregroundColor(.gray)
							}
							.padding()
							.padding(.leading)
							.cornerRadius(7)
							.overlay(RoundedRectangle(cornerRadius: 7)
								.stroke(Color.orange, lineWidth: 1)
								  )
							.padding(.horizontal)
							.padding(.top, 10)
						}
						.padding(.bottom, 5)
					}
				}
                ScrollView(showsIndicators: false) {
                    VStack {
                        if commViewModel.joinedComm.isEmpty {
                            VStack(alignment: .center) {
                                LottieView(lottieFile: "cryggulung")
                                    .frame(width: .screenWidth * 0.3, height: .screenHeight * 0.1)
                                Text("가입된 그룹이 없습니다")
                                    .foregroundColor(.primary)
                                    .font(.bold(16))
                                    .padding(.bottom, 1)
                                Group {
                                    Text("그룹에 가입하거나, 그룹을 만들어 보세요!")
                                }
                                .font(.thin(12))
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
                                            .frame(width: 40, height: 40)
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
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
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

extension CommJoinedListView {
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
        .background(HierarchicalShapeStyle.quaternary)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 20)
        .foregroundColor(Color(uiColor: .systemGray))
    }
}

struct GroupListView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var tabBarViewModel: TabBarViewModel = .init()
        @StateObject private var commViewModel: CommViewModel = .init()
        @StateObject private var zenoViewModel: ZenoViewModel = .init()
        @StateObject private var mypageViewModel: MypageViewModel = .init()
        @StateObject private var alarmViewModel: AlarmViewModel = .init()
        @State private var isPresented = true
        
        var body: some View {
            CommMainView()
                .sheet(isPresented: $isPresented) {
                    CommJoinedListView(isPresented: $isPresented,
								 isPresentedAddCommView: .constant(false),
								 isPresentedRequestCommView: .constant(false))
                }
                .environmentObject(tabBarViewModel)
                .environmentObject(commViewModel)
                .environmentObject(zenoViewModel)
                .environmentObject(mypageViewModel)
                .environmentObject(alarmViewModel)
                .onAppear {
                    Task {
                        let result = await FirebaseManager.shared.read(type: User.self, id: "neWZ4Vm1VsTH5qY5X5PQyXTNU8g2")
                        switch result {
                        case .success(let user):
                            commViewModel.userListenerHandler(user: user)
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
