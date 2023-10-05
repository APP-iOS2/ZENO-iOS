//
//  AlarmSelectCommunityCellView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct AlarmSelectCommunityCellView: View {
    @Binding var selectedCommunityId: String
    let community: Community
    
    var body: some View {
        VStack {
            Circle()
                .frame(width: 60)
                .overlay(
                    Circle()
                        .strokeBorder(
                            AngularGradient(gradient: Gradient(colors: [.red, .yellow, .purple, .red]), center: .center), lineWidth: 3
                        )
                        .opacity(community.id == selectedCommunityId ? 1 : 0)
                )
                .onTapGesture {
                    selectedCommunityId = community.id
                }
            Text("\(community.communityName)")
                .font(.footnote)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 72)
        }
        .padding(.vertical)
    }
}

struct AlarmSelectCommunityCellView_Preview: PreviewProvider {
    static var previews: some View {
		AlarmSelectCommunityCellView(selectedCommunityId: .constant("aaa"), community: Community.dummy[0])
    }
}
