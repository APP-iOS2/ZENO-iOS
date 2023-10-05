//
//  ZenoSearchableListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/05.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoSearchableListView<T: ZenoSearchable>: View where T: Hashable {
    @Binding var items: [T]
    @Binding var searchTerm: String
    let type: ItemType
    
    @State private var isSearchable: Bool = false
    
    var body: some View {
        VStack {
            if isSearchable {
                HStack {
                    TextField(text: $searchTerm) {
                        Text("친구 찾기...")
                            .font(.footnote)
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
                    ZenoSeachableCellView(item: item) {
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
                        ZenoSeachableCellView(item: item) {
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