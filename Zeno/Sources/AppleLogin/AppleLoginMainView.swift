//
//  AppleLoginMainView.swift
//  Zeno
//
//  Created by 박서연 on 2023/11/26.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import AuthenticationServices

import AuthenticationServices
import SwiftUI
import FirebaseAuth

struct SignInWithAppleButtonCustom: View {
    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                // Customize the request if needed
            },
            onCompletion: { result in
                switch result {
                case .success(let authorization):
                    if let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        // Successfully signed in with Apple
                        authenticateWithFirebase(using: appleCredential)
                    } else {
                        // Handle unexpected authorization type
                        print("Unexpected authorization type")
                    }
                case .failure(let error):
                    // Handle sign-in failure
                    print("Sign-in with Apple failed: \(error.localizedDescription)")
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(width: 280, height: 45)
    }

    private func authenticateWithFirebase(using appleCredential: ASAuthorizationAppleIDCredential) {
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: String(data: appleCredential.identityToken!, encoding: .utf8)!,
            rawNonce: ""
        )

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase authentication failed: \(error.localizedDescription)")
            } else {
                print("Firebase authentication successful")
            }
        }
    }
}

struct AppleLoginMainView_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithAppleButtonCustom()
    }
}
