//
//  CustomNavigationBackBtn.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct ZenoNavigationBackBtn<Label: View>: View {
    let action: () -> Void
    let tailingLabel: () -> Label
    
    var body: some View {
        HStack {
            Button {
                action()
            } label: {
                Image(systemName: "chevron.backward")
            }
            tailingLabel()
                .padding(.leading, 30)
        }
        .tint(.primary)
        .padding()
    }
}
