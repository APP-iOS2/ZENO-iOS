//
//  ZenoQuizView.swift
//  Zeno
//
//  Created by gnksbm on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct ZenoQuizView: View {
    let zenoList: [Zeno]
    let allMyFriends: [User]
    let loggedUser: User = .dummy[0]
    @State private var users: [User] = []
    @State private var selected: Int = 0
    @State private var answer: [Alarm] = []
    
    var body: some View {
        VStack(alignment: .center) {
            ProgressView(value: Double(selected + 1), total: Double(zenoList.count)) {
                Text("\(selected + 1) / \(zenoList.count)")
            }
            Text(zenoList[selected].question)
                .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 28))
            Spacer()
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                ForEach(users) { user in
                    Button {
                        selectUser(user: user)
                    } label: {
                        HStack {
                            Image(systemName: "person")
                            Text(user.name)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke()
                        )
                    }
                }
            }
            Button {
                resetUsers()
            } label: {
                Image(systemName: "shuffle")
                    .font(.title)
            }
        }
        .padding()
        .onAppear {
            resetUsers()
        }
    }
    
    func selectUser(user: User) {
        answer.append(.init(sendUserID: loggedUser.id, sendUserName: loggedUser.name, recieveUserID: user.id, recieveUserName: user.name, zenoID: zenoList[selected].id, zenoString: zenoList[selected].question, isPaid: false, createdAt: Date.timeIntervalSinceReferenceDate))
        resetUsers()
        if selected + 1 < zenoList.count {
            selected += 1
        }
    }
    
    func resetUsers() {
        users = Array(allMyFriends.shuffled().prefix(upTo: 4))
    }
}

struct ZenoQuizView_Previews: PreviewProvider {
    static var previews: some View {
        ZenoQuizView(zenoList: Array(Zeno.ZenoQuestions.shuffled().prefix(10)), allMyFriends: User.dummy)
    }
}
