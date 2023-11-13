//
//  GroupSelectView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

enum UserChoice: String, CaseIterable {
    case friends = "친구 목록"
    case badge = "뱃지 현황"
}

final class GroupSelectViewModel: ObservableObject {
    @Published var userSelected: UserChoice = .friends
}

extension GroupSelectViewModel {
    func tapSection(_ userChoice: UserChoice) {
        self.userSelected = userChoice
    }
}

struct GroupSelectView: View {
    @ObservedObject var mypageViewModel: MypageViewModel
    @StateObject private var viewModel = GroupSelectViewModel()
    
    var body: some View {
        LazyVStack(alignment: .trailing, pinnedViews: .sectionHeaders) {
            Section {
                switch viewModel.userSelected {
                case .friends: MypageFriendListView(mypageViewModel: mypageViewModel)
                case .badge: BadgeView(mypageViewModel: mypageViewModel)
                }
            } header: {
                HeaderView(headerViewModel: viewModel)
            }
        }
    }
}

private struct HeaderView: View {
    @ObservedObject var headerViewModel: GroupSelectViewModel
    
    fileprivate var body: some View {
        HStack {
            ForEach(UserChoice.allCases, id: \.self) { choiced in
                HStack {
                    VStack {
                        Text("\(choiced.rawValue)")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 40)
                            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                            .fontWeight(choiced == headerViewModel.userSelected ? .bold : .thin)
                        
                        Capsule()
                            .frame(height: 3)
                            .foregroundColor(choiced == headerViewModel.userSelected ? .primary : .clear)
                    }
                    .onTapGesture {
                        headerViewModel.tapSection(choiced)
                    }
                }
                .foregroundColor(.primary)
                Spacer()
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

struct GroupSelectView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSelectView(mypageViewModel: MypageViewModel())
    }
}
