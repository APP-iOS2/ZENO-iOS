//
//  AlarmCellView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/11.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmCellView: View {
    @State var gender: String = "여자"
    @State var question: String = "한강에서 같이 치맥하고 싶은 사람"
    @State var commName: String = "멋쟁이 사자처럼"
    @State var imgString: String = "woman1"
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                Image(imgString)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.gray)
                
                VStack(alignment: .leading) {
                    Text("\(commName)")
                        .bold()
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                    Text("\(gender)")
                        .font(.caption)
                        .padding(.bottom, 1)
                    Text("20초 전")
                        .font(.caption)
                        .foregroundStyle(.black)
                }
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .frame(width: 40, height: 40)
                    .foregroundColor(.black)
                    .offset(y: -18)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("< \(question) >")
                            .bold()
                        Text("질문에")
                            .font(.system(size: 16))
                    }
                    HStack(spacing: 0) {
                        Text("당신")
                            .bold()
                        Text("을 선택했습니다.")
                    }
                    .offset(y: 2)
                    .font(.system(size: 16))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                
                Spacer()
            }
            .offset(y: -10)
            .foregroundStyle(.black)
            .padding(.bottom)
        }
        .padding(40)
    }
}

struct AlarmCellView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmCellView()
    }
}
