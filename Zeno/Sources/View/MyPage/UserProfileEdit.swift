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
final class UserProfileEditViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var descriptionText: String = ""
    @Published var gender: Gender
    @Published var profileImageURL: String = ""
    
    @Published var isChecking: Bool = false
    @Published var isProgressLoading: Bool = false
    @Published var selectedImage: UIImage?
    @Published var isImagePicker: Bool = false
    
    init(name: String = "",
         descriptionText: String = "",
         gender: Gender = .female,
         isChecking: Bool = false,
         isProgressLoading: Bool = false,
         selectedImage: UIImage? = nil,
         isImagePicker: Bool = false) {
        self.name = name
        self.descriptionText = descriptionText
        self.gender = gender
        self.isChecking = isChecking
        self.isProgressLoading = isProgressLoading
        self.selectedImage = selectedImage
        self.isImagePicker = isImagePicker
    }
}

struct UserProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var mypageVM: MypageViewModel
    @StateObject private var userProfileViewModel = UserProfileEditViewModel()
    
    @ViewBuilder private var profileImage: some View {
        if let img = userProfileViewModel.selectedImage {
            Image(uiImage: img).resizable()
        } else {
            if userProfileViewModel.profileImageURL != KakaoAuthService.shared.noneImageURL {
                KFImage(URL(string: userProfileViewModel.profileImageURL))
                    .cacheOriginalImage()
                    .resizable()
                    .placeholder {
                        Image(asset: ZenoAsset.Assets.zenoIcon)
                            .resizable()
                    }
            } else {
                ZenoKFImageView(User(name: "", gender: userProfileViewModel.gender, kakaoToken: "", coin: 0, megaphone: 0, showInitial: 0, requestComm: []),
                                ratio: .fit,
                isRandom: false)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            profileImage
                .imageCustomSizing()
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.circle.fill")
                        .foregroundStyle(Color.gray)
                        .font(.title)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .onTapGesture {
                    userProfileViewModel.isImagePicker.toggle()
                }
            
            RegistCustomTF(titleText: "이름",
                           placeholderText: "",
                           customText: $userProfileViewModel.name,
                           isNotHanguel: $userProfileViewModel.isChecking,
                           textMaxCount: 5,
                           isFocusing: false,
                           isDelBtnAppear: false)
            .disabled(true)
            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 20))
            .foregroundStyle(Color.gray)
             
            RegistCustomTF(titleText: "한줄소개",
                           placeholderText: "50자 내로 간략히 자신을 어필해주세요.",
                           customText: $userProfileViewModel.descriptionText,
                           isNotHanguel: .constant(false),
                           textMaxCount: 50,
                           isFocusing: true)
            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
            
            HStack {
                Text("성별")
                    .frame(width: 60, alignment: .leading)
                Picker("Gender", selection: $userProfileViewModel.gender) {
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
                    if koreaLangCheck(userProfileViewModel.name) {
                        if userProfileViewModel.name.count >= 2 {
                            Task {
                                await dataUpdate()
                                dismiss()
                            }
                        } else {
                            userProfileViewModel.isChecking.toggle()
                        }
                    }
                } label: {
                    Text("확인")
                }
                .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 18))
                .tint(.primary)
            }
        }
        .overlay(
            ImageMenuView(title: "프로필 사진 수정",
                          isPresented: $userProfileViewModel.isImagePicker,
                          selectedImage: $userProfileViewModel.selectedImage)
        )
        .overlay(
           OverlayView(viewModel: userProfileViewModel)
        )
        .navigationBarBackButtonHidden()
        .onAppear { makeUserInfo() }
    }
    
    func makeUserInfo() {
        let name = mypageVM.userInfo?.name ?? ""
        let gender = mypageVM.userInfo?.gender ?? .female
        let desc = mypageVM.userInfo?.description ?? ""
        let profile = mypageVM.userInfo?.imageURL ?? ""
        
        self.userProfileViewModel.name = name
        self.userProfileViewModel.gender = gender
        self.userProfileViewModel.descriptionText = desc
        self.userProfileViewModel.profileImageURL = profile
    }
    
    func dataUpdate() async {
        do {
            if let user = mypageVM.userInfo {
                userProfileViewModel.isProgressLoading = true
                // 이미지 선택해서 바꾼거 storage에 저장하고 URL 반환받아야함.
                if let img = userProfileViewModel.selectedImage {
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
                
                try await FirebaseManager.shared.update(data: user.self, value: \.description, to: userProfileViewModel.descriptionText)
               
                userProfileViewModel.isProgressLoading = false
            } else {
                print(#function, "🦕User정보가 없음..!! 관리자 호출")
            }
        } catch {
            // toast를 띄워주면 될듯.
            print(#function, "이름변경 Update 실패했음. 다시 시도시키기\n\(error.localizedDescription)")
        }
    }
}

private struct OverlayView: View {
    @ObservedObject var viewModel: UserProfileEditViewModel
    
    fileprivate var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("수정사항이 저장중이에요.")
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
        .opacity(viewModel.isProgressLoading ? 1.0 : 0.0)
    }
}

struct UserProfileEdit_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserProfileEditView(mypageVM: MypageViewModel())
        }
    }
}
