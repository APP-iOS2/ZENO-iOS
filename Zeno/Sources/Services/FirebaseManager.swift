//
//  FirebaseManager.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/29.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

enum FirebaseError: Error {
    case emptyID
    case failToCreate
    case failToRead
    case failToUpdate
    case failToDelete
    case failToGetDocuments
    case failToUploadImg
    case failToEncode
    case failToFindContains
    case documentToData
}

/// Firebase Manager 커스텀
final class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    
    private init() { }
    
    // MARK: async
    func create<T: FirebaseAvailable>(data: T) throws where T: Encodable {
        let documentRef = db.collection("\(type(of: data))").document(data.id)
        do {
            try documentRef.setData(from: data)
        } catch {
            throw FirebaseError.failToCreate
        }
    }
    // async mirrorToDic이 - "Unsupported type: __SwiftValue" 런타임에러 유발
//    func create<T: FirebaseAvailable>(data: T) async throws where T: Encodable {
//        let documentRef = db.collection("\(type(of: data))").document(data.id)
//        do {
//            try await documentRef.setData(data.mirrorToDic())
//        } catch {
//            throw FirebaseError.failToCreate
//        }
//    }
    
    @discardableResult
    func createWithImage<T: FirebaseAvailable>(data: T,
                                               image: UIImage
    ) async throws -> T where T: Encodable, T: ZenoProfileVisible {
        var changableData = data
        do {
            let imageURL = try await createImageURL(id: data.id, image: image)
            changableData.imageURL = imageURL
            try await create(data: changableData)
            return changableData
        } catch {
            throw FirebaseError.failToUploadImg
        }
    }
    
    private func createImageURL(id: String, image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.25) else { return nil }
        
        let ref = Storage.storage().reference(withPath: "/images/\(id)")
        
        do {
            _ = try await ref.putDataAsync(imageData)
            let url = try await ref.downloadURL()

            return url.absoluteString
        } catch {
            print("🔴이미지 업로드 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    func createDummyArray<T: FirebaseAvailable>(datas: [T]) where T: Encodable {
        datas.forEach { data in
            let collectionRef = db.collection("\(type(of: data))")
            try? collectionRef.document(data.id).setData(from: data)
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
    
    func readDocumentsWithIDs<T>(type: T.Type,
                                 whereField: String = "id",
                                 ids: [String])
    async -> [Result<T, FirebaseError>] where T: Decodable {
        var results: [Result<T, FirebaseError>] = []
        let collectionRef = db.collection("\(type)")
        var values: [String]
        switch ids.isEmpty {
        case true:
            values = ["empty"]
        case false:
            values = ids
        }
        for piece in values.slice(maxCount: 30) {
            let query = collectionRef.whereField(whereField, in: piece)
            guard let snapshot = try? await query.getDocuments() else { return [.failure(FirebaseError.failToGetDocuments)] }
            for item in snapshot.documents {
                do {
                    let result = try item.data(as: T.self)
                    results.append(.success(result))
                } catch {
                    results.append(.failure(FirebaseError.documentToData))
                }
            }
        }
        return results
    }
    
    func readDocumentsArrayWithID<T>(type: T.Type,
                                     whereField: String = "id",
                                     id: String)
    async -> [Result<T, FirebaseError>] where T: Decodable {
        var results: [Result<T, FirebaseError>] = []
        let collectionRef = db.collection("\(type)")
        var values: String
        switch id.isEmpty {
        case true:
            values = "empty"
        case false:
            values = id
        }
        let query = collectionRef.whereField(whereField, arrayContains: values)
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
    
    func update<T: FirebaseAvailable, U: Encodable>(data: T,
                                                    value keyPath: WritableKeyPath<T, U>,
                                                    to: U) async throws {
        let documentRef = db.collection("\(type(of: data))").document(data.id)
        
        do {
            let dataType = try JSONEncoder().encode(to)
            do {
                let any = try JSONSerialization.jsonObject(with: dataType)
                do {
                    try await documentRef.updateData([keyPath.toString: any])
                } catch {
                    throw FirebaseError.failToUpdate
                }
            } catch {
                do {
                    try await documentRef.updateData([keyPath.toString: to])
                } catch {
                    throw FirebaseError.failToUpdate
                }
            }
        } catch {
            throw FirebaseError.failToEncode
        }
    }
    
    func updateModelPropertyAllCollention<T: FirebaseAvailable, U: Encodable>(
        type: T.Type,
        propertyPath keyPath: WritableKeyPath<T, U>,
        defaultValue: U
    ) async where T: Decodable {
        let collectionRef = db.collection("\(type)")
        var documentIDs: [String] = []
        guard let query = try? await collectionRef.getDocuments() else { return }
        for docSnapshot in query.documents {
            let result = docSnapshot.data()
            guard let any = result["id"],
                  let id = any as? String
            else { return }
            documentIDs.append(id)
        }
        
        await documentIDs.asyncForEach { id in
            do {
                guard let propertyName = "\(keyPath.debugDescription)".split(separator: ".").last else { return }
                let dataType = try JSONEncoder().encode(defaultValue)
                do {
                    let any = try JSONSerialization.jsonObject(with: dataType)
                    do {
                        try await collectionRef.document(id).updateData([propertyName: any])
                    } catch {
                        print(FirebaseError.failToUpdate.localizedDescription)
                    }
                } catch {
                    do {
                        try await collectionRef.document(id).updateData([propertyName: defaultValue])
                    } catch {
                        print(FirebaseError.failToUpdate.localizedDescription)
                    }
                }
            } catch {
                print(FirebaseError.failToEncode.localizedDescription)
            }
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
  
    func searchContains<T: FirebaseAvailable, U>(type: T.Type,
                                                   value keyPath: WritableKeyPath<T, U>,
                                                   searchTerm: String)
    async -> Result<[T], FirebaseError> where T: Decodable {
        let result = db.collection("\(type)").whereField(keyPath.toString, isGreaterThanOrEqualTo: searchTerm)
        do {
            let snapshot = try await result.getDocuments()
            return .success(snapshot.documents.compactMap { try? $0.data(as: T.self) })
        } catch {
            return .failure(.failToFindContains)
        }
    }
  
    /*-------------------------------------------------------------------------------------
        batch 사용법.
       1. createBatch로 batch생성하여 return
       2. updateInBatch, deleteInBatch, setDataInBatch 메서드를 활용하여 생성한 batch에 작업 주입
       3. batchCommit으로 작업 파베서버측으로 보냄.
        (파베서버로 보낸다는건 예상 -> 현기기 오프라인상태에서도 작업이 이루어진다는것을 바탕으로 예상.)
     --------------------------------------------------------------------------------------*/
    
    // TODO: 23.10.22 데이터 삭제랑은 잘 작동하는 듯한데 batchWorkItemCnt의 값이 증가하지 않고 있음. 싱글톤이라고 하나의 데이터를 공유하는게 아닌가..?
    
    /// batch 작업갯수 제한용 카운트 프로퍼티
    private var batchWorkItemCnt: Int = 0
    
    /// 새로운 batch를 생성한다.
    func createBatch() -> WriteBatch {
        self.batchWorkItemCnt = 0 // 초기화
        return db.batch()
    }
    
    /// batch용 Update메서드 -> 모든 data 객체는 id값을 지닌다는 가정.
    func updateInBatch<T: FirebaseAvailable, U: Encodable>(batch: inout WriteBatch,
                                                           data: T,
                                                           value keyPath: WritableKeyPath<T, U>,
                                                           to: U) -> Bool {
        let documentID = data.id
        guard !documentID.isEmpty else {
            print(#function, "👀 documentID가 존재하지않습니다.")
            return false
        }
        
        let documentRef = db.collection("\(type(of: data))").document(documentID)
        
        do {
            let dataType = try JSONEncoder().encode(to)
            do {
                let any = try JSONSerialization.jsonObject(with: dataType)
                batch.updateData([keyPath.toString: any], forDocument: documentRef)
            } catch {
                batch.updateData([keyPath.toString: to], forDocument: documentRef)
            }
        } catch {
            return false
        }
        
        self.batchWorkItemCnt += 1 // 작업 한개당 카운트 1 증가
        print(#function, "👀 \(self.batchWorkItemCnt)개")
        return true
    }
    
    /// batch용 Delete메서드 -> 모든 data 객체는 id값을 지닌다는 가정.
    func deleteInBatch<T: FirebaseAvailable>(batch: inout WriteBatch, data: T) -> Bool {
        let documentID = data.id
        guard !documentID.isEmpty else {
            print(#function, "👀 documentID가 존재하지않습니다.")
            return false
        }
        
        let documentRef = db.collection("\(type(of: data))").document(documentID)
        batch.deleteDocument(documentRef)
        self.batchWorkItemCnt += 1
        print(#function, "👀 \(self.batchWorkItemCnt)개")
        
        return true
    }
    
    /// batch용 setData메서드 -> 모든 data 객체는 id값을 지닌다는 가정.  23.10.24 기준 미완성. (잘 안쓰여서 좀 미뤘음)
    func setDataInBatch<T: FirebaseAvailable>(batch: inout WriteBatch, data: T) -> Bool where T: Encodable {
        let documentID = data.id
        guard !documentID.isEmpty else {
            print(#function, "👀 documentID가 존재하지않습니다.")
            return false
        }
        
        let documentRef = db.collection("\(type(of: data))").document(documentID)
        
        do {
            _ = try JSONEncoder().encode(data)
            batch.setData(["": ""], forDocument: documentRef)
        } catch {
            return false
        }
        
        self.batchWorkItemCnt += 1
        print(#function, "👀 \(self.batchWorkItemCnt)개")
        
        return true
    }
    
    /// batch 커밋 -> 최대 500개한도 내에서 처리해야함.
    func batchCommit(batch: WriteBatch) async throws -> Bool {
        // 500개 초과하면 작업 못함.
        guard self.batchWorkItemCnt <= 500 else { return false }
        print(#function, "👀 batchCount = \(batchWorkItemCnt)")
        do {
            try await batch.commit()
            self.batchWorkItemCnt = 0   // 초기화
            return true
        } catch {
            print(#function, "👀👺" + error.localizedDescription)
            throw error
        }
    }
    
    func readDocumentsWithValues<T: FirebaseAvailable, U>(
        type: T.Type,
        keyPath1: KeyPath<T, U>,
        value1: String,
        keyPath2: KeyPath<T, U>,
        value2: String
    ) async -> [T] where T: Decodable {
        do {
            let snapshot = try await db.collection("\(type)")
                .whereField(keyPath1.toString, isEqualTo: value1)
                .whereField(keyPath2.toString, isEqualTo: value2)
                .getDocuments()
//                .whereFilter(
//                    .andFilter([
//                        // 커뮤니티 아이디 == 알람의 COMMID
//                        .whereField(keyPath1.toString, isEqualTo: value1),
//                        // 유저 아이디 == 알람의 showID
//                        .whereField(keyPath2.toString, isEqualTo: value2)
//                    ])
//                )
            return snapshot.documents.compactMap { try? $0.data(as: T.self) }
        } catch {
            return []
        }
    }
}
