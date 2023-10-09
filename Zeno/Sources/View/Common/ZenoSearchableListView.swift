//
//  ZenoSearchableListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/05.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoSearchableListView<T: ZenoSearchable>: View where T: Hashable {
	var items: [T]
	@Binding var searchTerm: String
	let type: ItemType
	
	@State private var isSearchable: Bool = false
	@State var isShowingCommJoinView: Bool = false
	
	var body: some View {
		VStack {
			if isSearchable {
				HStack {
					TextField(text: $searchTerm) {
						Text("\(type.toString)")
					}
					Spacer()
					Button {
						isSearchable = false
						searchTerm = ""
					} label: {
						Text("취소")
							.font(.caption)
					}
				}
				ForEach(items) { item in
                    ZenoSearchableCellView(item: item, actionTitle: "친구추가") {
					}
					//
					.fullScreenCover(isPresented: $isShowingCommJoinView) {
						Text("Full Screen Cover")
					}
				}
			} else {
				HStack {
					Text("\(type.toString) \(items.count)")
						.font(.footnote)
					Spacer()
					Button {
						isSearchable = true
					} label: {
						Image(systemName: "magnifyingglass")
							.font(.caption)
					}
				}
				VStack {
					ForEach(items) { item in
                        ZenoSearchableCellView(item: item, actionTitle: "친구추가") {
						}
					}
				}
			}
		}
	}
	
	enum ItemType {
		case user, community
		
		var toString: String {
			switch self {
			case .user:
				return "친구"
			case .community:
				return "커뮤니티"
			}
		}
	}
}
