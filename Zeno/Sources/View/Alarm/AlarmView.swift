//
//  AlarmView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct AlarmView: View {
    @EnvironmentObject private var alarmViewModel: AlarmViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var commViewModel: CommViewModel
    @ObservedObject private var notificationObserver: NotificationObserver = NotificationObserver.shared
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedCommunityId: String = ""
    @State private var isShowPaymentSheet: Bool = false
    @State private var isShowInitialView: Bool = false
    
    @State private var isLackingCoin: Bool = false
    @State private var isLackingInitialTicket: Bool = false
    
    @State private var isPurchaseSheet: Bool = false
    @State private var selectAlarm: Alarm?
    
    @State private var usingCoin: Bool = false
    @State private var usingInitialTicket: Bool = false
    
    @State private var topSafeArea: CGFloat = 0
    
    var isBlur: Bool {
        return isShowPaymentSheet || usingCoin ||  usingInitialTicket ||
        isLackingCoin || isLackingInitialTicket
    }
    
    private var filterAlarmByCommunity: [Alarm] {
        return alarmViewModel.alarmArray.filter({ selectedCommunityId.isEmpty || $0.communityID == selectedCommunityId })
    }
    
    var lackCoin: Int {
        return 60 - (userViewModel.currentUser?.coin ?? 0)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                if alarmViewModel.isFetchComplete == false {
                    ProgressView()
                } else {
                    if commViewModel.joinedComm.isEmpty {
                        AlarmEmptyView()
                    } else {
                        ScrollView {
                            VStack {
                                Text("홈")
                                    .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 20))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .zIndex(1000)
                                    .clipped()
                                GeometryReader { proxy in
                                    let minY = proxy.frame(in: .global).minY
                                    let offsetY = minY < topSafeArea ? minY > 0 ? topSafeArea - minY : topSafeArea + -minY : 0
                                    AlarmSelectCommunityView(selectedCommunityId: $selectedCommunityId)
                                        .zIndex(98)
                                        .background(.background)
                                        .offset(y: offsetY)
                                }
                                .shadow(color: .primary.opacity(colorScheme == .light ? 0.1 : 0.3), radius: 2, y: 2)
                                if filterAlarmByCommunity.isEmpty {
                                    Spacer()
                                        .frame(width: .screenWidth, height: .screenHeight * 0.9)
                                } else {
                                    VStack {
                                        Spacer()
                                            .frame(height: 115)
                                        LazyVStack {
                                            ForEach(filterAlarmByCommunity) { alarm in
                                                if alarm.zenoID == "nudge" {
                                                    AlarmNudgeCellView(selectAlarm: $selectAlarm, alarm: alarm)
                                                        .padding(.bottom, 4)
                                                        .padding(.horizontal)
                                                        .onAppear {
                                                            Task {
                                                                if isLastItem(alarm) {
                                                                    if let currentUser = userViewModel.currentUser {
                                                                        await alarmViewModel.loadMoreData(showUserID: currentUser.id)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                } else {
                                                    AlarmListCellView(selectAlarm: $selectAlarm, alarm: alarm)
                                                        .padding(.bottom, 4)
                                                        .padding(.horizontal)
                                                        .onAppear {
                                                            Task {
                                                                if isLastItem(alarm) {
                                                                    if let currentUser = userViewModel.currentUser {
                                                                        await alarmViewModel.loadMoreData(showUserID: currentUser.id)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                }
                                            }
                                            .navigationDestination(isPresented: $isShowInitialView) {
                                                if let selectAlarm {
                                                    AlarmChangingView(selectAlarm: selectAlarm)
                                                }
                                            }
                                        }
                                        Spacer()
                                    }
                                    // 스크린 높이 - 그룹셀 이미지높이 - topSafeArea - 그룹텍스트 - 그 외 여백 예상높이
                                    .frame(
                                        minHeight:
                                            .isIPhoneSE ?
                                            .screenHeight - 60 - topSafeArea - 7 :
                                                .screenHeight - 60 - topSafeArea - 10 - (.screenHeight * 0.035)
                                    )
                                    .zIndex(-99)
                                    if alarmViewModel.isLoading {
                                        ProgressView()
                                    }
                                }
                            }
                        }
                        .background {
                            if filterAlarmByCommunity.isEmpty {
                                VStack(alignment: .center) {
                                    AlarmListEmptyView()
                                        .offset(y: -.screenHeight * 0.05)
                                }
                            }
                        }
                        .refreshable {
                            if let currentUser = userViewModel.currentUser {
                                Task {
                                    if selectedCommunityId.isEmpty {
                                        await alarmViewModel.fetchAlarmPagenation2(showUserID: currentUser.id)
                                    } else {
                                        await alarmViewModel.fetchAlarmPagenation2(showUserID: currentUser.id, communityID: selectedCommunityId)
                                    }
                                }
                            }
                        }
                        .blur(radius: isBlur ? 1.5 : 0)
                        .goodsAlert(
                            isPresented: $isShowPaymentSheet,
                            content1: "당신을 제노한 사람의 초성을",
                            content2: "확인하시겠습니까 ?",
                            primaryButtonTitle1: "코인 사용",
                            primaryAction1: {
                                if userViewModel.currentUser?.coin ?? 0 >= 60 {
                                    usingCoin = true
                                } else {
                                    print(" 코인 결제 임")
                                    isLackingCoin.toggle()
                                    
                                    isShowPaymentSheet = false
                                }
                            },
                            primaryButtonTitle2: "초성 확인권 사용",
                            primaryAction2: {
                                print("초성확인권 사용")
                                if userViewModel.currentUser?.showInitial ?? 0 > 0 {
                                    usingInitialTicket.toggle()
                                } else {
                                    print(" 유료 결제 임")
                                    // isLackingInitialTicket.toggle()
                                    
                                    isShowPaymentSheet = false
                                }
                            }
                        )
                        .usingAlert(
                            isPresented: $usingCoin,
                            imageName: "c.circle",
                            content: "코인",
                            quantity: userViewModel.currentUser?.coin ?? 0,
                            usingGoods: 60) {
                                isShowInitialView.toggle()
                                Task {
                                    await userViewModel.updateUserCoin(to: -10)
                                }
                                usingCoin = false
                            }
                            .updateAlert(
                                isPresented: $usingInitialTicket,
                                primaryAction1: {
                                    usingInitialTicket.toggle()
                            })
//                        .usingAlert(
//                            isPresented: $usingInitialTicket,
//                            imageName: "ticket",
//                            content: "초성 확인권",
//                            quantity: userViewModel.currentUser?.showInitial ?? 0,
//                            usingGoods: 1) {
//                                isShowInitialView.toggle()
//                                Task {
//                                    await userViewModel.updateUserInitialCheck(to: -1)
//                                }
//                            }
                        .cashAlert(
                            isPresented: $isLackingCoin,
                            imageTitle: nil,
                            title: "코인이 부족합니다.",
                            content: "투표를 통해 코인을 모아보세요.",
                            retainPoint: userViewModel.currentUser?.coin,
                            lackPoint: lackCoin,
                            primaryButtonTitle: "확인",
                            primaryAction: { /* 송금 로직 */ }
                        )
//                        .cashAlert(
//                            isPresented: $isLackingInitialTicket,
//                            imageTitle: nil,
//                            title: "초성확인권이 부족합니다.",
//                            content: "초성확인권을 구매하세요.",
//                            retainPoint: 0,
//                            lackPoint: 1,
//                            primaryButtonTitle: "확인",
//                            primaryAction: { isPurchaseSheet.toggle() }
//                        )
//                        .sheet(isPresented: $isPurchaseSheet, content: {
//                            PurchaseView(isShowPaymentSheet: $isShowPaymentSheet)
//                                .presentationDetents([.fraction(0.4)])
//                                .presentationDragIndicator(.visible)
//                            }
//                        )
                        VStack {
                            GeometryReader { proxy in
                                Color.primary
                                    .colorInvert()
                                    .frame(height: proxy.safeAreaInsets.top, alignment: .top)
                                    .ignoresSafeArea()
                                    .onAppear {
                                        topSafeArea = proxy.safeAreaInsets.top
                                    }
                            }
                            Spacer()
                            
                            Button(action: {
                                if selectAlarm != nil && selectAlarm?.zenoID != "nudge" {
                                    isShowPaymentSheet = true
                                }
                            }, label: {
                                WideButton(buttonName: "초성확인하기", systemImage: "", isplay: selectAlarm != nil && selectAlarm?.zenoID != "nudge" ? true : false)
                            })
                            .disabled(selectAlarm?.zenoID == "nudge" || selectAlarm == nil || isBlur ? true : false)
                            .blur(radius: isBlur ? 1.5 : 0)
                        }
                    }
                }
            }
        }
        .onChange(of: selectedCommunityId) { chgValue in
            if let currentUser = userViewModel.currentUser {
                Task {
                    if chgValue.isEmpty {
                        await alarmViewModel.fetchAlarmPagenation2(showUserID: currentUser.id)
                    } else {
                        await alarmViewModel.fetchAlarmPagenation2(showUserID: currentUser.id, communityID: chgValue)
                    }
                }
            }
            alarmViewModel.isPagenationLast = false
            selectAlarm = nil
        }
        .onChange(of: notificationObserver.newMessageID) { _ in
            if let currentUser = userViewModel.currentUser {
                Task {
                    await alarmViewModel.fetchLastestAlarm(showUserID: currentUser.id)
                }
            }
            alarmViewModel.isPagenationLast = false
        }
    }
    
    private func isLastItem(_ alarm: Alarm) -> Bool {
        if let lastAlarm = alarmViewModel.alarmArray.last {
            return lastAlarm.id == alarm.id
        }
        return false
    }
}

struct AlarmView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmView()
        // 이건 프리뷰니까 생성()
            .environmentObject(AlarmViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(IAPStore())
            .environmentObject(CommViewModel())
    }
}
