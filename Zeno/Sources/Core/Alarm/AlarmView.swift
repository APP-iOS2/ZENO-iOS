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
    
    var body: some View {
        ZStack {
            VStack {
                AlarmSelectCommunityView(selectedCommunityId: $selectedCommunityId, communityArray: communityArray)
                
                //            List(alarmArray.filter{$0.communityID == selectedCommunityId}) { alarm in
                List(alarmArray) { alarm in
                    AlarmListCellView(isShowPaymentSheet: $isShowPaymentSheet, alarm: alarm)
                }
                //                    .sheet(isPresented: $isShowPaymentSheet, content: {
                //                        // TODO: 알람 정보 넘겨주기
                //                        AlarmInitialBtnView()
                //                            .presentationDetents([.fraction(0.75)])
                //                    })
            }
            .blur(radius: isShowPaymentSheet ? 1.5 : 0)
            
            if isShowPaymentSheet {
                AlarmInitialBtnView()
                    .frame(height: 300)
                    .offset(y: 250)
            }
        }
    }
}

struct AlarmView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmView()
    }
}
