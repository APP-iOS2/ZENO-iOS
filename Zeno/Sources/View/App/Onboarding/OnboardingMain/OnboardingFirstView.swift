//
//  OnboardingFirstView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct OnboardingFirstView: View {
    @Binding var showNextView: Bool
    
    @State var isExpanded = false
    @State var showtext = false
    
    var body: some View {
        ZStack {
            GeoView(isExpanded: $isExpanded, showtext: $showtext, color: "MainColor", showNextView: $showNextView)
            
            VStack(alignment: .leading) {
                Text("제노에는 내가 추가한 \n친구들만 등장해요")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 25))
                    .foregroundColor(.white)
            }
            .opacity(isExpanded ? 1 : 0 )
            .scaleEffect(isExpanded ? 1 : 0)
            .offset(x: showtext ? 0 : .screenWidth)
        }
        .ignoresSafeArea()
    }
}

struct OnboardingFirstView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFirstView(showNextView: .constant(false))
    }
}

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
                    .cornerRadius(90)
                    .frame(width: isExpanded ? max(geometry.size.width, geometry.size.height) * 1.5 : 200,
                           height: isExpanded ? max(geometry.size.width, geometry.size.height) * 1.5 : 200)
                
                if !isExpanded {
                    HStack {
                        Text(text)
                            .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                        Image(systemName: "arrow.right")
                    }.bold().font(.system(size: 20))
                        .foregroundColor(.white)                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .offset(x: isExpanded ? -250 : 40, y: isExpanded ? -150 : 20)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.8)) {
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
