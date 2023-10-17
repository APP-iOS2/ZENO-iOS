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
    @State private var nextNavigation: Bool = false
    
    // MARK: 10.17 추가
    @State private var 이용약관: Bool = false
    @State private var 개인정보처리방침: Bool = false
  
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
                Text("제노 회원가입")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 18))
                Spacer()
            }
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
            HStack {
                Spacer()
                Text("필수")
                    .font(.thin(10))
                    .foregroundColor(.red)
                    .padding(.trailing)
                    .offset(y: 5)
            }
            RegistCustomTF(titleText: "* 이름",
                           placeholderText: "실명을 입력해주세요. ex)홍길동, 선우정아",
                           customText: $nameText,
                           isNotHanguel: $isChecking,
                           textMaxCount: 5,
                           isFocusing: true)
            .font(.regular(16))
            
            if isChecking {
                Text(checkingText)
                    .foregroundStyle(Color.red.opacity(0.9))
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            HStack {
                Text("* 성별")
                    .frame(width: 60, alignment: .leading)
                    .font(.regular(16))
                Picker("Gender", selection: $gender) {
                    ForEach(Gender.allCases, id: \.self) { gd in
                        Text(gd.toString)
                            .font(.regular(12))
                            .tag(gd)
                    }
                }
                .tint(.black)
                Spacer()
                Text("필수")
                    .font(.thin(10))
                    .foregroundColor(.red)
            }
            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 20))
            .padding()
            
            RegistCustomTF(titleText: "한줄소개",
                           placeholderText: "50자 내로 간략히 자신을 어필해주세요.",
                           customText: $descriptionText,
                           isNotHanguel: .constant(false),
                           textMaxCount: 50,
                           isFocusing: false)
            .font(.regular(13))
            
            Spacer()
            
            // MARK: 10.17 추가
            Group {
                Spacer()
                
                HStack {
                    Text("회원가입을 위해 아래의 이용약관과 개인정보 처리방침에 동의해주세요")
                        .font(.thin(13))
                }
                Divider()
                    .padding()
                
                VStack(alignment: .leading) {
                    /// 이용약관 동의
                    HStack {
                        Button {
                            이용약관.toggle()
                        } label: {
                            HStack {
                                Image(systemName: 이용약관 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.mainColor)
                                Text("이용약관")
                                Text("(필수)")
                                    .foregroundColor(.red)
                            }
                            .foregroundColor(.primary)
                        }
                        Spacer()
                        
                        /// 이용약관 보러가기
                        Button {
                            // 이용약관 뷰
                        } label: {
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.mainColor)
                        }
                    }
                    .padding(.bottom,10)
                    /// 개인정보 처리방침 동의
                    HStack {
                        Button {
                            개인정보처리방침.toggle()
                        } label: {
                            HStack {
                                Image(systemName: 개인정보처리방침 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.mainColor)
                                Text("개인정보 처리방침")
                                Text("(필수)")
                                    .foregroundColor(.red)
                            }
                            .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        /// 개인정보처리방침 보러가기
                        Button {
                            // 개인정보 처리방침 동의
                        } label: {
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.mainColor)
                        }
                    }
                    
                    Spacer()

                    /// 확인버튼
                    ///
                    Button {
                        if koreaLangCheck(nameText) {
                            if nameText.count >= 2 {
                                isConfirmSheet.toggle()
                            } else {
                                isChecking.toggle()
                            }
                        }
                    } label: {
                        Rectangle()
                            .foregroundColor(nameText.isEmpty || !이용약관 || !개인정보처리방침 ? .gray2 : .mainColor)
                            .frame(width: .screenWidth * 0.9, height: .screenHeight * 0.06)
                            .cornerRadius(10)
                            .overlay {
                                Text("회원가입")
                                    .foregroundColor(nameText.isEmpty || !이용약관 || !개인정보처리방침 ? .gray3 : .white)
                                    .font(.bold(17))
                        }
                    }
                    .disabled(nameText.isEmpty || !이용약관 || !개인정보처리방침)
                    .padding(.top,30)
                }
                .font(.thin(16))
            }
            .padding(.horizontal)
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
        .navigationDestination(isPresented: $nextNavigation) {
            OnboardingMainView()
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
