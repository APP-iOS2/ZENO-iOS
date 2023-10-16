//
//  AnimationExView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/15.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

// 애니메이션은 .. 프레임이 있어야하는군
// 아니? 애니메이션일때랑, 아닐때랑 차이점이 잇어야함
struct AnimationExView: View {
    @State private var isAnimation = [false, false, false, false]
    var rows = [GridItem(), GridItem()]
    var body: some View {
        VStack {
            LazyHGrid(rows: rows) {
                ForEach(0..<4) { index in
                    Button {
                        isAnimation[index].toggle()
                    } label: {
                        VStack {
                            Text("Haeun\(index)")
                            Image("Image18")
                                .resizable()
                                .frame(width: isAnimation[index] ? 50 : 60, height: isAnimation[index] ? 50 : 60)
                        }
                    }
                }
            }
            
            VStack {
                Image("Image12")
                //                .foregroundColor(isAnimation ? .yellow : .red)
                    .resizable()
//                    .frame(width: isAnimation ? 200 : 210, height: isAnimation ? 200 : 200)
                //                .animation(.spring(), value: isAnimation)
                //                .animation(.interpolatingSpring(mass: 1, stiffness: 200, damping: 13), value: isAnimation)
                //                .animation(.interactiveSpring(), value: isAnimation)
                //                .animation(.easeIn, value: isAnimation)
                //                .animation(.spring(response: 0.1,dampingFraction: 0.1), value: isAnimation)
                
//                Button("Animate") {
//                    isAnimation.toggle()
//                }
            }
        }
    }
}
struct AnimationExView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationExView()
    }
}
