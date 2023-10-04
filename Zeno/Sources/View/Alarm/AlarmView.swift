//
//  AlarmView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct AlarmView: View {
    @StateObject var alarmVM: AlarmViewModel = AlarmViewModel()
	@State var communityArray: [Community] = Community.dummy
    
    @State private var selectedCommunityId: String = ""
    @State private var isShowPaymentSheet: Bool = false
    @State private var isShowInitialView: Bool = false
    
    @State private var isLackingCoin: Bool = false
    @State private var isLackingInitialTicket: Bool = false
    
    @State private var selectAlarm: Alarm?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    AlarmSelectCommunityView(selectedCommunityId: $selectedCommunityId, communityArray: communityArray)
                    
                    List {
                        ForEach(alarmVM.alarmArray.filter { selectedCommunityId == "" || $0.communityID == selectedCommunityId }) { alarm in
                            AlarmListCellView(selectAlarm: $selectAlarm, alarm: alarm)
                        }
                        .navigationDestination(isPresented: $isShowInitialView) {
                            if let selectAlarm {
                                AlarmInitialView(selectAlarm: selectAlarm)
                            }
                        }
                    }
                    .sheet(isPresented: $isShowPaymentSheet, content: {
                        // TODO: 알람 정보 넘겨주기
                        AlarmInitialBtnView(isPresented: $isShowPaymentSheet, isLackingCoin: $isLackingCoin, isLackingInitialTicket: $isLackingInitialTicket) {
                            isShowInitialView = true
                        }
                        .presentationDetents([.fraction(0.75)])
                    })
                    
                    Button(action: {
                        if let selectAlarm {
                            isShowPaymentSheet = true
                        }
                    }, label: {
                        Text("선택하기")
                    })
                    .buttonStyle(.borderedProminent)
                }
                .blur(radius: isShowPaymentSheet ? 1.5 : 0)
                .cashAlert(
                  isPresented: $isLackingCoin,
                  title: "코인이 부족합니다.",
                  content: "투표를 통해 코인을 모아보세요.",
                  primaryButtonTitle: "확인",
                  primaryAction: { /* 송금 로직 */ }
                )
                .cashAlert(
                  isPresented: $isLackingInitialTicket,
                  title: "초성확인권이 부족합니다.",
                  content: "초성확인권을 구매하세요.",
                  primaryButtonTitle: "확인",
                  primaryAction: { /* 송금 로직 */ }
                )
            }
        }
    }
}

struct AlarmView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmView()
            .environmentObject(AlarmViewModel())
            .environmentObject(UserViewModel())
    }
}
