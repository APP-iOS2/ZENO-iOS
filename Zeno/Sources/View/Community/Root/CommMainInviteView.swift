//
//  CommMainInviteView.swift
//  Zeno
//
//  Created by gnksbm on 2023/11/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommMainInviteView: View {
    @EnvironmentObject private var commViewModel: CommViewModel
    
    var body: some View {
        Button {
            commViewModel.inviteWithKakao()
        } label: {
            VStack {
                LottieView(lottieFile: "invitePeople")
                    .frame(width: .screenWidth * 0.6, height: .screenHeight * 0.3)
                    .overlay {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.mainColor)
                            .offset(x: .screenWidth * 0.24, y: .screenHeight * 0.05)
                    }
                Text("친구를 초대해보세요")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 18))
                    .foregroundColor(.primary)
                    .offset(y: .screenHeight * -0.03)
            }
        }
        .frame(height: .screenHeight * 0.55)
    }
}

struct CommMainInviteView_Previews: PreviewProvider {
    static var previews: some View {
        CommMainInviteView()
            .environmentObject(CommViewModel())
    }
}
