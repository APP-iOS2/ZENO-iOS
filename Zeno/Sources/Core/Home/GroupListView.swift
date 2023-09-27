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
                ForEach(1..<5) { index in
                    Button {
                        // TODO: 그룹 변경 로직
                        isPresented = false
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("멋쟁이 사자처럼 iOS \(index)기")
                                HStack {
                                    // TODO: 새로운 알림으로 조건 변경
                                    if index == 2 || index == 4 {
                                        Circle()
                                            .frame(width: 5, height: 5)
                                            .foregroundColor(.red)
                                    }
                                    Text("새로운 알림\(index)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        .groupCell()
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
                    .groupCell()
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
