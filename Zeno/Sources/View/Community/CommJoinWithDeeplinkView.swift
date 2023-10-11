//
//  CommJoinWithDeeplinkView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/09.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommJoinWithDeeplinkView: View {
    @Binding var isPresented: Bool
    let comm: Community
    
    @EnvironmentObject private var commViewModel: CommViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 5) {
            Text(comm.name)
                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 22))
            Text("\(comm.joinMembers.count)명 참여중")
                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 14))
                .padding(.top, 10)
            Circle()
                .stroke()
                .background(
                    ZenoKFImageView(comm)
                )
                .frame(width: .screenWidth * 0.6, height: .screenHeight / 2)
                .clipShape(Circle())
            Text(comm.description)
                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 16))
                .padding(.vertical)
            ForEach(Btn.allCases) { btn in
                Button {
                    if btn == .join {
                        Task {
                            await commViewModel.joinCommWithDeeplink(commID: comm.id)
                            await userViewModel.joinCommWithDeeplink(comm: comm)
                            try? await userViewModel.loadUserData()
                        }
                    }
                    isPresented = false
                } label: {
                    HStack {
                        Text(btn.title)
                            .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                            .foregroundColor(.white)
                            .frame(width: .screenWidth * 0.9, height: .screenHeight * 0.07)
                            .background(
                                btn.background
                                    .opacity(0.5)
                                    .shadow(radius: 3)
                            )
                            .cornerRadius(15)
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        .padding()
    }
    
    private enum Btn: CaseIterable, Identifiable {
        case join, cancel
        
        var title: String {
            switch self {
            case .join:
                return "가입 하기"
            case .cancel:
                return "취소"
            }
        }
        
        var background: Color {
            switch self {
            case .join:
                return .purple2
            case .cancel:
                return .gray
            }
        }
        
        var id: Self { self }
    }
}

struct CommJoinWithDeeplinkView_Previews: PreviewProvider {
    static var previews: some View {
        CommJoinWithDeeplinkView(isPresented: .constant(true), comm: .dummy[0])
            .environmentObject(CommViewModel())
    }
}
