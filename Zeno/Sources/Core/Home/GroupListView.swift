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
    @State private var fraction: Double = 0.8
    @State private var detent: PresentationDetent = .fraction(0.8)
    @State private var detents: Set<PresentationDetent> = [.fraction(0.8), .fraction(1)]
    var body: some View {
        NavigationStack {
            ScrollView {
                // TODO: db의 전체 그룹 중 searchTerm 변수를 이용해 filter된 리스트로 ForEach 대체
                ForEach(0..<4) { _ in
                    Button {
                        // TODO: 그룹 변경 로직
                        isPresented = false
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
                NavigationLink {
                    AddNewGroupView(detent: $detent, isPresented: $isPresented)
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("새로운 그룹 만들기")
                        Spacer()
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
        .presentationDetents(detents, selection: $detent)
    }
}

struct GroupListView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        HomeMainView()
            .sheet(isPresented: $isPresented) {
                GroupListView(isPresented: $isPresented)
            }
    }
}
