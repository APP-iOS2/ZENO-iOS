//
//  MypageSettingView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct MypageSettingView: View {
    @EnvironmentObject var mypageVM: MypageViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView(showsIndicators: false) {
                Group {
                    linkView("질문 추가 요청하기", "https://docs.google.com/forms/d/e/1FAIpQLSfKTwKQSx04627mzk8vzve7F3GtrXWoBRYUY-P9ad44HgN0VQ/viewform")
                    Divider()
                    
                    linkView("Zeno 문의하기", "https://forms.gle/7TCpzA8QxgW5EWKw9")
                    Divider()
                    
                    linkView("개인정보처리방침", "https://www.notion.so/muker/fe4abdf9bfa44cac899e77f1092461ee?pvs=4")
                    Divider()
                    
                    linkView("이용약관", "https://www.notion.so/muker/a6553756734d4b619b5e45e70732560b?pvs=4")
                    Divider()
                    
                    linkView("알림 설정", UIApplication.openSettingsURLString)
                }
                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14))
                
                Divider()
              
                Button {
                        showAlert = true
                        alertMessage = "로그아웃하시겠습니까?"                    
                } label: {
                    HStack {
                        Text("로그아웃")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.right")
                    }
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14))
                    .padding()
                }
                
                Divider()
                      
                Button {
                      showAlert = true
                      alertMessage = "탈퇴 시 모든 데이터는 삭제되며 복구가 불가능합니다."                    
                } label: {
                    Text("회원탈퇴")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.red)
                }
                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 10))
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .foregroundColor(.primary)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("확인"),
                    message: Text(alertMessage),
                    primaryButton: .destructive(Text("확인")) {
                        if alertMessage == "로그아웃하시겠습니까?" {
                            print("회원 로그아웃됨")
                            Task {
                                await LoginManager(delegate: mypageVM).logout()                               
                                SignStatusObserved.shared.isNeedLogin = true
                            }
                        } else if alertMessage == "탈퇴 시 모든 데이터는 삭제되며 복구가 불가능합니다." {
                            print("회원탈퇴됨")
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
    
    private func rowView(_ label: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
    }
    
    @ViewBuilder
    private func linkView(_ label: String, _ url: String) -> some View {
        if let url = URL(string: url) {
            Link(destination: url) {
                rowView(label)
            }
        }
    }
}

struct MypageSettingView_Previews: PreviewProvider {
    static var previews: some View {
        MypageSettingView()
            .environmentObject(MypageViewModel())
    }
}
