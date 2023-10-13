//
//  ZenoProfileVisibleListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/14.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoProfileVisibleListView<Item: ZenoProfileVisible,
                                  HeaderLabel: View,
                                  BtnLabel: View>: View {
    let list: [Item]
    let headerLabel: () -> HeaderLabel
    let btnLabel: () -> BtnLabel
    let interaction: (Item) -> Void
    
    @State private var isListFold = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Section {
                if !isListFold {
                    ForEach(list) { item in
                        ZenoProfileVisibleCellView(item: item, label: btnLabel, interaction: interaction)
                    }
                }
            } header: {
                HStack {
                    headerLabel()
                    Spacer()
                    if !list.isEmpty {
                        Button {
                            isListFold.toggle()
                        } label: {
                            Image(systemName: isListFold ? "chevron.down" : "chevron.up")
                        }
                    }
                }
                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
                .font(.footnote)
            }
        }
        .animation(.easeInOut, value: [isListFold])
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(HomeListModifier())
        .onAppear {
            if list.isEmpty {
                isListFold = true
            }
        }
    }
}

struct ZenoProfileVisibleListView_Previews: PreviewProvider {
    static var previews: some View {
        ZenoProfileVisibleListView(list: User.dummy) {
            Text("헤더ㅋ")
        } btnLabel: {
            Text("버튼ㅋ")
        } interaction: { item in
            print(item)
        }
    }
}
