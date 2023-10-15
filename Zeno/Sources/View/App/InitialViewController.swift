//
//  InitialViewController.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/13.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

class InitialViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

struct InitialStoryBoard: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return InitialViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
