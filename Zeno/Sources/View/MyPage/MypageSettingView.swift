//
//  MypageSettingView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct MypageSettingView: View {
    @ObservedObject var mypageVM: MypageViewModel
    @StateObject private var settingViewModel = SettingViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView(showsIndicators: false) {
                ForEach(settingViewModel.items, id: \.self) { item in
                    settingViewModel.linkView(item.title, item.link)
                    Divider()
                }
                logoutButtonView(settingViewModel: settingViewModel)
                withdrawButtonView(settingViewModel: settingViewModel)
            }
            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14))
            .foregroundColor(.primary)
            .zenoWarning(MypageViewModel.RemoveFailReason.communityExists.toString(),
                         isPresented: $mypageVM.isUserDataDeleteFailAlert)
            .alert(isPresented: $settingViewModel.showAlert) {
                Alert(
                    title: Text("확인"),
                    message: Text(settingViewModel.message.rawValue),
                    primaryButton: .destructive(Text("확인")) {
                        switch settingViewModel.message {
                        case .logout:
                            Task {
                                await LoginManager(delegate: mypageVM).logout()
                                SignStatusObserved.shared.isNeedLogin = true
                            }
                        case .withdraw:
                            Task {
                                await LoginManager(delegate: mypageVM).memberRemove()
                                SignStatusObserved.shared.isNeedLogin = true
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
    }
}

private struct logoutButtonView: View {
    @ObservedObject var settingViewModel: SettingViewModel
    
    fileprivate var body: some View {
        Button {
            settingViewModel.changeAlertValue()
            settingViewModel.message =  .logout
        } label: {
            HStack {
                Text("로그아웃")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14))
            .padding()
        }
        
        Divider()
    }
}

private struct withdrawButtonView: View {
    @ObservedObject var settingViewModel: SettingViewModel
    
    fileprivate var body: some View {
        Button {
            settingViewModel.changeAlertValue()
            settingViewModel.message = .withdraw
        } label: {
            Text("회원탈퇴")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.red)
        }
        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14))
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct MypageSettingView_Previews: PreviewProvider {
    static var previews: some View {
        MypageSettingView(mypageVM: MypageViewModel())
    }
}
