//
//  HomeMainView.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct HomeMainView: View {
    var body: some View {
		NavigationStack {
			ScrollView {
				// 호호
				ForEach(0..<100) { _ in
					Text("하이루")
						.frame(width: .infinity, height: 30)
				}
				// 호호
				ForEach(0..<100) { _ in
					Text("하이루")
						.frame(width: .infinity, height: 30)
				}
			}
		}
    }// body
}

struct HomeMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainView()
    }
}
