//
//  GroupSideBarView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct GroupSideBarView: View {
    @Binding var isPresented: Bool
    @Binding var groupID: String
    // 현재 알람만 선택이 되어있는지 여부를 따지면 되지만 추후 확장성을 위해 배열로 코딩.
    @State private var clickedButtons: [Bool] = .init(repeating: false, count: 3)
    
    private let widthSizeRate: CGFloat = 0.75   // 지정 너비
    private let buttonSystemImage: [String] = ["rectangle.portrait.and.arrow.forward",
                                               "bell",
                                               "gearshape"]
    
    var body: some View {
        // Group ID를 받아서 알림여부를 가져온다. groupID가 없을때 어떻게 가져오는지는 확인해봐야함.
        @AppStorage(groupID) var isgroupAlarmSaved: Bool =
        UserDefaults.standard.bool(forKey: groupID)
        
        // isgroupAlarmSaved가 true인 경우 index = 1에 있는 알람의 값을 true로 변경해준다.
        if isgroupAlarmSaved {
            clickedButtons = clickedButtons.enumerated().map { (index, element) in
                if index == 1 {
                    return true
                } else {
                    return element
                }
            }
        }
        
        return GeometryReader { geometry in
            ZStack {
                Color.yellow
                
                VStack(alignment: .leading) {
                    Text("멋쟁이 사자처럼")
                    
                    Spacer()
                    
                    HStack(spacing: 100) {
                        ForEach(Array(buttonSystemImage.enumerated()), id: \.element.hash) { index, name in
                            Button(action: {
                                clickedButtons[index].toggle()
                                
                                switch index {
                                case 0:
                                    break
                                case 1: // 그룹별 알림 여부
                                    break
                                case 2:
                                    break
                                default:
                                    break
                                }
                            }, label: {
                                Image(systemName: clickedButtons[index] ? 
                                      "\(name).fill" : 
                                      name)
                            })
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                }
                .padding(10)
            }
            .frame(width: geometry.size.width * widthSizeRate)
            .offset(x: isPresented ? geometry.size.width * (1 - widthSizeRate) : geometry.size.width)  // 누르면 x 위치를 width보다 크게해줘서 화면에서 안보이게 한다.
            .animation(.easeInOut(duration: 0.3), value: isPresented)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct GroupMain: View {
    @State private var isPresented: Bool = false
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea(edges: .bottom)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack {
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Image(systemName: "square.stack.3d.down.right")
                        .foregroundStyle(Color.white)
                        .font(.title3)
                })
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Spacer()
            }
            .padding(20)
        }
        // MARK: - 그룹메인화면에서 이부분만 추가하면 됨. groupID는 선택해서 들어가는 groupID.
        .overlay(
            GroupSideBarView(isPresented: $isPresented, groupID: .constant("mutSa"))
        )
    }
}

struct GroupSideBarView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            GroupMain()
                .previewDisplayName("GroupMain")
            GroupSideBarView(isPresented: .constant(true),
                             groupID: .constant("mutSa"))
        }
    }
}
