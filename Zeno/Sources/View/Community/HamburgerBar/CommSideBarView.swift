//
//  CommSideBarView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct CommSideBarView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var commViewModel: CommViewModel
    @Binding var isPresented: Bool
    
    @State private var isSelectContent: Bool = false
    @State private var isSettingPresented: Bool = false
    @State private var isGroupOutAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(commViewModel.currentComm?.name ?? "가입된 커뮤니티가 없습니다.")
                        .font(.headline)
                    Text("\(commViewModel.currentComm?.joinMembers.count ?? 0)명 참여중")
                        .font(.caption)
                    Text("생성일 \(commViewModel.currentComm?.createdAt.convertDate ?? "가입된 커뮤니티가 없습니다.")")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .padding(.top, 5)
                .padding(.horizontal)
                Divider()
                VStack(alignment: .leading, spacing: 40) {
                    ForEach(SideMenu.allCases) { item in
                        Button {
                            switch item {
                            case .memberMGMT:
                                isPresented = false
                                isSelectContent.toggle()
                            case .inviteComm:
                                shareText()
                            }
                        } label: {
                            HStack {
                                Text(item.title)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
            }
            Spacer()
            // MARK: 하단 버튼 뷰
            HStack {
                ForEach(SideBarBtn.allCases) { btn in
                    Button {
                        switch btn {
                        case .out:
                            isGroupOutAlert.toggle()
                        case .alert:
                            Task {
                                await userViewModel.commAlertToggle(id: commViewModel.currentComm?.id ?? "")
                            }
                        case .setting:
                            isPresented = false
                            isSettingPresented.toggle()
                        }
                    } label: {
                        if btn == .setting {
                            if commViewModel.isCurrentCommManager {
                                Image(
                                    systemName: btn.getImageStr(isOn: commViewModel.isAlertOn)
                                )
                                .padding(.leading, 30)
                            }
                        } else {
                            Image(
                                systemName: btn.getImageStr(isOn: commViewModel.isAlertOn)
                            )
                        }
                    }
                    if btn == .out {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color.purple.opacity(0.2))
        }
        .foregroundStyle(Color.ggullungColor)
        .fullScreenCover(isPresented: $isSettingPresented) {
            CommSettingView(editMode: .edit)
        }
        .fullScreenCover(isPresented: $isSelectContent) {
            CommUserMgmtView()
        }
        .alert("그룹에서 나가시겠습니까?", isPresented: $isGroupOutAlert) {
            Button("예", role: .destructive) {
                // TODO: 그룹장일경우 manager 권한을 반드시 넘겨야만 탈퇴할 수 있는 로직으로 변경, 그룹넘기기뷰 구현
                Task {
                    guard let currntID = commViewModel.currentComm?.id else { return }
                    await commViewModel.leaveComm()
                    await userViewModel.leaveComm(commID: currntID)
                }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("해당 그룹으로 진행되던 모든 알림 및 정보들이 삭제됩니다.")
        }
    }
    
    enum SideMenu: CaseIterable, Identifiable {
        case memberMGMT, inviteComm
        
        var title: String {
            switch self {
            case .memberMGMT:
                return "구성원 관리"
            case .inviteComm:
                return "그룹 초대"
            }
        }
        
        var id: Self { self }
    }
    
    enum SideBarBtn: CaseIterable, Identifiable {
        case out
        case alert
        case setting
        
        func getImageStr(isOn: Bool) -> String {
            switch self {
            case .out:
                return "rectangle.portrait.and.arrow.forward"
            case .alert:
                return isOn ? "bell.fill" : "bell.slash"
            case .setting:
                return "gearshape"
            }
        }
        
        var id: Self { self }
    }
    
    /// 공유 시트
    private func shareText() {
        guard let url = URL(string: "https://www.naver.com") else { return }
        let activityVC = UIActivityViewController(
            activityItems: ["\(commViewModel.currentComm?.name ?? "커뮤니티 nil")", url],
            applicationActivities: [KakaoActivity(), IGActivity()]
        )
        
        // 공유 제외할 것들. (기본 제공중에서)
//        activityVC.excludedActivityTypes = [.postToTwitter,
//            .postToWeibo,
//            .postToVimeo,
//            .postToFlickr,
//            .postToTencentWeibo,
//            .saveToCameraRoll,
//            .mail,
//            .print,
//            .assignToContact
//        ]
                
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let mainWindow = windowScene.windows.first {
                mainWindow.rootViewController?.present(
                    activityVC,
                    animated: true,
                    completion: {
                        print("공유창 나타나면서 할 작업들?")
                    }
                )
            }
        }
    }
}

struct GroupSideBarView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            CommSideBarView(isPresented: .constant(true))
                .environmentObject(UserViewModel())
                .environmentObject(CommViewModel())
        }
    }
}
