//
//  HomeMainView.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct HomeMainView: View {
    @State private var isPresented = false
    @State private var isNavigated = false
    
    var body: some View {
		NavigationStack {
			ScrollView {
                Button {
                    isPresented = true
                } label: {
                    HStack {
                        Text("멋쟁이 사자처럼")
                        Image(systemName: "chevron.down")
                        Spacer()
                    }
                    .foregroundColor(.primary)
                    .padding()
                }
			}
            .navigationDestination(isPresented: $isNavigated) {
                AddNewGroupView(isPresented: $isNavigated)
            }
		}
        .sheet(isPresented: $isPresented) {
            GroupListView(isPresented: $isPresented) {
                isNavigated = true
            }
        }
    }// body
}

struct HomeMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainView()
    }
}
