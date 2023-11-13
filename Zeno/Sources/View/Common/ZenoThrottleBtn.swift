//
//  ZenoThrottleBtn.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/25.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoThrottleBtn<Label: View>: View {
    private let throttle: Throttle
    let action: () -> Void
    let label: () -> Label
    
    var body: some View {
        Button {
            throttle.run {
                action()
            }
        } label: {
            label()
        }
    }
    
    init(delay: TimeInterval = 1,
         action: @escaping () -> Void,
         label: @escaping () -> Label) {
        self.throttle = Throttle(delay: delay)
        self.action = action
        self.label = label
    }
}

//struct ZenoThrottleBtn_Previews: PreviewProvider {
//    static var previews: some View {
//        ZenoThrottleBtn()
//    }
//}
