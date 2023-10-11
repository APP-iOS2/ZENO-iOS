//
//  MyPageMain.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct MyPageMain: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    
//    private var mypageViewModel = MypageViewModel()
    @State private var isShowingSettingView = false
    @State private var isShowingZenoCoin = true // 첫 번째 뷰부터 시작
    @State private var timer: Timer?
    
    let coinView = CoinView()
    let megaphoneView = MegaphoneView()
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation {
                isShowingZenoCoin.toggle()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        // 유저 프로필 이미지 설정
                        if let imageURLString = userViewModel.currentUser?.imageURL,
                           let imageURL = URL(string: imageURLString) {
                            KFImage(imageURL)
                                .placeholder {
                                    ProgressView()
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .padding()
                        } else {
                            KFImage(URL(string: "https://k.kakaocdn.net/dn/dpk9l1/btqmGhA2lKL/Oz0wDuJn1YV2DIn92f6DVK/img_640x640.jpg"))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .padding()
                        }

                        VStack(alignment: .leading) {
                            HStack {
                                Text(userViewModel.currentUser?.name ?? "이름")
                                    .font(.system(.title3))
                                    .fontWeight(.semibold)
                                
                                NavigationLink {
                                    UserProfileEdit()
                                } label: {
                                    Image(systemName: "greaterthan")
                                }
                            }
                            Text(userViewModel.currentUser?.description ?? " ")
                        }
                        Spacer()
                    }
                    .foregroundColor(.black)
//
                    UserMoneyView()
                        .environmentObject(userViewModel)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            if isShowingZenoCoin {
                                coinView
                                    .environmentObject(userViewModel)
                            } else {
                                megaphoneView
                                    .environmentObject(userViewModel)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 60)
                    }
                    .background(Color.black)
                    .onAppear {
                        startTimer()
                        
                        print("👁️ 유저 커뮤니티 id 정보\(String(describing: userViewModel.currentUser?.commInfoList))")
                    }
                    .onDisappear {
                        print("⏰ 타이머 끝")
                        stopTimer()
                    }
                    GroupSelectView()
                        .foregroundColor(.black)
                        .environmentObject(userViewModel)
                }
            }
            .foregroundColor(.white)
            .navigationTitle("마이제노")
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        MypageSettingView()
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.black)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MyPageMain_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyPageMain()
                .environmentObject(UserViewModel(currentUser: .fakeCurrentUser))
        }
    }
}

extension MyPageMain {
    /*
     @MainActor
     func addRequestComm(comm: Community) async throws {
         guard var currentUser else { return }
         let requestComm = currentUser.requestComm + [comm.id]
         try await firebaseManager.update(data: currentUser.self,
                                          value: \.requestComm,
                                          to: requestComm)
         self.currentUser?.requestComm = requestComm
     }
     */
    func findGroup() {
        guard let currentUser = self.userViewModel.currentUser else { return }
        let test = currentUser.commInfoList
    }
    
    
    func userGroupList() {
        let db = Firestore.firestore()
        
        if let currentUser = userViewModel.currentUser?.commInfoList {
            print("\(currentUser[0].id)")
            db.collection("Community").document(currentUser[0].id).getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    if let fieldValue = data?["name"] as? String {
                        print("fieldValue : \(fieldValue)")
                    } else {
                        print("실패")
                    }
                } else {
                    print("firebase document 존재 오류")
                }
            }
//            for group in currentUser {
//
//            }
        }
    }
}
