//
//  FinishZenoView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct FinishZenoView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var count: Int = 1
    @State private var finishedText: String? = nil
    @State private var timeRemaining = ""
    let futureData: Date = Calendar.current.date(byAdding: .minute, value: 10, to: Date()) ?? Date()
    
    func updateTimeRemaining() {
        let remaining = Calendar.current.dateComponents([.minute, .second], from: Date(), to: futureData)
        let minute = remaining.minute ?? 0
        let second = remaining.second ?? 0
        timeRemaining = "\(minute) 분 \(second) 초 남았어요"
    }
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [.purple, .indigo]), center: .center, startRadius: 5, endRadius: 500).ignoresSafeArea()
            VStack {
                LottieView(lottieFile: "beforeZenoFirst")
                Text("다음 제노까지 \(timeRemaining) ")
                    .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 20))
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .offset(y: -.screenHeight * 0.2)
            }
        }
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) {_ in
            withAnimation(.default) {
                count = count == 5 ? 1 : count + 1
            }
            updateTimeRemaining()
        }
    }
}

struct FinishZenoView_Previews: PreviewProvider {
    static var previews: some View {
        FinishZenoView()
    }
}
