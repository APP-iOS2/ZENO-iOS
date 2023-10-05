//
//  GroupSettingView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/28.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommunitySettingView: View {
    let community: Community
    
    @Environment(\.dismiss) var dismiss
    @State private var groupName: String = ""
    @State private var groupDescription: String = ""
    @State private var isSearched: Bool = false
    @State private var selectedNumber: Int = 0
    @State private var isSelectItem: [Bool] = .init(repeating: false, count: 4)
    @State private var isGroupName: Bool = false
    @State private var isGroupDescription: Bool = false
    @State private var isImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        var image: Image {
            if let img = selectedImage {
                return Image(uiImage: img)
            } else {
                return Image("\(community.communityImage)") // 추후 어떤식으로 이미지 처리할지 미정.
            }
        }
        
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: { dismiss() }, label: {
                    Image(systemName: "chevron.left")
                        .padding(.trailing, 30)
                })
                .tint(.black)
                
                Text("그룹 설정")
                
                Spacer()
            }
            .padding()
           
            HStack {
                Button(action: {
                    isImagePicker.toggle()
                }, label: {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, alignment: .center)
                        .clipShape(Circle())
                        .background {
                            Circle()
                                .stroke(.gray.opacity(5.0))
                        }
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "camera.circle.fill")
                                .font(.title)
                                .tint(.gray)
                        }
                })
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            Spacer().frame(height: 30)
           
            VStack(alignment: .leading, spacing: 10) {
                Text("그룹 이름")
                Text(groupName)
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
            }
            .customTappedViewDesign(isTapped: $isSelectItem[0]) {
                isGroupName.toggle()
            }
            .fullScreenCover(isPresented: $isGroupName, content: {
                SettingTextFieldView(title: "그룹 이름", value: $groupName)
            })
                                   
            VStack(alignment: .leading, spacing: 0) {
                Toggle("검색 허용", isOn: $isSearched)
                Text("그룹 이름과 소개를 검색할 수 있게 합니다.")
                    .font(.caption)
            }
            .customTappedViewDesign(isTapped: $isSelectItem[1]) {
                isSearched.toggle()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("그룹 소개")
                Text(groupDescription)
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
            .customTappedViewDesign(isTapped: $isSelectItem[2], tapAfterAction: {
                isGroupDescription.toggle()
            })
            .fullScreenCover(isPresented: $isGroupDescription, content: {
                SettingTextFieldView(title: "그룹 소개", value: $groupDescription)
            })
            
            HStack {
                Text("그룹 정원")
                Spacer()
                Picker("groupNum", selection: $selectedNumber) {
                    // 최소 6명 최대 50명
                    ForEach(6..<51) { number in
                        Text("\(number) 명")
                    }
                }
                .tint(.black)
            }
            .customTappedViewDesign(isTapped: $isSelectItem[3])
            
            Spacer()
        }
        .overlay(ImageMenuView(isPresented: $isImagePicker, selectedImage: $selectedImage))
        .onAppear {
            groupName = community.communityName
            groupDescription = community.description
        }
    }
}

/// 그룹 설정 Item View 디자인 Modifier
struct GroupItemDesign: ViewModifier {
    @Binding var isTapped: Bool
    var moreTapAction: () -> Void = {}
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 100)
            .padding(.horizontal)
            .background {
                LinearGradient(
                    gradient: isTapped ? originalGradient : Gradient(colors: [.clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTapped = false
                }
                moreTapAction()
            }
    }
    
    let originalGradient = Gradient(colors: [.gray.opacity(0.3),
                                             .gray.opacity(0.25),
                                             .gray.opacity(0.23),
                                             .gray.opacity(0.2)])
}

extension View {
    func customTappedViewDesign(isTapped: Binding<Bool>, tapAfterAction: @escaping () -> Void = { }) -> some View {
        self.modifier(GroupItemDesign(isTapped: isTapped) {
            tapAfterAction()
        })
    }
}

struct GroupSettingView_Prieviews: PreviewProvider {
    static var previews: some View {
        CommunitySettingView(community: Community.dummy[0])
        SettingTextFieldView(title: "그룹 설정", value: .constant("ddd"))
            .previewDisplayName("텍스트변경")
    }
}
