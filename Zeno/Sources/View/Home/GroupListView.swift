//
//  GroupListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct GroupListView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var communityViewModel: CommunityViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(Array(zip(communityViewModel.searchedCommunity, communityViewModel.searchedCommunity.indices)), id: \.1) { community, index in
                    Button {
                        if communityViewModel.joinedCommunities.contains(community) {
                            communityViewModel.selectedCommunity = index
                            isPresented = false
                        } else {
                            // TODO: 새로운 그룹 가입 뷰
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(community.communityName)")
//                                HStack {
//                                    // TODO: 새로운 알림으로 조건 변경
//                                    if index == 2 || index == 4 {
//                                        Circle()
//                                            .frame(width: 5, height: 5)
//                                            .foregroundColor(.red)
//                                    }
//                                    Text("새로운 알림\(index)")
//                                        .font(.caption)
//                                        .foregroundColor(.secondary)
//                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        .groupCell()
                    }
                }
                NavigationLink {
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("새로운 그룹 만들기")
                        Spacer()
                    }
                    .groupCell()
                }
                .searchable(text: $communityViewModel.communitySearchTerm, placement: .toolbar, prompt: "그룹을 검색해보세요")
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
        .presentationDetents([.fraction(0.8)])
    }
}

struct GroupListView_Previews: PreviewProvider {
    @State static var isPresented = true
    @State static var userViewModel = UserViewModel(currentUser: .dummy[0])
    static var previews: some View {
        HomeMainView()
            .sheet(isPresented: $isPresented) {
                GroupListView(isPresented: $isPresented)
            }
            .environmentObject(userViewModel)
            .environmentObject(CommunityViewModel())
    }
}
