//
//  AppleLoginViewModel.swift
//  Zeno
//
//  Created by 박서연 on 2023/11/26.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseCore
import AuthenticationServices
import CryptoKit

final class AppleLoginViewModel: ObservableObject, LoginStatusDelegate {
    
    var userVM: UserViewModel = .init()
    
    @Published var result: Result<ASAuthorization, Error>?
    @Published var authResult: AuthDataResult?
    private var credential: OAuthCredential?
    
    var currentNonce: String?
    
    // LoginStatusDelegate 관련 함수
    func login() async -> Bool {
        guard let tempResult = self.result else { return false }
        self.handleSignInWithAppleCompletion(tempResult)
        let credential = await signIn()
        
        if let credential {
            if await checkDuplicationEmail(uid: credential.user.uid) {
                return true
            } else {
                try? await createUser(email: credential.user.email ?? "", passwrod: credential.user.uid, name: "", gender: .unknown, description: "", imageURL: "")
                UserDefaults.standard.set(false, forKey: "nickNameChanged") // 닉네임 변경창 열렸었는지 판단. 여기서 초기설정해줌.
                
                await MainActor.run {
                    print("✔️isNickNameRegistViewPop true")
                    userVM.isNickNameRegistViewPop = true // TabBarView에서 Sheet 오픈
                }
            }
        } else {
            return false
        }
        return true
    }
    
    func checkDuplicationEmail(uid: String?) async -> Bool {
        guard let uid = uid else { return false }
        let temp = await FirebaseManager.shared.readDocumentsWithIDs(type: User.self, ids: [uid])
        print("🚇temp: \(temp)")
        
        if temp.isEmpty {
            return false
        }
        
        return true
    }
    
    @MainActor
    func createUser(email: String,
                    passwrod: String,
                    name: String,
                    gender: Gender,
                    description: String,
                    imageURL: String?
    ) async throws {
        do {
            let user = User(id: passwrod,
                            name: name,
                            gender: gender,
                            imageURL: imageURL,
                            description: description,
                            kakaoToken: "카카오토큰",
                            coin: 0,
                            megaphone: 0,
                            showInitial: 0,
                            requestComm: []
            )
            do {
                try await FirebaseManager.shared.create(data: user)
            } catch {
                print("🦕creatUser에러: \(error.localizedDescription)")
            }
            print("🔵 회원가입 성공")
        } catch {
            print("🔴 회원가입 실패. 에러메세지: \(error.localizedDescription)")
            throw error
        }
    }
    
    func logout() async {
        //
    }
    
    func memberRemove() async -> Bool {
        return true
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationOpenIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        self.currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let failure) = result {
            print(failure.localizedDescription)
        } else if case .success(let success) = result {
            if let appleIDCredential = success.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = self.currentNonce else {
                    fatalError("😈 handleSignInWithAppleCompletion 함수서 에러 발생")
                }
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity toekn!")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print(appleIDToken.debugDescription)
                    return
                }
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                self.credential = credential
            }
        }
    }
    
    func signIn() async -> AuthDataResult? {
        guard let tempCredential = self.credential else { return nil }
        
        return await withCheckedContinuation { continuation in
            Auth.auth().signIn(with: tempCredential) { authResult, error in
                continuation.resume(returning: authResult)
            }
        }
    }
}

@available(iOS 13, *)
// Helper for Apple Login with Firebase
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                )
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}
