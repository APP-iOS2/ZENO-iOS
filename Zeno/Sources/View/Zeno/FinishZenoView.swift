//
//  FinishZenoView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct FinishZenoView: View {
    @StateObject var timerViewModel = TimerViewModel()

    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if timerViewModel.timesUp == false {
            Group {
                ZStack {
                    VStack {
                        LottieView(lottieFile: "beforeZenoFirst")
                        Text("다음 제노까지 \(timerViewModel.timeRemaining) ")
                            .blueAndBMfont()
                    }
                }
                .onAppear {
                    print("온어피어 나타남")
                    timerViewModel.myZenoTimer = Int(timerViewModel.comparingTime(currentUser: userViewModel.currentUser))
                    timerViewModel.futureData = Calendar.current.date(byAdding: .second, value: Int(timerViewModel.myZenoTimer), to: Date())
                    timerViewModel.updateTimeRemaining()
                }
                .onReceive(timerViewModel.timer) {_ in
                    timerViewModel.updateTimeRemaining()
                }
                .navigationBarBackButtonHidden()
            }
        } else {
            SelectCommunityVer2(isSheetOn: false)
            // TODO: NavigationPath 써야함
            // stack.removeLast()
                .task {
                    print("\(timerViewModel.timesUp)")
            }
        }
    }
}

struct FinishZenoView_Previews: PreviewProvider {
    static var previews: some View {
        FinishZenoView()
            .environmentObject(UserViewModel())
    }
}
