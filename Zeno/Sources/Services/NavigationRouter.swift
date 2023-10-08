//
//  NavigationRouter.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/08.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import SwiftUI

struct RouterView<T: Hashable, Content: View>: View {
    @ObservedObject
    var router: Router<T>
    
    @ViewBuilder var buildView: (T) -> Content
    var body: some View {
        NavigationStack(path: $router.paths) {
            buildView(router.root)
            .navigationDestination(for: T.self) { path in
                buildView(path)
            }
        }
        .environmentObject(router)
    }
}

final class Router<T: Hashable>: ObservableObject {
    @Published var root: T
    @Published var paths: [T] = []

    init(root: T) {
        self.root = root
    }

    func push(_ path: T) {
        paths.append(path)
    }

    func pop(to: T) {
        guard let found = paths.firstIndex(where: { $0 == to }) else {
            return
        }

        let numToPop = (found..<paths.endIndex).count - 1
        paths.removeLast(numToPop)
    }

    func updateRoot(root: T) {
        self.root = root
    }

    func popToRoot() {
        paths.removeAll()
    }
}

enum Path {
    case A
    case B
    case C
    case D
}
