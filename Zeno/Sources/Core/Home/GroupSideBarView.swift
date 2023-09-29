//
//  GroupSideBarView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct GroupSideBarView: View {
    @Binding var isPresented: Bool
    // 커뮤니티 정보
    let community: Community
    
    // 현재 알람만 선택이 되어있는지 여부를 따지면 되지만 추후 확장성을 위해 배열로 코딩.
    @State private var clickedButtons: [Bool] = .init(repeating: false, count: 3)
    @State private var selectIndex: Int = 0
    @State private var isSelectContent: Bool = false
    @State private var isSettingPresented: Bool = false
    @State private var isGroupOutAlert: Bool = false
    private let buttonSystemImage: [String] = ["rectangle.portrait.and.arrow.forward",
                                               "bell.slash",
                                               "gearshape"]
    /// Double타입 날짜 String타입으로 변환
    private var convertDate: String {
        let doubleDate: Double = community.createdAt
        let date = Date(timeIntervalSince1970: doubleDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
        
    var body: some View {
        // Group ID를 받아서 알림여부를 가져온다. groupID가 없을때 어떻게 가져오는지는 확인해봐야함.
        @AppStorage(community.id) var isgroupAlarmSaved: Bool = false // 기본값만 지정해준것일뿐 실제 가져온 값은 다를 수 있다.
        
        // isgroupAlarmSaved가 true인 경우 index = 1에 있는 알람의 값을 true로 변경해준다.
        if isgroupAlarmSaved {
            clickedButtons = clickedButtons.enumerated().map { (index, element) in
                if index == 1 {
                    return true
                } else {
                    return element
                }
            }
        }
         
        return VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(community.communityName)
                        .font(.headline)
                    Text("00명 참여중")
                        .font(.caption)
                    Text("생성일 \(convertDate)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .padding(.top, 5)
                .padding(.horizontal)
                
                Divider()
                
                // MARK: 메뉴들
                VStack(alignment: .leading, spacing: 40) {
                    ForEach(GroupSideMenuItem.items) { item in
                        Button(action: {
                            selectIndex = item.id
                            isPresented = false
                            isSelectContent.toggle()
                        }, label: {
                            HStack {
                                Text(item.contents)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        })
                        .tint(.black)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
            }
            
            Spacer()
            
            // MARK: 하단 버튼 뷰
            HStack(spacing: 30) {
                ForEach(Array(buttonSystemImage.enumerated()), id: \.element.hash) { index, name in
                    Button(action: {
                        clickedButtons[index].toggle()
                        
                        switch index {
                        case 0: // 그룹 나가기 alert
                            isGroupOutAlert.toggle()
                        case 1: // 그룹별 알림 여부 Toast하나 만들어서 띄우자. (커스텀 공통으로 가져가기)
                            break
                        case 2: // 그룹 설정
                            isPresented = false
                            isSettingPresented.toggle()
                        default:
                            break
                        }
                    }, label: {
                        if index == 1 {
                            if clickedButtons[index] {
                                Image(systemName: "bell.fill")
                            } else {
                                Image(systemName: name)
                            }
                        } else {
                            Image(systemName: name)
                        }
                    })
                    .foregroundStyle(Color.ggullungColor)
                   
                    if index == 0 { Spacer() }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color.yellow.opacity(0.2))
        }
        .fullScreenCover(isPresented: $isSettingPresented, content: {
            GroupSettingView()
        })
        .fullScreenCover(isPresented: $isSelectContent, content: {
            GroupSideMenuItem.getView(index: selectIndex)
        })
        .alert("그룹에서 나가시겠습니까?", isPresented: $isGroupOutAlert) {
            Button("예", role: .destructive) { groupOut() }
            Button("취소", role: .cancel) { print("취소") }
        } message: {
            Text("해당 그룹으로 진행되던 모든 알림 및 정보들이 삭제됩니다.")
        }
    }
    
    // MARK: Methods
    ///  그룹 탈퇴
    private func groupOut() {
        // 유저의 해당그룹을 서버에서 지우는 로직 구현해야함.
        // 해당그룹의 정보로 사이드바를 구성하였기때문에 사이드바의 Parent뷰가 refresh되어야 함.
        isPresented = false
    }
}

// MARK: 사이드바메뉴 Item 구조체
struct GroupSideMenuItem: Identifiable {
    let id: Int
    let contents: String
    
    static var items: [GroupSideMenuItem] = [
        .init(id: 0, contents: "구성원 관리"),
        .init(id: 1, contents: "그룹 초대")
    ]
    
    @ViewBuilder
    static func getView(index: Int) -> some View {
        switch index {
        case 0:
            Text("첫번째")
        case 1:
            Text("두번째")
        case 2:
            EmptyView()
        default:
            EmptyView()
        }
    }
}

struct GroupSideBarView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            GroupSideBarView(isPresented: .constant(true), community: Community.dummy[0])
        }
    }
}
