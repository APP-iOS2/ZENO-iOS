//
//  AlarmView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct AlarmSelectCommunityCellView: View {
    @Binding var selectedCommunityId: String
    let community: Community
    
    var body: some View {
        VStack {
            Circle()
                .frame(width: 60)
                .overlay(
                    Circle()
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 2))
                        .opacity(community.id == selectedCommunityId ? 1 : 0)
                )
                .onTapGesture {
                    selectedCommunityId = community.id
                }
            Text("\(community.communityName)")
        }
        .padding(.vertical)
    }
}

struct AlarmSelectCommunityView: View {
    @Binding var selectedCommunityId: String
    let communityArray: [Community]
    
    var body: some View {
        HStack {
            Button(action: {
                selectedCommunityId = ""
            }, label: {
                Text("전체")
            })
            .padding(.leading)
            
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(communityArray) { community in
                        AlarmSelectCommunityCellView(selectedCommunityId: $selectedCommunityId, community: community)
                    }
                }
            }
            .padding()
        }
    }
}

struct AlarmListCellView: View {
    @Binding var isShowPaymentSheet: Bool
    let alarm: Alarm
    
    var body: some View {
        Section {
            ZStack {
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 70)
                        .foregroundStyle(.green)
                    
                    VStack {
                        Text("\(alarm.zenoString)")
                            .font(.title3)
                        + Text("에 \(alarm.recieveUserName) 님을 선택했습니다.")
                    }
                    .onTapGesture {
                        isShowPaymentSheet = true
                    }
                        
                }
                // TODO: 커뮤니티 사진 클릭해도 공유 기능이 동작된다. 터치영역 수정해야 함
                ShareLink(item: "\(alarm.zenoString)에 \(alarm.recieveUserName) 님을 선택했습니다.") {
                    Image(systemName: "square.and.arrow.up")
                        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .bottomTrailing)
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 12, leading: -20, bottom: 20, trailing: 12))
        .listSectionSpacing(20)
    }
}

struct AlarmView: View {
    // MARK: 프로토타입 Test 데이터
    @State var alarmArray: [Alarm] = [Alarm(sendUserID: "sendId", sendUserName: "sendUser", recieveUserID: "recieveId", recieveUserName: "홍길동1", communityID: "commId", zenoID: "zenoId", zenoString: "친해지고 싶은 사람", isPaid: false, createdAt: 3015982301), Alarm(sendUserID: "sendId", sendUserName: "sendUser", recieveUserID: "recieveId", recieveUserName: "홍길동2", communityID: "commId", zenoID: "zenoId", zenoString: "친해지고 싶은 사람", isPaid: false, createdAt: 3015982301)]
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
        VStack {
            AlarmSelectCommunityView(selectedCommunityId: $selectedCommunityId, communityArray: communityArray)
            
//            List(alarmArray.filter{$0.communityID == selectedCommunityId}) { alarm in
            List(alarmArray) { alarm in
                AlarmListCellView(isShowPaymentSheet: $isShowPaymentSheet, alarm: alarm)
            }
            .sheet(isPresented: $isShowPaymentSheet, content: {
                // TODO: 알람 정보 넘겨주기
                EmptyView()
            })
        }
    }
}

#Preview {
    AlarmView()
}
