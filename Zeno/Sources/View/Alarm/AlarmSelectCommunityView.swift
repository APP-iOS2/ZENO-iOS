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
    let communityArray: [Community]
    
    var body: some View {
        HStack {
            Button(action: {
                selectedCommunityId = ""
            }, label: {
                Text("전체")
            })
            .padding(.leading)
            
            ScrollView(.horizontal) {
                HStack(spacing: 4) {
                    ForEach(communityArray) { community in
                        AlarmSelectCommunityCellView(selectedCommunityId: $selectedCommunityId, community: community)
                    }
                }
            }
        }
    }
}

struct AlarmSelectCommunityView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmSelectCommunityView(selectedCommunityId: .constant("aaa"), communityArray: [])
    }
}
