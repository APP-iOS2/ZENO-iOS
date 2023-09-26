//
//  ZenoView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct ZenoView: View {
    var body: some View {
        VStack {
            LottieView(lottieFile: "nudgeDevil")
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ZenoView_Previews: PreviewProvider {
    static var previews: some View {
        ZenoView()
    }
}
