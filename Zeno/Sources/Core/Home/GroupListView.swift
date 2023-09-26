//
//  GroupListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct GroupListView: View {
    @Binding var isPresented: Bool
    @State private var searchTerm: String = ""
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(0..<4) { _ in
                    NavigationLink {
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("멋쟁이 사자처럼 iOS 2기")
                                Text("공지사항......")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(lineWidth: 0)
                        )
                    }
                }
                .searchable(text: $searchTerm, placement: .toolbar, prompt: "그룹을 검색해보세요")
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("그룹 목록")
                        .font(.title)
                        .bold()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
            }
        }
    }
}

struct GroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView(isPresented: .constant(true))
    }
}
