//
//  DeepLinkJoinModifier.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

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
            
            ZenoKFImageView(comm, ratio: .fit)
                .clipShape(Circle())
                .frame(width: .screenWidth * 0.6)
                .padding(.vertical, 10)
            
            HStack {
                Image(systemName: "person.2.fill")
                Text("\(comm.joinMembers.count)명")
            }
            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 12))
            .padding(.bottom, 2)
            
            Text(comm.description)
                .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 14))
                .padding(.bottom)
            
            ForEach(Btn.allCases) { btn in
                Button {
                    if btn == .join {
                        primaryAction()
                    }
                    isPresented = false
                } label: {
                    HStack {
                        Group {
                            if btn == .join {
                                Text(comm.personnel > comm.joinMembers.count ? btn.title : "인원이 꽉 찼습니다")
                            } else {
                                Text(btn.title)
                            }
                        }
                        .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 16))
                        .foregroundColor(.white)
                        .frame(width: .screenWidth * 0.7, height: .screenHeight * 0.05)
                        .background(
                            Group {
                                if comm.personnel > comm.joinMembers.count {
                                    btn.background
                                } else {
                                    Btn.cancel.background
                                }
                            }
                                .shadow(radius: 3)
                        )
                        .cornerRadius(10)
                    }
                }
                .disabled(comm.personnel <= comm.joinMembers.count && btn == .join)
            }
        }
        .foregroundColor(.white.opacity(0.8))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(width: 300)
        .background {
            ZStack {
                ZenoKFImageView(comm)
                Color.primary.colorInvert()
                    .opacity(0.4)
                Blur(style: .dark)
            }
            .frame(width: .screenWidth * 0.8, height: .screenHeight * 0.75)
            .clipped()
            .cornerRadius(10)
            .shadow(radius: 1, y: 2)
        }
    }
    
    private enum Btn: CaseIterable, Identifiable {
        case join, cancel
        
        var title: String {
            switch self {
            case .join:
                return "Join"
            case .cancel:
                return "Cancel"
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
