//
//  FirebaseManager.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/29.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol CanUseFirebase {
    var id: String { get }
}

extension CanUseFirebase {
    func getPropertyName<T: CanUseFirebase, U>(_ keyPath: KeyPath<T, U>) -> String {
        guard let propertyName = "\(keyPath.debugDescription)".split(separator: ".").last
        else {
            #if DEBUG
            print(#function + ": fail to optional bind")
            #endif
            return ""
        }
        return String(propertyName)
    }
    
    func mirrorToDic() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: Any]()
        
        mirror.children.forEach {
            guard let key = $0.label else {
                #if DEBUG
                print(#function + ": fail to optional bind")
                #endif
                return
            }
            dictionary[key] = $0.value
        }
        return dictionary
    }
}

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
    func create<T: CanUseFirebase>(data: T) async throws where T: Encodable {
        let documentRef = db.collection("\(type(of: data))").document(data.id)
        
        do {
            try await documentRef.setData(data.mirrorToDic())
        } catch {
            throw FirebaseError.failToCreate
        }
    }
    
    func read<T: CanUseFirebase>(type: T.Type, id: String) async -> Result<T, Error> where T: Decodable {
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
    
    func update<T: CanUseFirebase, U: Decodable>(data: T,
                                                 value keyPath: WritableKeyPath<T, U>,
                                                 to: U) async throws {
        let documentRef = db.collection("\(type(of: data))").document(data.id)
        
        do {
            try await documentRef.updateData([data.getPropertyName(keyPath): to])
        } catch {
            throw FirebaseError.failToUpdate
        }
    }
    
    func delete<T: CanUseFirebase>(data: T) async throws {
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
//    func uploadDummyArray<T: CanUseFirebase>(datas: [T]) async where T: Encodable {
//        datas.forEach { data in
//            let collectionRef = db.collection("\(type(of: data))")
//            collectionRef.document(data.id).setData(<#T##documentData: [String : Any]##[String : Any]#>)
//            collectionRef.document(data.id).setData(data.mirrorToDic())
//        }
//    }
}
