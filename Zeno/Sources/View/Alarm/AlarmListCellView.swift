//
//  AlarmListCellView.swift
//  Zeno
//
//  Created by Hyo Myeong Ahn on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

struct AlarmListCellView: View {
    @Binding var selectAlarm: Alarm?
    @EnvironmentObject var communityViewModel: CommViewModel
    let alarm: Alarm
    
    var getCommunity: (name: String, imageURL: String?) {
        if let community = communityViewModel.getCommunityByID(alarm.communityID) {
            return (community.name, community.imageURL)
        }
        return ("error", nil)
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                if let urlStr = getCommunity.imageURL,
                    let url = URL(string: urlStr) {
                    KFImage(url)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    alarm.sendUserGender == .female ? Color.hex("EB0FFE") : Color.hex("0F62FE"), lineWidth: 2
                                )
                        )
                } else {
                    Circle()
                        .frame(width: 50)
                        .foregroundStyle(.gray)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    alarm.sendUserGender == .female ? Color.hex("EB0FFE") : Color.hex("0F62FE"), lineWidth: 2
                                )
                        )
                }
                VStack(alignment: .leading) {
                    Text("\(getCommunity.name) . \(alarm.sendUserGender.toString)")
                        .padding(.bottom, 4)
                    Text("3시간 전")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                ShareLink(item: "\(alarm.zenoString)에 \(alarm.receiveUserName) 님을 선택했습니다.") {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 40, height: 40, alignment: .topTrailing)
                }
            }
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                selectAlarm = alarm
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(alarm.zenoString)")
                        .bold()
                    Text("\(alarm.receiveUserName) 님을 선택했습니다.")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectAlarm = alarm
                }
                
                Spacer()
            }
        }
        .foregroundStyle(alarm.id == selectAlarm?.id ? .white : .gray)
        .padding()
        .background(alarm.id == selectAlarm?.id ? .purple2 : Color(uiColor: .systemGray6))
        .clipped()
        .cornerRadius(20)
    }
}

struct AlarmListCellView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmListCellView(selectAlarm: .constant(Alarm(sendUserID: "aa", sendUserName: "aa", sendUserFcmToken: "sendToken", sendUserGender: .female, receiveUserID: "bb", receiveUserName: "bb", receiveUserFcmToken: "recieveToken", communityID: "cc", showUserID: "1234", zenoID: "dd", zenoString: "zeno", createdAt: 91842031)), alarm: Alarm(sendUserID: "aa", sendUserName: "aa", sendUserFcmToken: "sendToken", sendUserGender: .female, receiveUserID: "bb", receiveUserName: "bb", receiveUserFcmToken: "recieveToken", communityID: "cc", showUserID: "1234", zenoID: "dd", zenoString: "zeno", createdAt: 91842031))
            .environmentObject(CommViewModel())
    }
}
