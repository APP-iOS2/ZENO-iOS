//
//  HomeMainView.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct HomeMainView: View {
    var body: some View {
		NavigationStack {
			ScrollView {
				ZStack {
					newBuddyView
				}
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						print("그룹 뷰 시트 오픈 액션")
					} label: {
						HStack {
							Text("멋쟁이 사자처럼 2기")
								.font(.title2)
							Image(systemName: "chevron.down")
								.font(.caption)
						}
						.tint(.black)
					}

					Text("멋쟁이 사자처럼 2기")
						.font(.title2)
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						print("햄버거 뷰 오픈 액션")
					} label: {
						Image(systemName: "heart.fill")
					}
				}
			}
		}
    }// body
}

extension HomeMainView {
	var newBuddyView: some View {
		VStack {
			HStack {
				Text("새로 들어온 친구")
			}
		}
	}
}

struct HomeMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainView()
    }
}
