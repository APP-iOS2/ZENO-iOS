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
    let label: () -> Label
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: "chevron.backward")
                label()
                    .padding(.leading, 30)
            }
        }
        .tint(.primary)
        .padding()
    }
}
