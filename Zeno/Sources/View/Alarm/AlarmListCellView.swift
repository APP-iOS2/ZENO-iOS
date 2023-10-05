//
//  AlarmListCellView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct AlarmListCellView: View {
    @Binding var selectAlarm: Alarm?
    let alarm: Alarm
        
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Circle()
                        .frame(width: 50)
                        .foregroundStyle(.gray)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    Color.hex("EB0FFE"), lineWidth: 2
//                                    Color.hex("0F62FE")
                                )
                        )
                    VStack(alignment: .leading) {
                        Text("멋쟁이 사자처럼 . 여자")
                            .padding(.bottom, 4)
                        Text("3시간 전")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(alarm.zenoString)")
                            .bold()
                        Text("\(alarm.recieveUserName) 님을 선택했습니다.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    
                    Spacer()
                    
                    ShareLink(item: "\(alarm.zenoString)에 \(alarm.recieveUserName) 님을 선택했습니다.") {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.bottom)
            }
            .onTapGesture {
                selectAlarm = alarm
                print("\(selectAlarm?.recieveUserName ?? "error")")
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(alarm.id == selectAlarm?.id ? Color("MainPurple1") : Color(uiColor: .systemGray4))
    }
}

struct AlarmListCellView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmListCellView(selectAlarm: .constant(Alarm(sendUserID: "aa", sendUserName: "aa", recieveUserID: "bb", recieveUserName: "bb", communityID: "cc", showUserID: "1234", zenoID: "dd", zenoString: "zeno", createdAt: 91842031)), alarm: Alarm(sendUserID: "aa", sendUserName: "aa", recieveUserID: "bb", recieveUserName: "bb", communityID: "cc", showUserID: "1234", zenoID: "dd", zenoString: "zeno", createdAt: 91842031))
    }
}
