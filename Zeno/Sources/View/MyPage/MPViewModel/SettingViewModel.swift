//
//  MypageSettingViewModel.swift
//  Zeno
//
//  Created by 박서연 on 2023/10/31.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct MyPageSettingRows: Hashable {
    var title: String
    var link: String
}

final class SettingViewModel: ObservableObject {
    enum alertMessage: String {
        case logout = "로그아웃하시겠습니까?"
        case withdraw = "탈퇴 시 모든 데이터는 삭제되며 복구가 불가능합니다."
    }
    
    var items: [MyPageSettingRows] = [
        .init(title: "질문 추가 요청하기", link: "https://docs.google.com/forms/d/e/1FAIpQLSfKTwKQSx04627mzk8vzve7F3GtrXWoBRYUY-P9ad44HgN0VQ/viewform"),
        .init(title: "Zeno 문의하기", link: "https://forms.gle/7TCpzA8QxgW5EWKw9"),
        .init(title: "개인정보처리방침", link: "https://www.notion.so/muker/fe4abdf9bfa44cac899e77f1092461ee?pvs=4"),
        .init(title: "이용약관", link: "https://www.notion.so/muker/a6553756734d4b619b5e45e70732560b?pvs=4"),
        .init(title: "알림 설정", link: UIApplication.openSettingsURLString)
    ]
    
    @Published var message: alertMessage = .logout
    @Published var showAlert: Bool = false
}

extension SettingViewModel {
    private func rowView(_ label: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
    }
    
    @ViewBuilder
    func linkView(_ label: String, _ url: String) -> some View {
        if let url = URL(string: url) {
            Link(destination: url) {
                rowView(label)
            }
        }
    }
    
    func changeAlertValue() {
        self.showAlert = true
    }
}
