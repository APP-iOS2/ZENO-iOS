//
//  CommEditView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
import PhotosUI

struct CommEditView: View {
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
    
    let editMode: EditMode
    
    @Binding var detent: PresentationDetent
    @Binding var isPresented: Bool
    
    @Environment(\.dismiss) private var dismiss
    @State private var selection: PhotosPickerItem?
    @Binding var community: Community
	@State private var emptyCommunity: Community = Community.dummy[0]
    @State private var selectedImg: Image = Image(systemName: "plus.circle")
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            PhotosPicker(selection: $selection) {
                // TODO: community.communityImage로 변경
                selectedImg
                    .resizable()
                // TODO: frame, radius 상수값으로 픽스?
                    .frame(width: 200, height: 200)
                    .cornerRadius(100)
            }
            Group {
                TextField("그룹 이름", text: $emptyCommunity.name, prompt: Text("그룹 이름"))
                TextField("그룹 설명", text: $emptyCommunity.description, prompt: Text("그룹 설명"))
            }
            .groupTF()
            HStack {
                Text("그룹 인원")
                    .bold()
                Spacer()
                Picker("그룹 인원", selection: $emptyCommunity.personnel) {
                    ForEach(0..<100) { index in
                        // TODO: selection과 index가 안맞아서 예외처리로 뷰 구현했는데 좋은 방법이 있다면 수정 요망
                        if index > 1 {
                            Text("\(index) 명")
                        }
                    }
                }
                .pickerStyle(.menu)
            }
            Toggle(isOn: $emptyCommunity.isSearchable) {
                VStack(alignment: .leading) {
                    Text("검색 허용")
                        .bold()
                    Text("그룹 이름과 소개를 검색할 수 있게 합니다.")
                        .font(.caption)
                }
            }
        }
        .font(.title)
        .padding()
        .navigationTitle(editMode.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                ZenoNavigationBackBtn {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    switch editMode {
                    case .addNew:
                        // TODO: 그룹 추가 함수
                        break
                    case .edit:
                        community = emptyCommunity
                    }
                    isPresented = false
                }
                .disabled(emptyCommunity.name.isEmpty)
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            switch editMode {
            case .addNew:
                detent = .fraction(1)
            case .edit:
                break
            }
        }
        .onDisappear {
            switch editMode {
            case .addNew:
                detent = .fraction(0.8)
            case .edit:
                break
            }
        }
        .onChange(of: selection) { newValue in
            newValue?.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let success):
                    guard let success,
                          let xmark = UIImage(systemName: "xmark.circle")
                    else { return }
                    selectedImg = Image(uiImage: .init(data: success) ?? xmark)
                case .failure:
                    break
                }
            }
        }
    }
}

struct EditGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CommEditView(editMode: .addNew, detent: .constant(.fraction(0.8)), isPresented: .constant(false), community: .constant(.dummy[0]))
    }
}
