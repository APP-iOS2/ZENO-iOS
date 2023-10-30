//
//  ZenoSideSheetModifier.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/29.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoSideSheetModifier<Label: View>: ViewModifier {
    @Binding var isPresented: Bool
    let durring: Double
    let alignment: Alignment
    let label: () -> Label
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var dragOffset: CGFloat = 0
    
    enum Alignment {
        case leading, trailing
    }
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            ZStack {
                content
                ZStack(alignment: alignment == .trailing ? .bottomTrailing : .bottomLeading) {
                    Group {
                        switch colorScheme {
                        case .light:
                            Color.black
                        case .dark:
                            Color.gray4
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .opacity(isPresented ? 0.3 : 0)
                    .edgesIgnoringSafeArea(.vertical)
                    .onTapGesture {
                        isPresented = false
                    }
                    .opacity(isPresented ? 1 : 0)
                    label()
                        .frame(width: proxy.size.width * 0.8)
                        .background(.background)
                        .background(.red)
                        .offset(x: isPresented ? dragOffset : alignment == .trailing ? proxy.size.width * 0.8 : proxy.size.width * -0.8)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let valueTemp = value.translation.width
                        switch alignment {
                        case .leading:
                            if valueTemp <= 0 {
                                dragOffset = valueTemp
                            }
                        case .trailing:
                            if valueTemp >= 0 {
                                dragOffset = valueTemp
                            }
                        }
                    }
                    .onEnded { value in
                        switch alignment {
                        case .leading:
                            if -value.translation.width > proxy.size.width * 0.4 {
                                isPresented = false
                            }
                        case .trailing:
                            if value.translation.width > proxy.size.width * 0.4 {
                                isPresented = false
                            }
                        }
                        dragOffset = 0
                    }
            )
            .animation(.easeInOut(duration: durring), value: isPresented)
        }
    }
}

extension View {
    func zenoSideSheet<Label: View>(
        isPresented: Binding<Bool>,
        durring: Double = 0.2,
        alignment: ZenoSideSheetModifier<Label>.Alignment = .leading,
        content: @escaping () -> Label
    ) -> some View {
        return modifier(
            ZenoSideSheetModifier(
                isPresented: isPresented,
                durring: durring,
                alignment: alignment,
                label: content)
        )
    }
}

struct ZenoSideSheetPreviews: PreviewProvider {
    struct Preview: View {
        @State private var isPresented = true
        
        var body: some View {
            VStack(spacing: 50) {
                Button {
                    isPresented = true
                } label: {
                    Text("SideSheet!")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
            }
            .zenoSideSheet(isPresented: $isPresented,
                           durring: 0.2,
                           alignment: .leading) {
                CommSideBarView(isPresented: $isPresented)
                    .environmentObject(UserViewModel())
                    .environmentObject(CommViewModel())
            }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
