//
//  TestImage.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/11.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct TestImage: View {
    var body: some View {
        Image("Image1")
            .resizable()
            .frame(width: 300, height: 200)
            .scaledToFit()
    }
}

struct TestImage_Previews: PreviewProvider {
    static var previews: some View {
        TestImage()
    }
}
