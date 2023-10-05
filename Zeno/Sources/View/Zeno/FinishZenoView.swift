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
    private let currentTime = Date().timeIntervalSince1970

    @State private var myZenoTimer: Int = 0
    @State private var count: Int = 1
    @State private var finishedText: String?
    @State private var timeRemaining = ""
    @State private var isTimeUp = false
    @State private var futureData: Date? // Optional로 선언
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
            }
        }
    }
    
    var body: some View {
        if userViewModel.readyForTimer() {
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
                    // MARK: 다른 뷰일때도 계속 나타남
                    print("온어피어 나타남")
                    myZenoTimer = Int(userViewModel.comparingTime())
                    if let futureDate = Calendar.current.date(byAdding: .second, value: Int(myZenoTimer), to: Date()) {
                        futureData = futureDate
                    }
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
                .task {
                    print("시간 끝남")
                    await userViewModel.updateUserStartAt(to: 0)
                    await userViewModel.updateUserStartZeno(to: false)
            }
        }
    }
    
    func comparingTime() -> Double {
        let currentTime = Date().timeIntervalSince1970

        if let currentUser = userViewModel.currentUser,
           let zenoEndAt = currentUser.zenoEndAt,
           let zenoStartAt = currentUser.zenoStartAt
        {
            return zenoEndAt - currentTime
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
