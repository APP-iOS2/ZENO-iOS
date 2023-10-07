//
//  CommSettingView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/28.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommSettingView: View {
    let comm: Community
    let editMode: EditMode
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var commViewModel: CommViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var emptyComm: Community = .emptyComm
    @State private var isSelectItem: [Bool] = .init(repeating: false, count: 4)
    @State private var isValueChanged: Bool = false
    @State private var backActionWarning: Bool = false
    @State private var isGroupName: Bool = false
    @State private var isGroupDescription: Bool = false
    @State private var isImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ZenoNavigationBackBtn {
                        if isValueChanged {
                            backActionWarning = true
                        } else {
                            dismiss()
                        }
                    }
                    .tint(.black)
                    Text("\(editMode.title)")
                        .padding(.leading, 30)
                    Spacer()
                    Button("완료") {
                        Task {
                            switch editMode {
                            case .addNew:
                                await commViewModel.createComm(comm: emptyComm)
                                await userViewModel.joinNewGroup(newID: emptyComm.id)
                            case .edit:
                                await commViewModel.updateComm(comm: emptyComm)
                            }
                            dismiss()
                        }
                    }
                    .disabled(!(!emptyComm.name.isEmpty &&
                                isValueChanged))
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
                ForEach(Array(
                    zip($isSelectItem, isSelectItem.indices)
                ), id: \.1) { $item, index in
                    commSettingItem(index: index)
                        .customTappedViewDesign(isTapped: $item) {
                            commSettingItemAction(index: index)()
                        }
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .overlay(
            ImageMenuView(isPresented: $isImagePicker, selectedImage: $selectedImage)
        )
        .fullScreenCover(isPresented: $isGroupName) {
            SettingTextFieldView(title: "그룹 이름", value: $emptyComm.name)
        }
        .fullScreenCover(isPresented: $isGroupDescription) {
            SettingTextFieldView(title: "그룹 소개", value: $emptyComm.description)
        }
        .onChange(of: emptyComm) { newValue in
            isValueChanged = comm != newValue
        }
        .onAppear {
            switch editMode {
            case .addNew:
                break
            case .edit:
                emptyComm = comm
            }
        }
        .alert("저장되지 않은 변경사항이 있습니다.", isPresented: $backActionWarning) {
            Button("나가기", role: .destructive) {
                backActionWarning = false
                dismiss()
            }
        }
    }
    
    @ViewBuilder
    func commSettingItem(index: Int) -> some View {
        switch index {
        case 0:
            VStack(alignment: .leading, spacing: 10) {
                Text("그룹 이름")
                if emptyComm.name.isEmpty {
                    Text("그룹 이름을 입력하세요")
                        .font(.callout)
                        .foregroundStyle(.gray)
                } else {
                    Text(emptyComm.name)
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
        case 1:
            VStack(alignment: .leading, spacing: 0) {
                Toggle("검색 허용", isOn: $emptyComm.isSearchable)
                Text("그룹 이름과 소개를 검색할 수 있게 합니다.")
                    .font(.caption)
            }
        case 2:
            VStack(alignment: .leading, spacing: 10) {
                Text("그룹 소개")
                if emptyComm.description.isEmpty {
                    Text("그룹 소개를 입력하세요")
                        .font(.callout)
                        .foregroundStyle(.gray)
                } else {
                    Text(emptyComm.description)
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
        case 3:
            HStack {
                Text("그룹 정원")
                Spacer()
                Picker("groupNum", selection: $emptyComm.personnel) {
                    // 최소 6명 최대 50명
                    ForEach(0..<51) { number in
                        if number > 5 {
                            Text("\(number) 명")
                        }
                    }
                }
                .tint(.black)
            }
        default:
            EmptyView()
        }
    }
    
    func commSettingItemAction(index: Int) -> () -> Void {
        switch index {
        case 0:
            return { isGroupName.toggle() }
        case 1:
            return { emptyComm.isSearchable.toggle() }
        case 2:
            return { isGroupDescription.toggle() }
        default:
            return { }
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
            // 추후 어떤식으로 이미지 처리할지 미정.
            return Image(comm.imageURL ?? "")
        }
    }
}

struct GroupSettingView_Prieviews: PreviewProvider {
    static var previews: some View {
        CommSettingView(comm: Community.dummy[0], editMode: .addNew)
        SettingTextFieldView(title: "그룹 설정", value: .constant("ddd"))
            .previewDisplayName("텍스트변경")
    }
}
