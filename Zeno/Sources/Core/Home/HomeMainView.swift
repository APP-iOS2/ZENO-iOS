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
				Text("하이")
			}
		}
    }// body
}

struct HomeMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainView()
    }
}
