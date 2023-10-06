//
//  CommSettingView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/28.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

class CommSettingViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var groupDescription: String = ""
    @Published var isSearched: Bool = false
    @Published var selectedNumber: Int = 0
}
struct CommSettingView: View {
    let community: Community
    let editMode: EditMode
    @Environment(\.dismiss) var dismiss
    @StateObject private var commSettingVM: CommSettingViewModel = .init()
    @State private var isSelectItem: [Bool] = .init(repeating: false, count: 4)
    @State private var isGroupName: Bool = false
    @State private var isGroupDescription: Bool = false
    @State private var isImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .padding(.trailing, 30)
                }
                .tint(.black)
                Text("\(editMode.title)")
                Spacer()
            }
            .padding()
            Button {
                isImagePicker.toggle()
            } label: {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, alignment: .center)
                    .clipShape(Circle())
                    .background {
                        Circle()
                            .stroke(.gray.opacity(5.0))
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.circle.fill")
                            .font(.title)
                            .tint(.gray)
                    }
            }
            .frame(maxWidth: .infinity)
            .padding()
            Spacer()
                .frame(height: 30)
            VStack(alignment: .leading, spacing: 10) {
                Text("그룹 이름")
                if commSettingVM.groupName.isEmpty {
                    Text("그룹 이름을 입력하세요")
                        .font(.callout)
                        .foregroundStyle(.gray)
                } else {
                    Text(commSettingVM.groupName)
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
            .customTappedViewDesign(isTapped: $isSelectItem[0]) {
                isGroupName.toggle()
            }
            .fullScreenCover(isPresented: $isGroupName) {
                SettingTextFieldView(title: "그룹 이름", value: $commSettingVM.groupName)
            }
            VStack(alignment: .leading, spacing: 0) {
                Toggle("검색 허용", isOn: $commSettingVM.isSearched)
                Text("그룹 이름과 소개를 검색할 수 있게 합니다.")
                    .font(.caption)
            }
            .customTappedViewDesign(isTapped: $isSelectItem[1]) {
                commSettingVM.isSearched.toggle()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("그룹 소개")
                if commSettingVM.groupDescription.isEmpty {
                    Text("그룹 소개를 입력하세요")
                        .font(.callout)
                        .foregroundStyle(.gray)
                } else {
                    Text(commSettingVM.groupDescription)
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
            .customTappedViewDesign(isTapped: $isSelectItem[2]) {
                isGroupDescription.toggle()
            }
            .fullScreenCover(isPresented: $isGroupDescription) {
                SettingTextFieldView(title: "그룹 소개", value: $commSettingVM.groupDescription)
            }
            
            HStack {
                Text("그룹 정원")
                Spacer()
                Picker("groupNum", selection: $commSettingVM.selectedNumber) {
                    // 최소 6명 최대 50명
                    ForEach(6..<51) { number in
                        Text("\(number) 명")
                    }
                }
                .tint(.black)
            }
            .customTappedViewDesign(isTapped: $isSelectItem[3])
            
            Spacer()
        }
        .overlay(ImageMenuView(isPresented: $isImagePicker, selectedImage: $selectedImage))
        .onAppear {
            switch editMode {
            case .addNew:
                break
            case .edit:
                commSettingVM.groupName = community.name
                commSettingVM.groupDescription = community.description
            }
        }
    }
    
    enum EditMode {
        case addNew, edit
        
        var title: String {
            switch self {
            case .addNew:
                return "그룹 만들기"
            case .edit:
                return "그룹 설정"
            }
        }
    }
    
    var image: Image {
        if let img = selectedImage {
            return Image(uiImage: img)
        } else {
            return Image("\(community.imageURL)") // 추후 어떤식으로 이미지 처리할지 미정.
        }
    }
}

struct GroupSettingView_Prieviews: PreviewProvider {
    static var previews: some View {
        CommSettingView(community: Community.dummy[0], editMode: .addNew)
        SettingTextFieldView(title: "그룹 설정", value: .constant("ddd"))
            .previewDisplayName("텍스트변경")
    }
}
