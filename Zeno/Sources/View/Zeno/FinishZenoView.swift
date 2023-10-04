//
//  FinishZenoView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct FinishZenoView: View {
    private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var myZenoTimer: Int = 0
    @State private var count: Int = 1
    @State private var finishedText: String?
    @State private var timeRemaining = ""
    @State private var isTimeUp = false
    @State private var futureDate = Calendar.current.date(byAdding: .second, value: Int(self.comparingTime()), to: Date())
    // Optional로 선언
    @State var stack = NavigationPath()
    
    @EnvironmentObject private var userViewModel: UserViewModel
    
    func updateTimeRemaining() {
        if let futureDate = futureData {
            let remaining = Calendar.current.dateComponents([.minute, .second], from: Date(), to: futureDate)
            let minute = remaining.minute ?? 0
            let second = remaining.second ?? 0
            timeRemaining = "\(minute) 분 \(second) 초 남았어요"
            
            if minute == 0 && second <= 0 {
                self.timer.upstream.connect().cancel()
                isTimeUp = true
            }
        }
    }
    
    var body: some View {
        if isTimeUp == false {
            Group {
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
                    updateTimeRemaining()
                }
            }
        } else {
            SelectCommunityVer2()
            // TODO: NavigationPath 써야함
            // stack.removeLast()
                .onAppear {
                    userViewModel.currentUser!.startZeno = false
            }
        }
    }
    
    func comparingTime() -> Double {
        if let currentUser = userViewModel.currentUser {
            let afterZenoTime = currentUser.zenoStartAt + 10
            let currentTime = Date().timeIntervalSince1970
            
            if currentTime >= afterZenoTime {
                return afterZenoTime - currentUser.zenoStartAt
            } else {
                return currentUser.zenoStartAt - afterZenoTime
            }
        } else {
            return 0.0
        }
    }
}

struct FinishZenoView_Previews: PreviewProvider {
    static var previews: some View {
        FinishZenoView()
            .environmentObject(UserViewModel())
    }
}
