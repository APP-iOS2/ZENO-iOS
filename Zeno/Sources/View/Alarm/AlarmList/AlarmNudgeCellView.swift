//
//  AlarmNudgeCellView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/18.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

struct AlarmNudgeCellView: View {
    @Binding var selectAlarm: Alarm?
    @EnvironmentObject var communityViewModel: CommViewModel
    @Environment(\.colorScheme) var colorScheme
    let alarm: Alarm
    
    private var getCommunity: (name: String, imageURL: String?) {
        if let community = communityViewModel.getCommunityByID(alarm.communityID) {
            return (community.name, community.imageURL)
        }
        return ("error", nil)
    }
    
    private var getFontColor: Color {
            if alarm.id == selectAlarm?.id || colorScheme == .dark {
                return Color.white
            }
            return Color.gray4
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                if let urlStr = getCommunity.imageURL,
                    let url = URL(string: urlStr) {
                    KFImage(url)
                        .cacheOriginalImage()
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    .black, lineWidth: 1
                                )
                        )
                } else {
                    Image("ZenoIcon")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    .black, lineWidth: 1
                                )
                        )
                }
                VStack(alignment: .leading) {
                    Text("\(getCommunity.name)")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 13))
                    Text("\(alarm.sendUserGender.toString)")
                        .font(.caption2)
                    Text("\(alarm.createdAt.theOtherDay)")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 10))
                }
                
                Spacer()
                
                ShareLink(item: "\(alarm.zenoString)에 \(alarm.receiveUserName) 님을 선택했습니다.") {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 40, height: 40, alignment: .topTrailing)
                }
            }
            .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 14))
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                if let selectCell = selectAlarm, selectCell.id == alarm.id {
                    selectAlarm = nil
                } else {
                    selectAlarm = alarm
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(alarm.receiveUserName)님이")
                        .font(.thin(13))
                        .padding(.bottom, 1)
                    Text("\(alarm.zenoString)에")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 14))
                        .padding(.bottom, 1)
                        .offset(y: -3)
                    HStack(spacing: 0) {
                        Text("답변으로 지목한 친구가 \(alarm.receiveUserName)님을 ")
                            .font(.thin(13))
                        Text("💜 콕 찔렀어요 💜")
                            .font(.bold(14))
                    }
                    .offset(y: -6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let selectCell = selectAlarm, selectCell.id == alarm.id {
                   } else {
                        selectAlarm = alarm
                    }
                }
                
                Spacer()
            }
        }
        .foregroundStyle(getFontColor)
        .padding()
        .background(alarm.id == selectAlarm?.id ? .purple2 : Color.hex("F7F3FF"))
        .clipped()
        .cornerRadius(20)
        .shadow(color: .mainColor, radius: 1, y: 1)
    }
}

struct AlarmNudgeCellView_priview: PreviewProvider {
    static var previews: some View {
        AlarmNudgeCellView(selectAlarm: .constant(Alarm(sendUserID: "aa", sendUserName: "aa", sendUserFcmToken: "sendToken", sendUserGender: .female, receiveUserID: "bb", receiveUserName: "bb", receiveUserFcmToken: "recieveToken", communityID: "cc", showUserID: "1234", zenoID: "dd", zenoString: "zeno", createdAt: 91842031)), alarm: Alarm(sendUserID: "aa", sendUserName: "aa", sendUserFcmToken: "sendToken", sendUserGender: .female, receiveUserID: "bb", receiveUserName: "bb", receiveUserFcmToken: "recieveToken", communityID: "cc", showUserID: "1234", zenoID: "dd", zenoString: "zeno", createdAt: 91842031))
            .environmentObject(CommViewModel())
    }
}
