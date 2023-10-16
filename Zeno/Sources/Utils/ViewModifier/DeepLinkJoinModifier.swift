//
//  DeepLinkJoinModifier.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct DeepLinkJoinModifier: ViewModifier {
    @Binding var isPresented: Bool
    let comm: Community
    let durring: Double
    let primaryAction: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            ZStack {
                if isPresented {
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .blur(radius: isPresented ? 2 : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            self.isPresented = false // 외부 영역 터치 시 내려감
                        }
                    JoinWithDeepLinkView(
                        isPresented: $isPresented,
                        comm: comm,
                        primaryAction: primaryAction
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(
                isPresented
                ? .easeInOut(duration: durring)
                : .easeInOut(duration: durring),
                value: isPresented
            )
        }
    }
}

struct JoinWithDeepLinkView: View {
    @Binding var isPresented: Bool
    let comm: Community
    let primaryAction: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(comm.name)
                .font(.extraBold(22))
            Text("\(comm.joinMembers.count)명 참여중")
                .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 14))
                .padding(.top, 10)
            ZenoKFImageView(comm, ratio: .fit)
                .clipShape(Circle())
                .frame(width: .screenWidth * 0.6)
                .padding(.vertical, 10)
            Text(comm.description)
                .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 16))
                .padding(.vertical)
            ForEach(Btn.allCases) { btn in
                Button {
                    if btn == .join {
                        primaryAction()
                    }
                    isPresented = false
                } label: {
                    HStack {
                        Text(btn.title)
                            .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 20))
                            .foregroundColor(.white)
                            .frame(width: .screenWidth * 0.7, height: .screenHeight * 0.07)
                            .background(
                                btn.background
                                    .shadow(radius: 3)
                            )
                            .cornerRadius(15)
                    }
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.mainColor)
                .shadow(color: .red, radius: 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.background)
                )
        )
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
                return .mainColor
            case .cancel:
                return .gray
            }
        }
        
        var id: Self { self }
    }
}

extension View {
    func joinWithDeepLink(
        isPresented: Binding<Bool>,
        comm: Community,
        durring: Double = 0.3,
        primaryAction: @escaping () -> Void
    ) -> some View {
        return modifier(
            DeepLinkJoinModifier(
                isPresented: isPresented,
                comm: comm,
                durring: durring,
                primaryAction: primaryAction
            )
        )
    }
}

struct ZenoAlertPreviews: PreviewProvider {
    struct Preview: View {
        @State private var showsAlert = true
        
        var body: some View {
            VStack(spacing: 50) {
                Button {
                    showsAlert = true
                } label: {
                    Text("Alert 보여줘!")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
            }
            .joinWithDeepLink(
                isPresented: $showsAlert,
                comm: .dummy[0]) {
                }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
