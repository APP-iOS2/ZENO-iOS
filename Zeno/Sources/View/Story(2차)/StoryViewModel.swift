//
//  StoryViewModel.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/12.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

final class StoryViewModel: ObservableObject {
    private let firebaseManager = FirebaseManager.shared
    private let userSession = Auth.auth().currentUser
    @Published private var story: [Story] = []
    
    func idToImage() {
        
    }
    
    func updateStory(story: Story) async {
        // 인자는 렛인가? ex) story
        do {
            try await firebaseManager.create(data: story)
            self.story.append(story)
            // newStory.userid = userSession.
        } catch {
            debugPrint(#function + "Create 추가 실패")
        }
    }
    
    @MainActor
    func fetchStory(communityID: String) async {
        let alarmRef = Firestore.firestore().collection("Alarm")
            .whereField("communityID", isEqualTo: communityID)
        do {
            let querySnapShot = try await alarmRef.getDocuments()
            self.story.removeAll()
            
            try querySnapShot.documents.forEach { queryDocumentSnapshot in
                _ = try queryDocumentSnapshot.data(as: Alarm.self )
                // self.story.append(tempAlarm)
            }
        } catch {
            print(error)
        }
    }

    func disappearStory() {
    }
}
