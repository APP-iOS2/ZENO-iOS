//
//  AlarmConfettiView.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
import ConfettiSwiftUI

struct AlarmConfettiView: View {
    @State private var counter: Int = 0
    
    var body: some View {
        Button("🎉") {
            counter += 1
        }
        .confettiCannon(counter: $counter, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
    }
}

struct AlarmConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmConfettiView()
    }
}
