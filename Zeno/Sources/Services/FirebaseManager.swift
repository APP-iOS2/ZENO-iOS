//
//  FirebaseManager.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/29.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol CanUseFirebase: Identifiable {
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
}

final class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    
    private init() { }
    
    func updateValue<T: CanUseFirebase, U: Decodable>(data: T,
                                                      value keyPath: WritableKeyPath<T, U>,
                                                      to: U,
                                                      completion: @escaping (T) -> Void) where T: Codable {
        let collectionRef: CollectionReference = db.collection("\(type(of: data))")
        
        read(type: T.self, id: data.id) { result in
            do {
                var updateData = result
                updateData[keyPath: keyPath] = to
                try collectionRef.document(data.id).setData(from: updateData) { error in
                    guard error == nil else {
                        self.printError(error: error!)
                        return
                    }
                    completion(updateData)
                }
            } catch {
                #if DEBUG
                print(#function + ": fail to .setData()")
                #endif
            }
        }
    }
    
    func updateValueInArray<T: CanUseFirebase, U: Decodable>(data: T,
                                                             value keyPath: WritableKeyPath<T, [U]>,
                                                             to: U,
                                                             completion: @escaping (T) -> Void
    ) where T: Codable, U: CanUseFirebase {
        let collectionRef: CollectionReference = db.collection("\(type(of: data))")
        
        read(type: T.self, id: data.id) { result in
            do {
                var updateData = result
                let values = updateData[keyPath: keyPath]
                guard let index = values.firstIndex(where: { $0.id == to.id }) else {
                    #if DEBUG
                    print(#function + ": fail to optional bind - index")
                    #endif
                    return
                }
                updateData[keyPath: keyPath][index] = to
                try collectionRef.document(data.id).setData(from: updateData) { error in
                    guard error == nil else {
                        self.printError(error: error!)
                        return
                    }
                    completion(updateData)
                }
            } catch {
                #if DEBUG
                print(#function + ": fail to .setData()")
                #endif
            }
        }
    }
    
    func uploadDummyArray<T: CanUseFirebase>(datas: [T]) where T: Encodable {
        datas.forEach { data in
            let collectionRef = db.collection("\(type(of: data))")
            
            do {
                try collectionRef.document(data.id).setData(from: data) { error in
                    guard error == nil else {
                        self.printError(error: error!)
                        return
                    }
                }
            } catch {
                #if DEBUG
                print(#function + ": fail to .setData(from:)")
                #endif
            }
        }
    }
    
    /// 동작하지 않음
    func updateAndaddSnapshot<T: CanUseFirebase, U: Decodable>(data: T,
                                                               value keyPath: WritableKeyPath<T, U>,
                                                               to: U,
                                                               completion: @escaping (U) -> Void) {
        let collectionRef = db.collection("\(type(of: data))")
        let propertyName = data.getPropertyName(keyPath)
        
        update(data: data, value: keyPath, to: to) { _ in
            collectionRef.document(data.id).addSnapshotListener { snapshot, error in
                guard error == nil else {
                    self.printError(error: error!)
                    return
                }
                guard let fbDic = snapshot?.data() else {
                    #if DEBUG
                    print(#function + ": fail to optional bind - [String: Any]")
                    #endif
                    return
                }
                guard let fbAny = fbDic[propertyName] else {
                    #if DEBUG
                    print(#function + ": fail to optional bind - Any")
                    #endif
                    return
                }
                guard let uType = fbAny as? U else {
                    #if DEBUG
                    print(#function + ": fail to optional bind - [Order]")
                    #endif
                    return
                }
                completion(uType)
            }
        }
    }
    
    func addCollectionSnapshotForRest<T: CanUseFirebase>(type: T.Type,
                                                         completion: @escaping ([T]) -> Void) where T: Decodable {
        let collectionRef = db.collection("\(type)")
        
        collectionRef.addSnapshotListener { snapshot, error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            guard let returnArray = snapshot?.documents.map({
                do {
                    return try $0.data(as: T.self)
                } catch {
                    fatalError()
                }
            }) else { return }
            completion(returnArray)
        }
    }
    
    func addCollectionSnapshot<T: CanUseFirebase, U: Decodable>(data: T,
                                                                value keyPath: KeyPath<T, U>,
                                                                completion: @escaping (U) -> Void) where T: Decodable {
        let collectionRef = db.collection("\(type(of: data))")
        var listener: ListenerRegistration?
        
        listener = collectionRef.addSnapshotListener { snapshot, error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            guard let docs = snapshot?.documents else {
                #if DEBUG
                print(#function + ": fail to optional bind - docs")
                #endif
                return
            }
            let myChange = docs.filter {
                do {
                    return try $0.data(as: T.self).id == data.id
                } catch {
                    return false
                }
            }
            if !myChange.isEmpty {
                guard let result = try? myChange[0].data(as: T.self) else {
                    #if DEBUG
                    print(#function + ": fail to optional bind")
                    #endif
                    return
                }
                completion(result[keyPath: keyPath])
            } else {
                listener?.remove()
                #if DEBUG
                print("listener is removed")
                #endif
            }
        }
    }
    
    func addSnapshot<T: CanUseFirebase, U: Decodable>(data: T,
                                                      value keyPath: KeyPath<T, U>,
                                                      completion: @escaping (U) -> Void) {
        let collectionRef = db.collection("\(type(of: data))")
        let propertyName = data.getPropertyName(keyPath)
        
        collectionRef.document(data.id).addSnapshotListener { snapshot, error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            guard let fbDic = snapshot?.data() else {
                #if DEBUG
                print(#function + ": fail to optional bind - [String: Any]")
                #endif
                return
            }
            guard let fbAny = fbDic[propertyName] else {
                #if DEBUG
                print(#function + ": fail to optional bind - Any")
                #endif
                return
            }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: fbAny) else {
                #if DEBUG
                print(#function + ": fail to optional bind - jsonData")
                #endif
                return
            }
            guard let uType = try? JSONDecoder().decode(U.self, from: jsonData) else {
                #if DEBUG
                print(#function + ": fail to optional bind - U")
                #endif
                return
            }
            completion(uType)
        }
    }
    
    func addArraySnapshot<T: CanUseFirebase, U: Decodable>(data: T,
                                                           value keyPath: KeyPath<T, U>,
                                                           completion: @escaping ([U]) -> Void) {
        let collectionRef: CollectionReference = db.collection("\(type(of: data))")
        let propertyName = data.getPropertyName(keyPath)
        
        collectionRef.document(data.id).addSnapshotListener { snapshot, error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            guard let fbDic = snapshot?.data() else {
                #if DEBUG
                print(#function + ": fail to optional bind - [String: Any]")
                #endif
                return
            }
            guard let fbAny = fbDic[propertyName] else {
                #if DEBUG
                print(#function + ": fail to optional bind - Any")
                #endif
                return
            }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: fbAny) else {
                #if DEBUG
                print(#function + ": fail to optional bind - jsonData")
                #endif
                return
            }
            guard let uType = try? JSONDecoder().decode([U].self, from: jsonData) else {
                #if DEBUG
                print(#function + ": fail to optional bind - [U]")
                #endif
                return
            }
            completion(uType)
        }
    }
    
    func create<T: CanUseFirebase>(data: T) where T: Encodable {
        let collectionRef: CollectionReference = db.collection("\(type(of: data))")
        
        do {
            try collectionRef.document(data.id).setData(from: data) { error in
                guard error == nil else {
                    self.printError(error: error!)
                    return
                }
            }
        } catch {
            #if DEBUG
            print(#function + ": fail to .setData(from:)")
            #endif
        }
    }
    
    func create<T: CanUseFirebase>(data: T, completion: @escaping () -> Void) where T: Encodable {
        let collectionRef: CollectionReference = db.collection("\(type(of: data))")
        
        do {
            try collectionRef.document(data.id).setData(from: data) { error in
                guard error == nil else {
                    self.printError(error: error!)
                    return
                }
            }
            completion()
        } catch {
            #if DEBUG
            print(#function + ": fail to .setData()")
            #endif
        }
    }
    
    func read<T: CanUseFirebase>(type: T.Type, id: String, completion: @escaping (T) -> Void) where T: Decodable {
        guard !id.isEmpty else {
            #if DEBUG
            print(#function + "ERROR!!! documentID is Empty")
            #endif
            return
        }
        
        let documentRef = db.collection("\(type)").document(id)
        
        documentRef.getDocument(as: T.self) { result in
            switch result {
            case .success(let success):
                completion(success)
            case .failure(let error):
                self.printError(error: error)
            }
        }
    }
    
    func readProperty<T: CanUseFirebase, U>(data: T, value keyPath: KeyPath<T, U>,
                                            completion: @escaping (U) -> Void) {
        let collectionRef: CollectionReference = db.collection("\(type(of: data))")
        let propertyName = data.getPropertyName(keyPath)
        collectionRef.document(data.id).getDocument { snapshot, error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            guard let fbdic = snapshot?.data() else {
                #if DEBUG
                print(#function + ": fail to optional bind - [String: Any]")
                #endif
                return
            }
            guard let uType = fbdic[propertyName] as? U else {
                #if DEBUG
                print(#function + ": fail to optional bind - [U]")
                #endif
                return
            }
            completion(uType)
        }
    }
    
    func readAllDocument<T: CanUseFirebase>(type: T.Type,
                                            completion: @escaping (T) -> Void) where T: Decodable {
        let collectionRef = db.collection("\(type)")
        
        var idArray: [String] = []
        
        collectionRef.getDocuments { snapshot, error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            guard let allDocs = snapshot?.documents else {
                #if DEBUG
                print(#function + ": fail to optional bind - snapshot?.documents")
                #endif
                return
            }
            allDocs.forEach {
                idArray.append($0.documentID)
            }
            idArray.forEach { id in
                self.read(type: type, id: id) { result in
                    completion(result)
                }
            }
        }
    }
    
    func update<T: CanUseFirebase, U: Decodable>(data: T,
                                                 value keyPath: WritableKeyPath<T, U>,
                                                 to: U,
                                                 completion: @escaping (T) -> Void) {
        let collectionRef: CollectionReference = db.collection("\(type(of: data))")
        let propertyName = data.getPropertyName(keyPath)
        
        collectionRef.document(data.id).updateData([propertyName: to]) { error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            var result = data
            result[keyPath: keyPath] = to
            completion(result)
        }
    }
    
    func insertValue<T: CanUseFirebase, U: Decodable>(data: T,
                                                      insertAt: Int,
                                                      value keyPath: WritableKeyPath<T, [U]>,
                                                      to: U,
                                                      completion: @escaping () -> Void) where T: Encodable {
        let collectionRef: CollectionReference = db.collection("\(type(of: data))")
        
        collectionRef.document(data.id).getDocument { _, error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            var newData = data
            newData[keyPath: keyPath].insert(to, at: insertAt)
            do {
                try collectionRef.document(data.id).setData(from: newData) { error in
                    guard error == nil else {
                        self.printError(error: error!)
                        return
                    }
                    completion()
                }
            } catch {
                #if DEBUG
                print(#function + ": Error - setData(from: newData)")
                #endif
            }
        }
    }
    
    func appendValue<T: CanUseFirebase, U: Decodable>(data: T,
                                                      value keyPath: WritableKeyPath<T, [U]>,
                                                      to: U,
                                                      completion: @escaping (String) -> Void
    ) where T: Encodable, U: CanUseFirebase {
        let collectionRef: CollectionReference = db.collection("\(type(of: data))")
        
        collectionRef.document(data.id).getDocument { _, error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            var newData = data
            newData[keyPath: keyPath].append(to)
            do {
                try collectionRef.document(data.id).setData(from: newData) { error in
                    guard error == nil else {
                        self.printError(error: error!)
                        return
                    }
                    completion(to.id)
                }
            } catch {
                #if DEBUG
                print(#function + ": Error - setData(from: newData)")
                #endif
            }
        }
    }
    
    func addSnapshot<T: CanUseFirebase, U: Decodable>(data: T,
                                                      value keyPath: KeyPath<T, U>,
                                                      resultCompletion: @escaping (U) -> Void,
                                                      completion: @escaping (ListenerRegistration?) -> Void) {
        let collectionRef = db.collection("\(type(of: data))")
        var listener: ListenerRegistration?
        let propertyName = data.getPropertyName(keyPath)
        
        listener = collectionRef.document(data.id).addSnapshotListener { snapshot, error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            guard let fbDic = snapshot?.data() else {
                #if DEBUG
                print(#function + ": fail to optional bind - [String: Any]")
                #endif
                return
            }
            guard let fbAny = fbDic[propertyName] else {
                #if DEBUG
                print(#function + ": fail to optional bind - Any")
                #endif
                return
            }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: fbAny) else {
                #if DEBUG
                print(#function + ": fail to optional bind - jsonData")
                #endif
                return
            }
            guard let uType = try? JSONDecoder().decode(U.self, from: jsonData) else {
                #if DEBUG
                print(#function + ": fail to optional bind - U")
                #endif
                return
            }
            resultCompletion(uType)
            completion(listener)
        }
    }
    
    func insertValueResult<T: CanUseFirebase, U: Decodable>(data: T,
                                                            insertAt: Int,
                                                            value keyPath: WritableKeyPath<T, [U]>,
                                                            to: U,
                                                            completion: @escaping (_ success: U) -> Void
    ) where T: Encodable {
        let collectionRef: CollectionReference = db.collection("\(type(of: data))")
        
        collectionRef.document(data.id).getDocument { _, error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            var newData = data
            newData[keyPath: keyPath].insert(to, at: insertAt)
            do {
                try collectionRef.document(data.id).setData(from: newData) { error in
                    guard error == nil else {
                        self.printError(error: error!)
                        return
                    }
                    completion(to)
                }
            } catch {
                #if DEBUG
                print(#function + ": Error - setData(from: newData)")
                #endif
            }
        }
    }
    
    func delete<T: CanUseFirebase>(data: T, completion: @escaping (T) -> Void) {
        let documentID = data.id
        guard !documentID.isEmpty else {
            #if DEBUG
            print(#function + ": documentID is Empty")
            #endif
            return
        }
        
        let documentRef = db.document("\(type(of: data))/\(documentID)")
        
        documentRef.delete { error in
            guard error == nil else {
                self.printError(error: error!)
                return
            }
            completion(data)
        }
    }
    
    private func printError(error: Error) {
        #if DEBUG
        print(#function + ": \(error.localizedDescription)")
        #endif
    }
}
