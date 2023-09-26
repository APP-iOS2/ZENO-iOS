//
//  AddNewGroupView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
import PhotosUI

struct AddNewGroupView: View {
    @Binding var detent: PresentationDetent
    @Binding var isPresented: Bool
    
    @Environment(\.dismiss) private var dismiss
    @State private var selection: PhotosPickerItem?
    @State private var selectedImg: Image = Image(systemName: "plus.circle")
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var personnel: Int = 2
    @State private var isGroupSearchable: Bool = true
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            PhotosPicker(selection: $selection) {
                selectedImg
                    .resizable()
                // TODO: frame, radius 상수값으로 픽스?
                    .frame(width: 200, height: 200)
                    .cornerRadius(100)
            }
            Group {
                TextField("그룹 이름", text: $title, prompt: Text("그룹 이름"))
                TextField("그룹 설명", text: $description, prompt: Text("그룹 설명"))
            }
            .groupTF()
            HStack {
                Text("그룹 인원")
                    .bold()
                Spacer()
                Picker("그룹 인원", selection: $personnel) {
                    ForEach(0..<100) { index in
                        // TODO: selection과 index가 안맞아서 예외처리로 뷰 구현했는데 좋은 방법이 있다면 수정 요망
                        if index > 1 {
                            Text("\(index) 명")
                        }
                    }
                }
            }
            Toggle(isOn: $isGroupSearchable) {
                VStack(alignment: .leading) {
                    Text("검색 허용")
                        .bold()
                    Text("그룹 이름과 소개를 검색할 수 있게 합니다.")
                        .font(.caption)
                }
            }
        }
        .font(.title)
        .pickerStyle(.menu)
        .padding()
        .navigationTitle("그룹 만들기")
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
                    // TODO: 그룹 추가 함수
                    isPresented = false
                }
                .disabled(title.isEmpty)
            }
        }
        .onAppear {
            detent = .fraction(1)
        }
        .onDisappear {
            detent = .fraction(0.8)
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

struct AddNewGroupView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        HomeMainView()
            .sheet(isPresented: $isPresented) {
                GroupListView(isPresented: $isPresented)
            }
    }
}
