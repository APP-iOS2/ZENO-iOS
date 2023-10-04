//
//  AuthManager.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/02.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase
import FirebaseCore
import FirebaseStorage
import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@MainActor
final class AuthManager: ObservableObject {
    // MARK: Badge Properties
    /// badges: View에서 실제로 사용되는 뱃지들의 "이름"을 담은 배열
    /// bearimagesDatas: Storage로 부터 다운 받는 Data형식 뱃지 배열, 해당 배열값을 통해 이미지를 보여줄 수 있음
    /// bearBadges: Badge 형식을 담은 뱃지 배열
    /// newBadges: Storage에서 최초로 가져온 뱃지 이미지들이 순서에 맞게 정렬되어 담기는 배열
    @Published var badges: [String] = []
    @Published var bearimagesDatas: [Data] = []
    
    // MARK: firestore references
    /// storageRef: firebase storage 레퍼런스
    /// database: firestore DB 레퍼런스
    /// firebaseAuth: firebase Auth 레퍼런스
    let storageRef = Storage.storage().reference()
    let database = Firestore.firestore()
    let firebaseAuth = Auth.auth()
    
    // MARK: - Functions
    
    // MARK: - 사용 중인 유저의 닉네임을 반환
    func getNickName(uid: String) async throws -> String {
        do {
            let target = try await database.collection("User").document(uid)
                .getDocument()
            
            let docData = target.data()
            
            let tmpName: String = docData?["name"] as? String ?? ""
            
            return tmpName
        } catch {
            throw(error)
        }
    }
    
    // MARK: - 사용 중인 유저의 닉네임을 수정
    func updateUserNickName(uid: String, nickname: String) async throws {
        let path = database.collection("User")
        do {
            try await path.document(uid).updateData(["name": nickname])
        } catch {
            throw(error)
        }
    }
    
    // MARK: - 사용 중인 유저의 이메일을 반환
    func getEmail(uid: String) async throws -> String {
        do {
            let target = try await database.collection( "User").document("\(uid)")
                .getDocument()
            
            let docData = target.data()
            
            let tmpEmail: String = docData?["email"] as? String ?? ""
            
            return tmpEmail
        } catch {
            throw(error)
        }
    }
    
    // MARK: - 사용 중인 유저의 친구목록을 반환
    func getFriends(uid: String) async throws -> [User] {
        do {
            let target = try await database.collection("User").document("\(uid)")
                .getDocument()
            
            let docData = target.data()
            
            let tmpFriends: [User] = docData?["friends"] as? [User] ?? []
            
            return tmpFriends
        } catch {
            throw(error)
        }
    }
    
    // MARK: - 사용 중인 유저의 프로필사진을 반환
    func getProImage(uid: String) async throws -> String {
        do {
            let target = try await database.collection("User").document("\(uid)")
                .getDocument()
            
            let docData = target.data()
            
            let tmpPorImage: String = docData?["proImage"] as? String ?? ""
            
            return tmpPorImage
        } catch {
            throw(error)
        }
    }
    
    // MARK: - 사용 중인 유저의 프로필 사진을 수정
    func updateUserProfileImage(uid: String, image: String) async throws -> Void {
        let path = database.collection("User")
        do {
            try await path.document(uid).updateData(["proImage": image])
        } catch {
            throw(error)
        }
    }
    // MARK: - 유저의 FCM Token을 받아와 추가하기
    func addFcmToken(uid: String, token: String) async throws {
        let path = database.collection("User").document("\(uid)")
        
        do {
            try await path.updateData([
                "fcmToken": token
            ])
        } catch {
            throw(error)
        }
    }
    
    // MARK: - 특정 유저의 FCM Token 반환
    func getFCMToken(uid: String) async throws -> String {
        do {
            let target = try await database.collection("User").document("\(uid)")
                .getDocument()
            
            let docData = target.data()
            
            let tmpToken: String = docData?["fcmToken"] as? String ?? ""
            
            return tmpToken
        } catch {
            throw(error)
        }
    }
    

    
}
