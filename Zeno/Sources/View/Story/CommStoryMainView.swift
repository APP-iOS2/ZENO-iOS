//
//  CommStoryMainView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/12.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommStoryMainView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingSheet: Bool = false
    
    // 뷰에서는 리턴 값이 하나만 튀어나와야한다.
    // 얘는 연산 프로퍼티..인가?
    // TODO: 공부하기
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                VStack {
                    ZStack {
                        Rectangle()
                            // TODO: 강사님께도 여쭤보기
                            //.offset(x: -30)
                            .cornerRadius(10)
                            .foregroundColor(.gray3)
                            .frame(width: 80, height: 98)
                            .opacity(0.6)
                        
                        Image(systemName: "plus")
                            .foregroundColor(.gray4)
                            .opacity(0.8)
                    }
                    
                    Text("만들기")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 11))
                }
                .onTapGesture {
                    isShowingSheet = true
                }
                
                showStoryViews()
            }
        }
        .fullScreenCover(isPresented: $isShowingSheet) {
            MakeStoryView()
        }
    }
    
    func showStoryViews() -> some View {
        ForEach(0..<4) { _ in
            VStack {
                ZStack {
                    Rectangle()
                        .cornerRadius(10)
                        .foregroundColor(.mainColor)
                        .frame(width: 80, height: 98)
                    .opacity(0.6)
                    
                    VStack {
                        Text("아 오늘")
                        Text(" 개 쩔었다!!!!!")
                    }
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 11))
                    
                    Image("woman1")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .offset(y: 38)
                }
                
                Text("황멋사")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 11))
            }
        }
    }
}

struct CommStoryMainView_Previews: PreviewProvider {
    static var previews: some View {
        CommStoryMainView()
    }
}
