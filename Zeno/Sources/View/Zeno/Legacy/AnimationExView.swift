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
    @State private var imgAnimation = false
    @State private var isAnimation = [false, false, false, false]
    var imfine: [String] = ["user1","user2","user3", "user4"]
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
//                                .frame(width: 50, height: 50)
                                .frame(width: isAnimation[index] ? 50 : 60, height: isAnimation[index] ? 50 : 60)
//                                .animation(.interpolatingSpring(mass: 1, stiffness: 200, damping: 13), value: isAnimation)
                                .animation(.spring(response: 0.1, dampingFraction: 0.1), value: isAnimation)
                        }
                    }
                }
            }
            
            VStack {
                Image("Image12")
                //                .foregroundColor(isAnimation ? .yellow : .red)
//                    .resizable()
//                    .frame(width: imgAnimation ? 200 : 210, height: imgAnimation ? 200 : 200)
                //                .animation(.spring(), value: isAnimation)
                //                .animation(.interpolatingSpring(mass: 1, stiffness: 200, damping: 13), value: isAnimation)
//                                .animation(.interactiveSpring(), value: imgAnimation)
//                    .animation(.easeOut(duration: 0.4), value: imgAnimation)
//                                .animation(.spring(response: 0.1,dampingFraction: 0.1), value: imgAnimation)
                
                Button("Animate") {
                    imgAnimation.toggle()
                }
            }
        }
    }
}
struct AnimationExView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationExView()
    }
}
