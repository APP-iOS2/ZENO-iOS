//
//  GroupListViewModifier.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct GroupListViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
            )
            .padding(5)
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
            .bold()
            .font(.title)
    }
}

extension View {
    func groupCell() -> some View {
        modifier(GroupListViewModifier())
    }
    
    func groupTF() -> some View {
        modifier(GroupTFModifier())
    }
    
    func gmTitle() -> some View {
        modifier(GroupManagementTitleModifier())
    }
}
