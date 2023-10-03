//
//  FinishZenoView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct FinishZenoView: View {
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var count: Int = 1
    @State private var finishedText: String?
    @State private var timeRemaining = ""
    let futureData: Date = Calendar.current.date(byAdding: .second, value: 20, to: Date()) ?? Date()
    
    func updateTimeRemaining() {
        let remaining = Calendar.current.dateComponents([.minute, .second], from: Date(), to: futureData)
        let minute = remaining.minute ?? 0
        let second = remaining.second ?? 0
        timeRemaining = "\(minute) 분 \(second) 초 남았어요"
        
        if timeRemaining == "0 분 0 초 남았어요" {
            self.timer.upstream.connect().cancel()
        }
    }
    
    var body: some View {
        if timeRemaining == "0 분 0 초 남았어요" {
                        SelectCommunityView()
                    }
        ZStack {
            VStack {
                LottieView(lottieFile: "beforeZenoFirst")
                Text("다음 제노까지 \(timeRemaining) ")
                    .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 20))
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.ggullungColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .offset(y: -.screenHeight * 0.2)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) {_ in
//            withAnimation(.default) {
//                count = count == 5 ? 1 : count + 1
//            }
            updateTimeRemaining()
        }
    }
}

struct FinishZenoView_Previews: PreviewProvider {
    static var previews: some View {
        FinishZenoView()
    }
}
