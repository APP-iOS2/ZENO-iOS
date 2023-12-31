//
//  CommSettingView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/28.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommSettingView: View {
    let editMode: EditMode
    
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
	@State private var iscompletionBtn: Bool = false
	
	private let throttle: Throttle = .init(delay: 5.0)
    
    var body: some View {
        ScrollView {
			ZStack {
				if iscompletionBtn {
					ProgressView()
				}
				VStack(alignment: .leading, spacing: 0) {
					HStack {
						ZenoNavigationBackBtn {
							if isValueChanged {
								backActionWarning = true
							} else {
								dismiss()
							}
						} tailingLabel: {
							HStack {
								Text("\(editMode.title)")
									.font(.regular(16))
								Spacer()
								Button {
									iscompletionBtn = true
									throttle.run {
										Task {
											switch editMode {
											case .addNew:
												_ = await commViewModel.createComm(comm: emptyComm, image: selectedImage)
											case .edit:
												await commViewModel.updateCommInfo(comm: emptyComm, image: selectedImage)
											}
											dismiss()
										}
									}
								} label: {
									Text("완료")
										.font(.bold(16))
								}
								.disabled(emptyComm.name.isEmpty || !isValueChanged || iscompletionBtn)
								.tint(Color("MainColor"))
							}
						}
					}
					Button {
						isImagePicker.toggle()
					} label: {
						Circle()
							.frame(width: 150, alignment: .center)
							.foregroundColor(.clear)
							.background(
								commImage
									.frame(width: 150)
									.clipShape(Circle())
							)
							.background {
								Circle()
									.stroke(.gray.opacity(5.0))
							}
							.overlay(alignment: .bottomTrailing) {
								Image(systemName: "camera.circle.fill")
									.font(.title)
									.tint(.gray)
							}
							.shadow(radius: 3)
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
        }
		.tint(.mainColor)
        .navigationBarBackButtonHidden()
        .overlay(
            ImageMenuView(title: "그룹 사진 등록",
                          isPresented: $isImagePicker,
                          selectedImage: $selectedImage)
        )
        .fullScreenCover(isPresented: $isGroupName) {
            SettingTextFieldView(title: "그룹 이름", value: $emptyComm.name)
        }
        .fullScreenCover(isPresented: $isGroupDescription) {
            SettingTextFieldView(title: "그룹 소개", value: $emptyComm.description)
        }
        .onChange(of: emptyComm) { newValue in
            if commViewModel.joinedComm.isEmpty {
                isValueChanged = Community.emptyComm != newValue
            }
            guard let currentComm = commViewModel.currentComm else { return }
            isValueChanged = currentComm != newValue
        }
        .onChange(of: selectedImage) { _ in
            isValueChanged = true
        }
        .onAppear {
            switch editMode {
            case .addNew:
                break
            case .edit:
                guard let currentComm = commViewModel.currentComm else { return }
                emptyComm = currentComm
            }
        }
        .alert("저장되지 않은 변경사항이 있습니다.", isPresented: $backActionWarning) {
            Button("나가기", role: .destructive) {
                backActionWarning = false
                dismiss()
            }
			.font(.regular(15))
        }
        .interactiveDismissDisabled()
    }
    
    @ViewBuilder
    func commSettingItem(index: Int) -> some View {
        switch index {
        case 0:
            VStack(alignment: .leading, spacing: 10) {
                Text("그룹 이름")
					.font(.regular(16))
                if emptyComm.name.isEmpty {
                    Text("그룹 이름을 입력하세요")
						.font(.regular(15))
                        .foregroundStyle(.gray)
                } else {
                    Text(emptyComm.name)
                        .font(.regular(15))
                        .foregroundStyle(.gray)
                }
            }
        case 1:
            VStack(alignment: .leading, spacing: 0) {
                Toggle("검색 허용", isOn: $emptyComm.isSearchable)
					.font(.regular(16))
                Text("그룹 이름과 소개를 검색할 수 있게 합니다.")
					.font(.thin(13))
            }
        case 2:
            VStack(alignment: .leading, spacing: 10) {
                Text("그룹 소개")
					.font(.regular(16))
                if emptyComm.description.isEmpty {
                    Text("그룹 소개를 입력하세요")
						.font(.regular(15))
                        .foregroundStyle(.gray)
                } else {
                    Text(emptyComm.description)
						.font(.regular(15))
                        .foregroundStyle(.gray)
                }
            }
        case 3:
            HStack {
                Text("그룹 정원")
					.font(.regular(16))
                Spacer()
                Picker("groupNum", selection: $emptyComm.personnel) {
                    // 최소 6명 최대 50명
                    ForEach(0..<51) { number in
                        if number > 5 {
                            Text("\(number) 명")
                        }
                    }
                }
				.font(.regular(15))
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
                return "그룹 수정"
            }
        }
    }
    
    @ViewBuilder
    var commImage: some View {
        if let img = selectedImage {
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            ZenoKFImageView(emptyComm)
        }
    }
}

struct GroupSettingView_Prieviews: PreviewProvider {
    static var previews: some View {
        CommSettingView(editMode: .addNew)
        SettingTextFieldView(title: "그룹 설정", value: .constant("ddd"))
            .previewDisplayName("텍스트변경")
    }
}
