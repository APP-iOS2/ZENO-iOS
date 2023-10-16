//
//  InformationButtonView.swift
//  Zeno
//
//  Created by 박서연 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct InformationButtonView: View {
    @State var isButtonTapped: Bool = false
    
    var body: some View {
        VStack {
            Button {
                isButtonTapped.toggle()
            } label: {
                Image(systemName: "info.circle")
            }
            if isButtonTapped {
//                .overlay(
//                    VStack {
                            Rectangle()
                                .frame(width: 200, height: 100)
                                .foregroundColor(Color.blue)
                                .overlay(
                                    Text("Hello, SwiftUI!")
                                        .foregroundColor(Color.white)
                                        .font(.title)
                                )
//                    }
//                )
            }
        }
    }
}

struct InformationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        InformationButtonView()
    }
}
