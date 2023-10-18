//
//  CommCell.swift
//  Zeno
//
//  Created by Muker on 2023/10/08.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommListCell: View {
	@EnvironmentObject private var userViewModel: UserViewModel
	@EnvironmentObject private var commViewModel: CommViewModel
	
	let comm: Community
	
	let action: () -> Void
	
	@State private var isShowingCommRequestView = false
	
	var body: some View {
		Button {
			action()
			commViewModel.addSearchTerm(comm.name)
			isShowingCommRequestView = true
		} label: {
			VStack {
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
					.padding(.horizontal)
					.padding(.top, 2)
			}
		}
		.fullScreenCover(isPresented: $isShowingCommRequestView) {
			CommRequestView(isShowingCommRequestView: $isShowingCommRequestView,
							aplicationStatus: commViewModel.checkApplied(comm: comm),
							comm: comm)
		}
	}
}
