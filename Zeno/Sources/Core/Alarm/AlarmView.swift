//
//  AlarmView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct AlarmView: View {
    // MARK: 프로토타입 Test 데이터
    @State var alarmArray: [Alarm] = [Alarm(sendUserID: "sendId", sendUserName: "sendUser", recieveUserID: "recieveId", recieveUserName: "홍길동1", communityID: "commId", zenoID: "zenoId", zenoString: "친해지고 싶은 사람", createdAt: 3015982301), Alarm(sendUserID: "sendId", sendUserName: "sendUser", recieveUserID: "recieveId", recieveUserName: "홍길동2", communityID: "commId", zenoID: "zenoId", zenoString: "친해지고 싶은 사람", createdAt: 3015982301)]
    @State var communityArray: [Community] = [Community(communityName: "aaa", description: "bbb", createdAt: 10924810),
                                              Community(communityName: "bbb", description: "bbb", createdAt: 10924810),
                                              Community(communityName: "ccc", description: "bbb", createdAt: 10924810),
                                              Community(communityName: "ddd", description: "bbb", createdAt: 10924810),
                                              Community(communityName: "eee", description: "bbb", createdAt: 10924810),
                                              Community(communityName: "fff", description: "bbb", createdAt: 10924810),
                                              Community(communityName: "ggg", description: "bbb", createdAt: 10924810),
                                              Community(communityName: "hhh", description: "bbb", createdAt: 10924810),
                                              Community(communityName: "iii", description: "bbb", createdAt: 10924810)]
    
    @State private var selectedCommunityId: String = ""
    @State private var isShowPaymentSheet: Bool = false
    @State private var isShowInitialView: Bool = false
    
    @State private var isLackingCoin: Bool = false
    @State private var isLackingInitialTicket: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    AlarmSelectCommunityView(selectedCommunityId: $selectedCommunityId, communityArray: communityArray)
                    
                    //            List(alarmArray.filter{$0.communityID == selectedCommunityId}) { alarm in
                    List {
                        ForEach(alarmArray) { alarm in
                            AlarmListCellView(isShowPaymentSheet: $isShowPaymentSheet, alarm: alarm)
                        }
                        .navigationDestination(isPresented: $isShowInitialView) {
                            AlarmInitialView()
                        }
                    }
                    .sheet(isPresented: $isShowPaymentSheet, content: {
                        // TODO: 알람 정보 넘겨주기
                        AlarmInitialBtnView(isPresented: $isShowPaymentSheet, isLackingCoin: $isLackingCoin, isLackingInitialTicket: $isLackingInitialTicket) {
                            isShowInitialView = true
                        }
                        .presentationDetents([.fraction(0.75)])
                    })
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
    }
}
