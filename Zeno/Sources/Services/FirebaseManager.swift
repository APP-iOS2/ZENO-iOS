//
//  FirebaseManager.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/29.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum FirebaseError: Error {
    case emptyID
    case failToCreate
    case failToRead
    case failToUpdate
    case failToDelete
    case failToGetDocuments
    case documentToData
}

final class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    
    private init() { }
    
    // MARK: async
    func create<T: FirebaseAvailable>(data: T) async throws where T: Encodable {
        let documentRef = db.collection("\(type(of: data))").document(data.id)
        
        do {
            try documentRef.setData(from: data)
        } catch {
            throw FirebaseError.failToCreate
        }
    }
    
    func read<T: FirebaseAvailable>(type: T.Type, id: String) async -> Result<T, Error> where T: Decodable {
        guard !id.isEmpty else {
            return .failure(FirebaseError.emptyID)
        }
        
        let documentRef = db.collection("\(type)").document(id)
        
        do {
            return .success(try await documentRef.getDocument(as: T.self))
        } catch {
            return .failure(FirebaseError.failToRead)
        }
    }
    
    func update<T: FirebaseAvailable, U: Decodable>(data: T,
                                                 value keyPath: WritableKeyPath<T, U>,
                                                 to: U) async throws {
        let documentRef = db.collection("\(type(of: data))").document(data.id)
        
        do {
            try await documentRef.updateData([data.getPropertyName(keyPath): to])
        } catch {
            throw FirebaseError.failToUpdate
        }
    }
    
    func delete<T: FirebaseAvailable>(data: T) async throws {
        let documentID = data.id
        guard !documentID.isEmpty else {
            throw FirebaseError.emptyID
        }
        
        let documentRef = db.collection("\(type(of: data))").document(data.id)
        
        do {
            try await documentRef.delete()
        } catch {
            throw FirebaseError.failToDelete
        }
    }
    
    func readDocumentsWithIDs<T>(type: T.Type, ids: [String]) async -> [Result<T, FirebaseError>] where T: Decodable {
        var results: [Result<T, FirebaseError>] = []
        let collectionRef = db.collection("\(type)")
        var values: [String]
        switch ids.isEmpty {
        case true:
            values = ["empty"]
        case false:
            values = ids
        }
        let query = collectionRef.whereField("id", in: values)
        guard let snapshot = try? await query.getDocuments() else { return [.failure(FirebaseError.failToGetDocuments)] }
        for item in snapshot.documents {
            do {
                let result = try item.data(as: T.self)
                results.append(.success(result))
            } catch {
                results.append(.failure(FirebaseError.documentToData))
            }
        }
        return results
    }
    
    func readAllCollection<T>(type: T.Type) async -> [Result<T, FirebaseError>] where T: Decodable {
        var results: [Result<T, FirebaseError>] = []
        let collectionRef = db.collection("\(type)")
        guard let query = try? await collectionRef.getDocuments() else { return [] }
        for docSnapshot in query.documents {
            do {
                let result = try docSnapshot.data(as: T.self)
                results.append(.success(result))
            } catch {
                results.append(.failure(FirebaseError.documentToData))
            }
        }
        return results
    }
    
    func uploadDummyArray<T: FirebaseAvailable>(datas: [T]) where T: Encodable {
        datas.forEach { data in
            let collectionRef = db.collection("\(type(of: data))")
            try? collectionRef.document(data.id).setData(from: data)
        }
    }
}
