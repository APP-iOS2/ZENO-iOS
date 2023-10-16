//
//  GeoView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct GeoView: View {
    @Binding var isExpanded: Bool
    @Binding var showtext: Bool

    var color: String
    var text: String = "NEXT"
    var showNextView: Binding<Bool>?
    var shouldToggleExpand: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle().foregroundColor(Color(color))
                    .cornerRadius(85)
                    .frame(width: isExpanded ? max(geometry.size.width, geometry.size.height) * 1.5 : 200,
                           height: isExpanded ? max(geometry.size.width, geometry.size.height) * 1.5 : 200)
                
                if !isExpanded {
                    HStack {
                        Text(text)
                            .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 25))
                        Image(systemName: "arrow.right")
                            .bold()
                            .font(.system(size: 25))
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .offset(x: isExpanded ? -250 : 40, y: isExpanded ? -150 : 20)
        }
        .onTapGesture {
            withAnimation(.spring(response: 1, dampingFraction: 0.7)) {
                if shouldToggleExpand {
                    isExpanded .toggle()
                } else {
                    isExpanded = true
                }
                showtext.toggle()

                if let showNextViewBinding = showNextView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showNextViewBinding.wrappedValue.toggle()
                    }
                }
            }
        }
    }
}

//struct GeoView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeoView()
//    }
//}
