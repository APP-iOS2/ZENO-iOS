//
//  CommEmptyView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommEmptyView: View {
	@EnvironmentObject private var commViewModel: CommViewModel
	@EnvironmentObject private var userViewModel: UserViewModel
	
	let action: () -> Void
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Button {
				} label: {
					Image(systemName: "arrow.triangle.2.circlepath")
						.resizable()
						.scaledToFill()
						.frame(width: 30, height: 30)
				}
				.tint(.mainColor)
			}
			.padding(30)
			Spacer()
			Section {
				Button {
					action()
				} label: {
					LottieView(lottieFile: "search")
						.frame(width: .screenWidth * 0.6, height: .screenHeight * 0.2)
						.overlay {
							Image(systemName: "plus.circle.fill")
								.font(.system(size: 35))
								.foregroundColor(Color("mainPurple2"))
								.offset(x: .screenWidth * 0.15, y: .screenHeight * 0.07)
						}
				}
				Text("그룹을 찾거나 만들어보세요 ! ")
					.padding(.top, 10)
					.font(.regular(16))
			}
			.offset(y: -40)
			Spacer()
		}
	}
}

struct CommEmptyView_Previews: PreviewProvider {
	static var previews: some View {
		CommEmptyView(action: { })
	}
}
