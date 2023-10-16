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
        HStack(spacing: 1) {
            Button {
                isButtonTapped.toggle()
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: 10)
            if isButtonTapped {
                HStack(spacing: 2) {
                    Text("제노 초성 확인권 잔여 횟수")
                        .foregroundColor(Color.black)
                        .font(.system(size: 10, weight: .thin))
                    Button {
                        isButtonTapped.toggle()
                    } label: {
                        Image(systemName: "x.circle")
                            .font(.system(size: 10, weight: .thin))
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

struct InformationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        InformationButtonView()
    }
}
