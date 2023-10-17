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
    @EnvironmentObject var commViewModel: CommViewModel
    
    @State private var selectedCommunityId: String = ""
    @State private var isShowPaymentSheet: Bool = false
    @State private var isShowInitialView: Bool = false
    
    @State private var isLackingCoin: Bool = false
    @State private var isLackingInitialTicket: Bool = false
    
    @State private var isPurchaseSheet: Bool = false
    @State private var selectAlarm: Alarm?
    
    @State private var usingCoin: Bool = false
    @State private var usingInitialTicket: Bool = false
    
    var isBlur: Bool {
        return isShowPaymentSheet || usingCoin ||  usingInitialTicket ||
                isLackingCoin || isLackingInitialTicket
    }
    
    private var filterAlarmByCommunity: [Alarm] {
        return alarmViewModel.alarmArray.filter({ selectedCommunityId.isEmpty || $0.communityID == selectedCommunityId })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if alarmViewModel.isFetchComplete == false {
                    ProgressView()
                } else {
                    if commViewModel.joinedComm.isEmpty {
                        AlarmEmptyView()
                    } else {
                        VStack {
                            ScrollView {
                                Text("홈")
                                    .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 20))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                
                                if filterAlarmByCommunity.isEmpty {
                                    AlarmSelectCommunityView(selectedCommunityId: $selectedCommunityId)
                                    if alarmViewModel.isLoading {
                                        ProgressView()
                                    } else {
                                        AlarmListEmptyView()
                                    }
                                } else {
                                    LazyVStack(pinnedViews: .sectionHeaders) {
                                        Section {
                                            ForEach(filterAlarmByCommunity) { alarm in
                                                AlarmListCellView(selectAlarm: $selectAlarm, alarm: alarm)
                                                    .padding(.bottom, 4)
                                                    .padding(.horizontal)
                                                    .onAppear {
                                                        Task {
                                                            if isLastItem(alarm) {
                                                                if let currentUser = userViewModel.currentUser {
                                                                    await alarmViewModel.loadMoreData(showUserID: currentUser.id)
                                                                    print("======alarmViewModel.loadMoreData")
                                                                }
                                                            }
                                                        }
                                                    }
                                            }
                                        } header: {
                                            AlarmSelectCommunityView(selectedCommunityId: $selectedCommunityId)
                                                .background(.background)
                                        }
                                        .navigationDestination(isPresented: $isShowInitialView) {
                                            if let selectAlarm {
                                                AlarmChangingView(selectAlarm: selectAlarm)
                                            }
                                        }
                                        
                                        if alarmViewModel.isLoading {
                                            ProgressView()
                                        }
                                    }
                                }
                                // 버튼에 하위 셀이 가려지는 경우 or 데이터 없는 경우 refreshable 동작을 위해 추가
//                                Color.clear.frame(height: 80)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .screenHeight * 1.2)
                            .refreshable {
                                if let currentUser = userViewModel.currentUser {
                                    Task {
                                        await alarmViewModel.fetchLastestAlarm(showUserID: currentUser.id)
                                    }
                                }
                            }
                        }
                        //                    .shadow(color: .ggullungColor.opacity(0.4), radius: 5, y: 3)
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
                                    isLackingInitialTicket.toggle()
                                    
                                    isShowPaymentSheet = false
                                }
                            },
                            primaryButtonTitle3: "다음에",
                            primaryAction3: {
                                isShowPaymentSheet = false
                            })
                        .usingAlert(
                            isPresented: $usingCoin,
                            imageName: "c.circle",
                            content: "코인",
                            quantity: userViewModel.currentUser?.coin ?? 0,
                            usingGoods: 60) {
                                isShowInitialView.toggle()
                                Task {
                                    await userViewModel.updateUserCoin(to: -60)
                                }
                                usingCoin = false
                            }
                        .usingAlert(
                            isPresented: $usingInitialTicket,
                            imageName: "ticket",
                            content: "초성 확인권",
                            quantity: userViewModel.currentUser?.showInitial ?? 0,
                            usingGoods: 1) {
                                isShowInitialView.toggle()
                                Task {
                                    await userViewModel.updateUserInitialCheck(to: -1)
                                }
                        }
                        .cashAlert(
                            isPresented: $isLackingCoin,
                            imageTitle: nil,
                            title: "코인이 부족합니다.",
                            content: "투표를 통해 코인을 모아보세요.",
                            primaryButtonTitle: "확인",
                            primaryAction: { /* 송금 로직 */ }
                        )
                        .cashAlert(
                            isPresented: $isLackingInitialTicket,
                            imageTitle: nil,
                            title: "초성확인권이 부족합니다.",
                            content: "초성확인권을 구매하세요.",
                            primaryButtonTitle: "확인",
                            primaryAction: { isPurchaseSheet.toggle() }
                        )
                        .sheet(isPresented: $isPurchaseSheet, content: {
                            PurchaseView()
                                .presentationDetents([.fraction(0.75)])
                                .presentationDragIndicator(.visible)
                            })
                        
                        VStack {
                            GeometryReader { reader in
                                Color.primary
                                    .colorInvert()
                                    .frame(height: reader.safeAreaInsets.top, alignment: .top)
                                    .ignoresSafeArea()
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
        .onChange(of: selectedCommunityId) { _ in
            if let currentUser = userViewModel.currentUser {
                Task {
                    if selectedCommunityId.isEmpty {
                        await alarmViewModel.fetchAlarmPagenation2(showUserID: currentUser.id)
                    } else {
                        await alarmViewModel.fetchAlarmPagenation2(showUserID: currentUser.id, communityID: selectedCommunityId)
                    }
                }
            }
            alarmViewModel.isPagenationLast = false
            selectAlarm = nil
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
