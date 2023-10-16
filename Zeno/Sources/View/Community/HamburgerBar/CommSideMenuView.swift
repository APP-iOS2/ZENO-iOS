//
//  CommSideMenuView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/28.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommSideMenuView: View {
    @Binding var isPresented: Bool
    let comm: Community
    
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                Color.black.opacity(isPresented ? 0.3 : 0)
                    .edgesIgnoringSafeArea(.vertical)
                    .onTapGesture {
                        isPresented = false
                    }
                    .animation(.easeIn(duration: 0.2), value: isPresented)
                ZStack {
                    Color.primary
                        .edgesIgnoringSafeArea(.bottom)
                        .colorInvert()
						.padding(.top, 35)
                    CommSideBarView(isPresented: $isPresented)
                }
                .frame(width: geometry.size.width * 0.8)
                .offset(x: isPresented ? dragOffset : geometry.size.width)
                .animation(.easeInOut(duration: 0.45), value: isPresented)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let valueTemp = value.translation.width
                        if valueTemp >= 0 { dragOffset = valueTemp }
                    }
                    .onEnded { value in
                        if value.translation.width > geometry.size.width * 0.4 {
                            isPresented = false
                        }
                        dragOffset = 0
                    }
            )
        }
    }
}

#if DEBUG
struct SideMenuView_Preview: PreviewProvider {
    struct SideTestMainView: View {
        @State private var isPresented: Bool = true
        
        var body: some View {
            ZStack {
                Color.teal.opacity(0.5)
                VStack(alignment: .trailing) {
                    HStack {
                        Spacer()
                        Button("사이드바") {
                            isPresented.toggle()
                        }
                        .tint(.black)
                    }
                    Spacer()
                }
                .padding()
            }
            .overlay(CommSideMenuView(isPresented: $isPresented, comm: Community.dummy[0]))
        }
    }
    
    static var previews: some View {
        SideTestMainView()
            .environmentObject(CommViewModel())
            .environmentObject(UserViewModel())
    }
}
#endif
