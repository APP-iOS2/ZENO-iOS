//
//  AlarmView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct AlarmView: View {
    @EnvironmentObject var alarmViewModel: AlarmViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject var iAPVM: IAPStore = IAPStore()
    @EnvironmentObject var userViewModel: UserViewModel
    @State var communityArray: [Community] = Community.dummy
    
    @State private var selectedCommunityId: String = ""
    @State private var isShowPaymentSheet: Bool = false
    @State private var isShowInitialView: Bool = false
    
    @State private var isLackingCoin: Bool = false
    @State private var isLackingInitialTicket: Bool = false
    
    @State private var isPurchaseSheet: Bool = false
    @State private var selectAlarm: Alarm?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("MainPink3")
                    .ignoresSafeArea()
                
                VStack {
                    AlarmSelectCommunityView(selectedCommunityId: $selectedCommunityId, communityArray: communityArray)
                    
                    ScrollView {
                        ForEach(alarmViewModel.alarmArray.filter { selectedCommunityId.isEmpty || $0.communityID == selectedCommunityId }) { alarm in
                            AlarmListCellView(selectAlarm: $selectAlarm, alarm: alarm)
                        }
                        .navigationDestination(isPresented: $isShowInitialView) {
                            if let selectAlarm {
                                AlarmInitialView(selectAlarm: selectAlarm)
                            }
                        }
                    }
                    .padding()
                    .sheet(isPresented: $isShowPaymentSheet, content: {
                        AlarmInitialBtnView(isPresented: $isShowPaymentSheet, isLackingCoin: $isLackingCoin, isLackingInitialTicket: $isLackingInitialTicket) {
                            isShowInitialView = true
                        }
                        .presentationDetents([.fraction(0.75)])
                    })
                }
                .refreshable {
                    await alarmViewModel.fetchAlarm(showUserID: userViewModel.currentUser?.id ?? "")
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
                  primaryAction: { isPurchaseSheet.toggle() }
                )
                .sheet(isPresented: $isPurchaseSheet, content: {
                    PurchaseView()
                        .environmentObject(iAPVM)
                })
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        if selectAlarm != nil {
                            isShowPaymentSheet = true
                        }
                    }, label: {
                        Text("선택하기")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(Color("MainPurple1"))
                    .disabled(selectAlarm == nil ? true : false)
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct AlarmView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmView()
        // 이건 프리뷰니까 생성()
            .environmentObject(AlarmViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(IAPStore())
    }
}
