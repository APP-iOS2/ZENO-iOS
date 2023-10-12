//
//  MegaphoneView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct MegaphoneView: View {
    @EnvironmentObject private var mypageViewModel: MypageViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 30))
                .foregroundColor(.red)
                .fontWeight(.bold)
            Text("확성기가 \(mypageViewModel.userInfo?.megaphone ?? 0)회 남았어요.")
                .foregroundColor(.white)
                .font(.system(size: 20))
        }
//        .frame(width: UIScreen.main.bounds.width, height: 60)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(.black)
    }
}

struct MegaphoneView_Previews: PreviewProvider {
    static var previews: some View {
        MegaphoneView()
            .environmentObject(MypageViewModel())
    }
}
