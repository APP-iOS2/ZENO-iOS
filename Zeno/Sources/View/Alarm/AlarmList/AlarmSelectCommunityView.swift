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
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    VStack {
                        Image("All1")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .shadow(color: .ggullungColor.opacity(0.3), radius: 3)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        AngularGradient(gradient: Gradient(colors: [.red, .yellow, .purple, .red]), center: .center), lineWidth: 3
                                    )
                                    .opacity(selectedCommunityId.isEmpty ? 1 : 0)
                            )
                            .onTapGesture {
                                selectedCommunityId = ""
                            }
                        Text("전체")
                            .font(.footnote)
                            .frame(width: 72)
                    }
                    .padding(.leading, 5)
                    ForEach(communityViewModel.joinedComm) { community in
                        AlarmSelectCommunityCellView(selectedCommunityId: $selectedCommunityId, community: community)
                    }
                }
            }
        }
    }
}

struct AlarmSelectCommunityView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmSelectCommunityView(selectedCommunityId: .constant("aaa"))
            .environmentObject(CommViewModel())
    }
}
