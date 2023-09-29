//
//  GroupSettingView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/28.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct GroupSettingView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Button(action: {
                dismiss()
            }, label: {
                Text("뒤로가기")
            })
            Text("Hello, World!")
        }
    }
}

struct GroupSettingView_Prieviews: PreviewProvider {
    static var previews: some View {
        GroupSettingView()
    }
}
