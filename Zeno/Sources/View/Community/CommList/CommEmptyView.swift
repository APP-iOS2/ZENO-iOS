//
//  CommEmptyView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommEmptyView: View {
	let action: () -> Void
	
    var body: some View {
        VStack {
            Button {
                action()
            } label: {
                LottieView(lottieFile: "search")
                    .frame(width: .screenWidth * 0.6, height: .screenHeight * 0.2)
                    .overlay {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray4)
                            .offset(x: .screenWidth * 0.17, y: .screenHeight * 0.07)
                }
            }
            
            Text("그룹을 찾거나 만들어보세요 ! ")
                .padding(.top, 10)
				.font(.regular(16))
        }
    }
}

struct CommEmptyView_Previews: PreviewProvider {
    static var previews: some View {
		CommEmptyView(action: { })
    }
}
