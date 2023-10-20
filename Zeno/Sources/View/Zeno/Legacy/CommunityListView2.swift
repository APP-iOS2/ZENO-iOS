//
//  CommunityListView2.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/19.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommunityListView2: View {
    @EnvironmentObject private var commViewModel: CommViewModel
    @EnvironmentObject private var zenoViewModel: ZenoViewModel
    
    @Binding var currentIndex: Int
    @Binding var selected: String
    @Binding var useConfentti: Bool
    @Binding var counter: Int
    @Binding var isPlay: PlayStatus
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(commViewModel.joinedComm.indices),
                        id: \.self) { index in
                    Button {
                        currentIndex = index
                    } label: {
                        HStack {
                            ZenoKFImageView(commViewModel.joinedComm[index])
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .padding(.trailing, 10)
                            
                            Text(commViewModel.joinedComm[index].name)
                                .font(selected == commViewModel.joinedComm[index].id ?
                                      ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 16) :
                                        ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
                                .foregroundColor(.primary.opacity(0.7))
                            
                            Spacer()
                            
                            Image(systemName: "checkmark")
                                .opacity(selected == commViewModel.joinedComm[index].id ? 1 : 0)
                                .padding(.trailing, .screenWidth * 0.05)
                        }
                    }
                    
                    .frame(width: .screenWidth * 0.9)
                    .listRowBackground(EmptyView())
                    .id(commViewModel.joinedComm[index].id)
                }
                Text("가라")
                    .padding()
                    .padding()
                    .foregroundColor(.clear)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .overlay {
                HStack {
                    Spacer()
                    Color.primary
                        .colorInvert()
                        .frame(width: .screenWidth * 0.055)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .onChange(of: currentIndex) { newValue in
                withAnimation {
                    proxy.scrollTo(commViewModel.joinedComm[newValue].id, anchor: .center)
                }
            }
        }
        .onAppear {
            print("-----그룹 리스트 뷰-------")
            debugPrint(commViewModel.joinedComm)
            debugPrint(commViewModel.joinedComm.count) }
    }
    
    func select(index: Int) {
        selected = commViewModel.joinedComm[index].id
        
        if zenoViewModel.hasFourFriends(comm: commViewModel.joinedComm[index]) {
            isPlay = .success
        } else {
            isPlay = .lessThanFour
        }
        
        if useConfentti {
            counter += 1
            useConfentti = false
        }
    }
}
