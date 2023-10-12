//
//  MypageViewModel.swift
//  Zeno
//
//  Created by 박서연 on 2023/10/11.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//
import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class MypageViewModel {    
    func userGroupList() {
        let db = Firestore.firestore()
        
//        if let currentUser = userViewModel.currentUser?.commInfoList {
//            for group in currentUser {
//                db.collection("Community").document(group.id).getDocument { document, error in
//                    if let document = document, document.exists {
//                        let data = document.data()
//
//                        if let fieldValue = data?["name"] as? String {
//                            print("fieldValue : \(fieldValue)")
//                        } else {
//                            print("실패")
//                        }
//                    } else {
//                        print("firebase document 존재 오류")
//                    }
//                }
//            }
//        }
//        return ["ddd", "ddd"]
    }
}
