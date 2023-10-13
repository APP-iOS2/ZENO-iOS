//
//  SideMenuView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/28.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

/// 사이드메뉴 제작 프레임
///  - 해당 뷰에서는 애니메이션관련 처리만 관리.
struct SideMenuView: View {
    /// 사이드메뉴 표현 여부
    @Binding var isPresented: Bool
    let comm: Community
    private let widthSizeRate: CGFloat = 0.8  // 지정 너비비율 최대 1
    @State private var dragOffset: CGFloat = 0   // 초기값 0 = 여기서는 x 좌표값을 의미.
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                // 뒷배경
                // opacity는 해당 View를 숨김처리할때도 많이 사용한다. (뷰의 자리를 보존해야할 경우) 공식문서에 나와있음.
                Color.black.opacity(isPresented ? 0.3 : 0)
                    .edgesIgnoringSafeArea(.top)
                    .onTapGesture {
                        isPresented = false
                    }
                    .animation(.easeIn(duration: 0.2), value: isPresented)
                
                // 실제 나타낼 컨텐츠 (widthSizeRate의 비율로 나타내준다.)
                ZStack {
                    Color(uiColor: .systemBackground)
                    
                    CommSideBarView(isPresented: $isPresented)
                }
                .frame(width: geometry.size.width * widthSizeRate)
                // 누르기전에는 x 위치를 width만큼 줘서 화면에서 안보이게 한다.
                // 좌표에 따라 애니메이션의 효과도 달라진다. ex) offset을 주지않으면 기본적으로 fadeIn, fadeOut 효과로 적용.
                .offset(x: isPresented ? dragOffset : geometry.size.width)
                .animation(.easeInOut(duration: 0.45), value: isPresented)
                .gesture(
                    DragGesture()
                        // 동작 중 발생하는 변경사항을 알려준다.
//                        .updating($dragOffset) { (value, state, _) in
//                            let valueTemp = value.translation.width
//                            /* -------------------------------------------------
//                                드래그한 지점이 x좌표 0보다 작으면 왼쪽으로 더 움직이기 때문에
//                                0보다 크거나 같을경우에만 state 변경.
//                                state를 변경하면 dragOffSet이 변경된다고 보면 된다.
//                                현경우에는 onChanged에서 처리해야한다.
//                             --------------------------------------------------- */
//                            if valueTemp >= 0 { state = valueTemp }
//                        }
                        .onChanged { value in
                            let valueTemp = value.translation.width
                            if valueTemp >= 0 { dragOffset = valueTemp }
                        }
                        // onEnded = 드래그 이벤트가 끝났을때 실행됨.
                        .onEnded { value in
                            if value.translation.width > geometry.size.width * 0.4 {
                                // 그 끝난지점부터 다시 offset을 계산해 주면 될거 같은데... 해결!!
                                // updating이 아닌 onchanged에서 직접 dragOffSet을 직접 할당하여 해결!!
                                isPresented = false
                            }
                            dragOffset = 0
                        }
                )
            }
        }
    }
}

#if DEBUG
/// 사이드바 예시뷰
struct SideTestMainView: View {
    @State private var isPresented: Bool = false
    
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
        .overlay(SideMenuView(isPresented: $isPresented, comm: Community.dummy[0]))
    }
}

struct SideMenuView_Preview: PreviewProvider {
    static var previews: some View {
       SideTestMainView2()
            .environmentObject(CommViewModel())
            .environmentObject(UserViewModel())
    }
}
#endif

struct SideMenuView2: View {
    @Binding var isPresented: Bool
    let comm: Community
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                Color.black
                    .opacity(isPresented ? 0.3 : 0)
                    .edgesIgnoringSafeArea(.top)
                    .onTapGesture {
                        isPresented = false
                    }
                CommSideBarView(isPresented: $isPresented)
                    .background(.background)
                    .frame(width: geometry.size.width * 0.8)
                    .offset(x: isPresented ? dragOffset : geometry.size.width)
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
            .animation(.easeInOut(duration: 0.45), value: isPresented)
        }
    }
}

struct SideTestMainView2: View {
    @State private var isPresented: Bool = false
    
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
        .overlay(SideMenuView2(isPresented: $isPresented, comm: Community.dummy[0]))
    }
}
