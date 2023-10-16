//
//  NickNameRegistView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/10.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

/// 앱 설치 후 첫 회원가입시 사용하는 뷰 ( 실명 적는 란 )
struct NickNameRegistView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var nameText: String = ""
    @State private var descriptionText: String = ""
    @State private var isChecking: Bool = false
    @State private var gender: Gender = .male
    @State private var profileImageURL: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePicker: Bool = false
    @State private var isProgressLoading: Bool = false
    @State private var isConfirmSheet: Bool = false
    
    private var checkingText: String {
        if nameText.count >= 2 {
            return "한글로 입력바랍니다. 영어이름인경우 발음대로 입력. 공백없이 입력."
        } else {
            return "2자 이상 입력해주세요."
        }
    }
    
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
            HStack(spacing: 30) {
                Text("Zeno에 오신걸 환영합니다.")
                Spacer()
                Button {
                    if koreaLangCheck(nameText) {
                        if nameText.count >= 2 {
                            isConfirmSheet.toggle()
                        } else {
                            isChecking.toggle()
                        }
                    }
                } label: {
                    Text("확인")
                }
                .disabled(nameText.isEmpty)
            }
            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 18))
            .padding()
            .tint(.black)
            
            Circle()
                .frame(width: 150, alignment: .center)
                .foregroundColor(.clear)
                .background(
                    profileImage
                        .clipShape(Circle())
                )
                .background {
                    Circle()
                        .stroke(.gray.opacity(5.0))
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
            
            RegistCustomTF(titleText: "* 이름",
                           placeholderText: "실명을 입력해주세요. ex)홍길동, 선우정아",
                           customText: $nameText,
                           isNotHanguel: $isChecking,
                           textMaxCount: 5,
                           isFocusing: true)
            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 20))
            
            if isChecking {
                Text(checkingText)
                    .foregroundStyle(Color.red.opacity(0.9))
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            RegistCustomTF(titleText: "한줄소개",
                           placeholderText: "50자 내로 간략히 자신을 어필해주세요.",
                           customText: $descriptionText,
                           isNotHanguel: .constant(false),
                           textMaxCount: 50,
                           isFocusing: false)
            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
            
            HStack {
                Text("* 성별")
                    .frame(width: 60, alignment: .leading)
                Picker("Gender", selection: $gender) {
                    ForEach(Gender.allCases, id: \.self) { gd in
                        Text(gd.toString)
                            .tag(gd)
                    }
                }
                .tint(.black)
            }
            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 20))
            .padding()
            
            Spacer()
        }
        .contentShape(Rectangle())
        .hideKeyboardOnTap()
        .overlay(
            ImageMenuView(title: "프로필 사진 등록",
                          isPresented: $isImagePicker,
                          selectedImage: $selectedImage)
        )
        .overlay(
            ZStack {
                Color.black.opacity(0.25)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Zeno에 입장중이에요~!\n잠시만 기다려주세요 ^.^")
                        .font(.callout)
                        .bold()
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                    ProgressView()
                        .tint(Color.purple)
                        .bold()
                    Spacer()
                }
                .padding(.top, 40)
            }
            .opacity(isProgressLoading ? 1.0 : 0.0)
        )
        .sheet(isPresented: $isConfirmSheet, content: {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("한번 더 확인해주세요!!")
                        .bold()
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 25))
                    Text("아래정보들은 가입 후에 더이상 수정하실 수가 없습니다.")
                        .font(.footnote)
                        .foregroundStyle(Color.red)
                }
                .padding(.top, 30)
                VStack(alignment: .leading, spacing: 10) {
                    Text("이름 : \(nameText)")
                    Text("성별 : \(gender.toString)")
                }
                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 20))
                .padding(.bottom, 20)
                
                HStack(spacing: 50) {
                    Button {
                        isConfirmSheet.toggle()
                    } label: {
                        Text("취소")
                            .foregroundStyle(Color.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red.opacity(0.9))
                    }
                    
                    Button {
                        Task {
                            isConfirmSheet.toggle()
                            await dataUpdate()
                            dismiss()
                        }
                    } label: {
                        Text("확인")
                            .foregroundStyle(Color.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.purple2)
                    }
                }
                .padding(.horizontal, 5)
                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 20))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .font(.title2)
            .presentationDetents([.fraction(0.3)])
        })
        .onAppear {
            getUserData()
        }
    }
    
    /// 유저정보 가져와서 세팅.
    private func getUserData() {
        self.gender = userVM.currentUser?.gender ?? .female
        self.profileImageURL = userVM.currentUser?.imageURL ?? ""
//        print("이미지 : \(profileImageURL)")
    }
    
    private func dataUpdate() async {
        do {
            if let user = userVM.currentUser {
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
                
                try await FirebaseManager.shared.update(data: user.self, value: \.name, to: nameText)
                try await FirebaseManager.shared.update(data: user.self, value: \.description, to: descriptionText)
                try await FirebaseManager.shared.update(data: user.self, value: \.gender, to: gender)
                UserDefaults.standard.set(true, forKey: "nickNameChanged")
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

struct NickNameRegistView_Previews: PreviewProvider {
    static var previews: some View {
        NickNameRegistView()
            .environmentObject(UserViewModel())
    }
}
