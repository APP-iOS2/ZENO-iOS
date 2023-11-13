//
//  ZenoProfileFoldableListView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/14.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoProfileFoldableListView<Item: ZenoProfileVisible,
                                  HeaderLabel: View,
                                  BtnLabel: View>: View {
	@EnvironmentObject var commViewModel: CommViewModel
    @Binding var isListFold: Bool
	var list: [Item]
    let headerLabel: () -> HeaderLabel
    let btnLabel: () -> BtnLabel
    let interaction: (Item) -> Void
    
    @State private var emptyList: [Item] = []
    
    var body: some View {
        LazyVStack(alignment: .center) {
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
            ForEach(isListFold ? emptyList : list) { item in
                ZenoProfileVisibleCellView(item: item,
                                           isBtnHidden: false,
                                           isManager: commViewModel.managerChangeWarning,
                                           label: btnLabel,
                                           interaction: interaction)
            }
        }
        .homeList()
        .onChange(of: isListFold) { _ in
            if isListFold {
                withAnimation {
                    for _ in 0..<emptyList.count {
                        emptyList.removeLast()
                    }
                }
            } else {
                emptyList = list
            }
        }
        .onAppear {
            emptyList = list
            if list.isEmpty {
                isListFold = true
            }
        }
    }
}

struct ZenoProfileVisibleListView_Previews: PreviewProvider {
    static var previews: some View {
        ZenoProfileFoldableListView(isListFold: .constant(true), list: User.dummy) {
            Text("헤더ㅋ")
        } btnLabel: {
            Text("버튼ㅋ")
        } interaction: { item in
            print(item.name)
        }
    }
}
