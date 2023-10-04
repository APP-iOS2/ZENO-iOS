//
//  UserProfileEdit.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
import PhotosUI

struct UserProfileEdit: View {
    @Environment(\.dismiss) private var dismiss
    @State var selectedItem: [PhotosPickerItem] = []
    @State var selfDescription: String = ""
    
    var body: some View {
        VStack {
            Image("profile")
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding()
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("프로필 사진 수정")
                    .font(.system(size: 15))
                    .padding()
                    .background(.purple)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            VStack(alignment: .leading) {
                Text("이름")
                    .font(.system(size: 15))
                Text("박서연")
                    .font(.system(size: 25, weight: .semibold))
                    .padding(.bottom, 30)
                Text("한 줄 소개")
                    .font(.system(size: 15))
                HStack {
                    TextField("한 줄 소개 수정", text: $selfDescription)
                        .font(.system(size: 25))
                    Button {
                        selfDescription = ""
                    } label: {
                        Image(systemName: "x.circle")
                    }
                }
            }
            .padding()
            Spacer()
        }
        .navigationTitle("프로필 수정")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct UserProfileEdit_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserProfileEdit()
        }
    }
}
