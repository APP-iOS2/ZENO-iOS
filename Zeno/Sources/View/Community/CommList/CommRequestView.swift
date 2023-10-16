//
//  CommReqestView.swift
//  Zeno
//
//  Created by Muker on 2023/10/08.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommRequestView: View {
	@EnvironmentObject private var userViewModel: UserViewModel
	@EnvironmentObject private var commViewModel: CommViewModel
	
	@Binding var isShowingCommRequestView: Bool
	@State var aplicationStatus: Bool
	@State private var showingAlert = false
	
	var comm: Community
	
	var body: some View {
		NavigationStack {
			ZStack {
				VStack {
					Image("yagom")
						.resizable()
						.frame(maxWidth: UIScreen.main.bounds.width,
							   maxHeight: UIScreen.main.bounds.width)
						.overlay(
							RoundedRectangle(cornerRadius: 6)
								.stroke(Color(uiColor: .systemGray6), lineWidth: 1)
						)
						.padding()
						.padding(.vertical)
					VStack(alignment: .leading, spacing: 3) {
						Text(comm.name)
							.font(.title2)
							.fontWeight(.semibold)
							.lineLimit(2)
							.padding(.horizontal)
						Text(comm.description)
							.lineLimit(nil)
							.padding(.horizontal)
							.padding(.top)
						Text("\(comm.joinMembers.count) / \(comm.personnel) | 개설일 \(comm.createdAt.convertDate)")
							.font(.footnote)
							.foregroundColor(.gray)
							.padding(.horizontal)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
					Spacer()
					Button {
						Task {
							do {
								await commViewModel.requestJoinComm(comm: comm)
								try await userViewModel.addRequestComm(comm: comm)
								self.showingAlert = true
								self.aplicationStatus = true
								print("성공\(self.showingAlert)")
							} catch {
								print("실패")
							}
						}
					} label: {
						ZStack {
							Rectangle()
								.frame(width: .screenWidth * 0.9, height: .screenHeight * 0.07)
								.cornerRadius(15)
								.foregroundColor(aplicationStatus ? .gray : .purple2)
								.opacity(0.5)
								.shadow(radius: 3)
							Image(systemName: "paperplane")
								.font(.system(size: 21))
								.offset(x: -.screenWidth * 0.3)
								.foregroundColor(aplicationStatus ? .gray : .white)
							Text(aplicationStatus ? "이미 가입신청한 그룹" : "가입 신청 하기")
								.font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 20))
								.foregroundColor(aplicationStatus ? .gray : .white)
						}
						.offset(y: -20)
					}
					.disabled(aplicationStatus)
					.alert(isPresented: $showingAlert) {
								Alert(title: Text("그룹에 가입신청을 보냈습니다"), dismissButton: .default(Text("확인")))
							}
				}
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						isShowingCommRequestView = false
					} label: {
						Image(systemName: "xmark")
					}
				}
			}
		}
	}
}

struct CommReqestView_Previews: PreviewProvider {
	static var previews: some View {
		CommRequestView(isShowingCommRequestView: .constant(true), aplicationStatus: true, comm: Community.dummy[0])
            .environmentObject(UserViewModel())
            .environmentObject(CommViewModel())
	}
}
