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
	
	@State private var isShowingCommRequestView = false
	
	var body: some View {
		VStack {
			HStack {
				VStack {
					// MARK: - 이미지 수정해야함
					Image("yagom")
						.resizable()
						.frame(width: 70, height: 70)
						.overlay(
							RoundedRectangle(cornerRadius: 6)
								.stroke(Color(uiColor: .systemGray6), lineWidth: 1)
						)
				}
				.padding(.trailing)
				VStack(alignment: .leading, spacing: 2) {
					Text("\(comm.name)")
						.lineLimit(1)
					Text("\(comm.description)")
						.lineLimit(1)
						.font(.footnote)
						.foregroundColor(.gray)
					Text("\(comm.joinMembers.count) / \(comm.personnel)")
						.font(.caption)
						.foregroundColor(.gray)
				}
				Spacer()
			}
			.padding()
			Divider()
		}
		.onTapGesture {
			isShowingCommRequestView = true
		}
		.fullScreenCover(isPresented: $isShowingCommRequestView) {
			CommRequestView(isShowingCommRequestView: $isShowingCommRequestView,
							aplicationStatus: commViewModel.checkApplied(comm: comm),
							comm: comm)
		}
	}
}
