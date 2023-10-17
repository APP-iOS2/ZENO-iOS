//
//  UserProfileEdit.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

/// 프로필 수정 View
struct UserProfileEdit: View {
    @EnvironmentObject var mypageVM: MypageViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var nameText: String = ""
    @State private var descriptionText: String = ""
    @State private var isChecking: Bool = false
    @State private var gender: Gender = .male
    @State private var profileImageURL: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePicker: Bool = false
    @State private var isProgressLoading: Bool = false
        
    @ViewBuilder
    private var profileImage: some View {
        if let img = selectedImage {
            Image(uiImage: img)
                .resizable()
                .frame(width: 150, alignment: .center)
                .aspectRatio(contentMode: .fit)
        } else {
            if profileImageURL != KakaoAuthService.shared.noneImageURL {
                KFImage(URL(string: profileImageURL))
                    .cacheOriginalImage()
                    .resizable()
                    .placeholder {
                        Image(asset: ZenoAsset.Assets.zenoIcon)
                            .resizable()
                    }
                    .frame(width: 150, alignment: .center)
                    .aspectRatio(contentMode: .fit)
            } else {
                ZenoKFImageView(User(name: "", gender: gender, kakaoToken: "", coin: 0, megaphone: 0, showInitial: 0, requestComm: []),
                                ratio: .fit,
                isRandom: false)
                .frame(width: 150, alignment: .center)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Circle()
                .frame(width: 150, alignment: .center)
                .foregroundColor(.clear)
                .background(
                    profileImage
                        .clipShape(Circle())
                )
                .background {
                    Circle().stroke(.gray.opacity(5.0))
                }
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.circle.fill")
                        .foregroundStyle(Color.gray)
                        .font(.title)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .onTapGesture {
                    isImagePicker.toggle()
                }
            
            RegistCustomTF(titleText: "이름",
                           placeholderText: "",
                           customText: $nameText,
                           isNotHanguel: $isChecking,
                           textMaxCount: 5,
                           isFocusing: false,
                           isDelBtnAppear: false)
            .disabled(true)
            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 20))
            .foregroundStyle(Color.gray)
             
            RegistCustomTF(titleText: "한줄소개",
                           placeholderText: "50자 내로 간략히 자신을 어필해주세요.",
                           customText: $descriptionText,
                           isNotHanguel: .constant(false),
                           textMaxCount: 50,
                           isFocusing: true)
            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
            
            HStack {
                Text("성별")
                    .frame(width: 60, alignment: .leading)
                Picker("Gender", selection: $gender) {
                    ForEach(Gender.allCases, id: \.self) {
                        Text($0.toString)
                            .tag($0)
                    }
                }
                .tint(.gray)
            }
            .disabled(true)
            .foregroundStyle(Color.gray)
            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 20))
            .padding()
            
            Spacer()
        }
        .contentShape(Rectangle())
        .hideKeyboardOnTap()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                ZenoNavigationBackBtn {
                    dismiss()
                } tailingLabel: {
                    Text("프로필 수정")
                }
                .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 18))
                .tint(.black)
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    if koreaLangCheck(nameText) {
                        if nameText.count >= 2 {
                            Task {
                                await dataUpdate()
                                dismiss()
                            }
                        } else {
                            isChecking.toggle()
                        }
                    }
                } label: {
                    Text("확인")
                }
                .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 18))
                .tint(.black)
            }
        }
        .overlay(
            ImageMenuView(title: "프로필 사진 수정",
                          isPresented: $isImagePicker,
                          selectedImage: $selectedImage)
        )
        .overlay(
            ZStack {
                Color.black.opacity(0.25)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("수정사항이 저장중이에요~")
                        .font(.callout)
                        .bold()
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                    ProgressView()
                        .tint(Color.purple)
                        .bold()
                    Spacer()
                }
                .padding(.top, 20)
            }
            .opacity(isProgressLoading ? 1.0 : 0.0)
        )
        .navigationBarBackButtonHidden()
        .onAppear {
            getUserData()
        }
    }
    
    /// 유저정보 가져와서 세팅.
    private func getUserData() {
        self.nameText = mypageVM.userInfo?.name ?? ""
        self.descriptionText = mypageVM.userInfo?.description ?? ""
        self.gender = mypageVM.userInfo?.gender ?? .female
        self.profileImageURL = mypageVM.userInfo?.imageURL ?? ""
    }
    
    private func dataUpdate() async {
        do {
            if let user = mypageVM.userInfo {
                isProgressLoading = true
                // 이미지 선택해서 바꾼거 storage에 저장하고 URL 반환받아야함.
                if let img = selectedImage {
                    var returnImageURL: String?
                    // 변환로직
                    do {
                        returnImageURL = try await ImageUploader.uploadImage(image: img)
                    } catch {
                        print(#function, "🦕\(error.localizedDescription)")
                    }
                    // 이미지 업데이트 로직
                    if let returnImageURL {
                        try await FirebaseManager.shared.update(data: user.self, value: \.imageURL, to: returnImageURL)
                    }
                }
                
                try await FirebaseManager.shared.update(data: user.self, value: \.description, to: descriptionText)
               
                isProgressLoading = false
            } else {
                print(#function, "🦕User정보가 없음..!! 관리자 호출")
            }
        } catch {
            // toast를 띄워주면 될듯.
            print(#function, "이름변경 Update 실패했음. 다시 시도시키기\n\(error.localizedDescription)")
        }
    }
}

struct UserProfileEdit_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserProfileEdit()
                .environmentObject(MypageViewModel())
        }
    }
}
