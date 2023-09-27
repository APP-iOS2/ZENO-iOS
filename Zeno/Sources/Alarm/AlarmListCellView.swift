//
//  AlarmListCellView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

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
        // .listSectionSpacing(20)
    }
}

struct AlarmListCellView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmListCellView(isShowPaymentSheet: .constant(false), alarm: Alarm(sendUserID: "aa", sendUserName: "aa", recieveUserID: "bb", recieveUserName: "bb", communityID: "cc", zenoID: "dd", zenoString: "zeno", isPaid: false, createdAt: 91842031))
    }
}
