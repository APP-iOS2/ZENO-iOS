//
//  CommRequestListView.swift
//  Zeno
//
//  Created by Muker on 2023/10/19.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommRequestListView: View {
	@EnvironmentObject private var userViewModel: UserViewModel
	@EnvironmentObject private var commViewModel: CommViewModel
	@Environment(\.dismiss) private var dismiss
	
	@State var arr: [Community] = []
	@State var joinRequestCancelAlarm = false
	
	var body: some View {
		VStack {
			HStack {
				ZenoNavigationBackBtn {
					dismiss()
				} tailingLabel: {
					HStack {
						Text("가입신청한 그룹")
						Spacer()
					}
					.font(.regular(16))
				}
			}
			ScrollView {
				ForEach(arr.filter { comm in
					guard let currentUser = commViewModel.currentUser else { return false }
					return currentUser.requestComm.contains(where: { $0 == comm.id })
				}) { comm in
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
						Button {
							Task {
								await commViewModel.removeJoinRequestUser(comm: comm)
								joinRequestCancelAlarm = true
							}
						} label: {
							HStack(alignment: .bottom, spacing: 2) {
								Image(systemName: "checkmark.circle.badge.xmark.fill")
									.symbolRenderingMode(.palette)
									.foregroundStyle(.red, .white)
								Text("신청 취소")
									.font(.thin(12))
							}
						}
						.font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
						.foregroundColor(.white)
						.padding(5)
						.background(Color("MainColor"))
						.cornerRadius(6)
						.shadow(radius: 0.3)
					}
					.groupCell()
				}
				.padding()
			}
		}
		.navigationBarBackButtonHidden()
		.onAppear {
			Task {
				self.arr = await commViewModel.getRequestComm()
			}
		}
		.zenoWarning("그룹 가입 신청이 취소되었습니다.", isPresented: $joinRequestCancelAlarm)
    }
    
    /// [가입신청] 가입 신청된 커뮤니티 불러오기
    func getRequestComm(user: User) async -> [Community] {
        let results = await FirebaseManager.shared.readDocumentsWithIDs(type: Community.self, ids: user.requestComm)
        
        var requestComm: [Community] = []
        
        await results.asyncForEach { result in
            switch result {
            case .success(let comm):
                requestComm.append(comm)
            case .failure:
                print("가입신청 보낸 그룹 정보 불러오기 실패")
            }
        }
        return requestComm
    }
}

struct CommRequestListView_Previews: PreviewProvider {
    static var previews: some View {
		CommRequestListView(arr: [])
    }
}
