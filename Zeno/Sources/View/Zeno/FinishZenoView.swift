//
//  FinishZenoView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct FinishZenoView: View {
    @State private var navigationSwitch: Bool = false
    @State private var stack = NavigationPath()
    @StateObject private var timerViewModel = TimerViewModel()
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        ZStack {
            VStack {
                LottieView(lottieFile: "beforeZenoFirst")
                
                if timerViewModel.timesUp == false {
                    Text("다음 제노까지 \(timerViewModel.timeRemaining) ")
                        .blueAndBMfont()
                } else {
                    Text(" 시간이 다 됐어요! ")
                        .blueAndBMfont()
                        .offset(y: 15)
                    Button {
                        navigationSwitch = true
                    } label: {
                        WideButton(buttonName: "제노하러가기", isplay: true)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigationSwitch) {
            SelectCommunityVer2()
        }
        .onAppear {
            timerViewModel.myZenoTimer = Int(timerViewModel.comparingTime(currentUser: userViewModel.currentUser))
            timerViewModel.futureData = Calendar.current.date(byAdding: .second, value: Int(timerViewModel.myZenoTimer), to: Date())
            timerViewModel.updateTimeRemaining()
        }
        .onReceive(timerViewModel.timer) {_ in
            timerViewModel.updateTimeRemaining()
        }
        .navigationBarBackButtonHidden()
    }
}

struct FinishZenoView_Previews: PreviewProvider {
    static var previews: some View {
        FinishZenoView()
            .environmentObject(UserViewModel())
    }
}
