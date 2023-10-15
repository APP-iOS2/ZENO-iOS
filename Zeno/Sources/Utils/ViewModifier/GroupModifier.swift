//
//  GroupListViewModifier.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct GroupCellModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.background)
            .cornerRadius(10)
            .shadow(color: .ggullungColor, radius: 1)
    }
}

struct GroupTFModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .bold()
    }
}

struct GroupManagementTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
    }
}

struct GroupItemDesign: ViewModifier {
    @Binding var isTapped: Bool
    var moreTapAction: () -> Void = {}
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 100)
            .padding(.horizontal)
            .background {
                LinearGradient(
                    gradient: isTapped ? originalGradient : Gradient(colors: [.clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTapped = false
                }
                moreTapAction()
            }
    }
    
    let originalGradient = Gradient(colors: [
        .gray.opacity(0.3),
        .gray.opacity(0.25),
        .gray.opacity(0.23),
        .gray.opacity(0.2)
    ])
}

extension View {
    func groupCell() -> some View {
        modifier(GroupCellModifier())
    }
    
    func groupTF() -> some View {
        modifier(GroupTFModifier())
    }
    
    func gmTitle() -> some View {
        modifier(GroupManagementTitleModifier())
    }
    
    func customTappedViewDesign(isTapped: Binding<Bool>, tapAfterAction: @escaping () -> Void = { }) -> some View {
        modifier(GroupItemDesign(isTapped: isTapped) {
            tapAfterAction()
        })
    }
}
