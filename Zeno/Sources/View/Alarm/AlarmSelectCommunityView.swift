//
//  AlarmSelectCommunityView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct AlarmSelectCommunityView: View {
    @Binding var selectedCommunityId: String
    @EnvironmentObject var communityViewModel: CommViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selectedCommunityId = ""
                }, label: {
                    Text("전체")
                })
                .padding(.leading)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 4) {
                        ForEach(communityViewModel.joinedComm) { community in
                            AlarmSelectCommunityCellView(selectedCommunityId: $selectedCommunityId, community: community)
                        }
                    }
                }
            }
            .padding(.vertical, -10)
        }
    }
}

struct AlarmSelectCommunityView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmSelectCommunityView(selectedCommunityId: .constant("aaa"))
            .environmentObject(CommViewModel())
    }
}
