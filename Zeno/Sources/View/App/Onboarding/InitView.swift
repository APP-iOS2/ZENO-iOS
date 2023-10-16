//
//  InitView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/11.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct InitView: View {
    @State private var firstGroupVisible = false
    @State private var secondGroupVisible = false

    var body: some View {
        ZStack(alignment: .center) {
            Image("splashBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
            ZStack {
                LottieView(lottieFile: "bubbles")
            }
            Image("ZenoPng")
                .resizable()
                .frame(width: CGFloat.screenHeight == 667 ? 250 : 300, height: CGFloat.screenHeight == 667 ? 250 : 300)
                .offset(y: CGFloat.screenHeight == 667 ? -230 : -250)
            Spacer()
            VStack {
                if firstGroupVisible {
                    withAnimation {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.white)
                                .frame(width: .screenWidth - 35, height: 150)
                                .opacity(0.6)
                                .cornerRadius(11)
                            AlarmCellView()
                        }
                    }
                }
                if secondGroupVisible {
                    withAnimation {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.white)
                                .frame(width: .screenWidth - 35, height: 150)
                                .opacity(0.6)
                                .cornerRadius(11)
                            AlarmCellView(gender: "남자", question: "밈을 가장 잘 아는 사람", commName: "한라산 정복까지", imgString: "man1")
                        }  .offset(y: -60)
                    }
                }
            }
            .offset(y: 150)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 1)) {
                    firstGroupVisible = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    secondGroupVisible = true
                }
            }
        }
    }
}

struct InitView_Previews: PreviewProvider {
    static var previews: some View {
        InitView()
    }
}
