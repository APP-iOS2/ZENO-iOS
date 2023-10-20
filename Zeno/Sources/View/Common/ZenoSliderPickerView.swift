//
//  ZenoSliderPickerView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

protocol SliderPickerProtocol: Identifiable, CaseIterable {
    var title: String { get }
}

extension SliderPickerProtocol {
    var id: Self { self }
}

enum SliderTest: SliderPickerProtocol {
    case a, b, c, d, e, f
    
    var title: String {
        switch self {
        case .a:
            return "a"
        case .b:
            return "b"
        case .c:
            return "c"
        case .d:
            return "d"
        case .e:
            return "e"
        case .f:
            return "f"
        }
    }
}

struct ZenoSliderPickerView<Item: SliderPickerProtocol>: View {
    let items: [Item]
    let maxItemRatio = 5
    let interaction: (Item) -> Void
    
    @State private var selected = ""
    @State private var volume: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack(spacing: .zero) {
                ForEach(items) { item in
                    Button {
                        selected = item.title
                        interaction(item)
                    } label: {
                        Text(item.title)
                            .frame(width: items.count < 5 ? .screenWidth / CGFloat(items.count) : .screenWidth / 5)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .overlay {
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: items.count < maxItemRatio ? .screenWidth / CGFloat(items.count) : .screenWidth / CGFloat(maxItemRatio), height: proxy.size.height)
                        .offset(x: proxy.frame(in: .global).width / CGFloat(items.count) * volume, y: proxy.frame(in: .local).minY)
                        .foregroundColor(.purple2)
                        .opacity(0.4)
                }
            }
            GeometryReader { proxy in
                Capsule()
                    .frame(width: items.count < maxItemRatio ? .screenWidth / CGFloat(items.count) : .screenWidth / CGFloat(maxItemRatio), height: 3)
                    .offset(x: proxy.frame(in: .global).width / CGFloat(items.count) * volume, y: proxy.frame(in: .local).minY)
            }
        }
        .onChange(of: selected) { newValue in
            guard let value = items.firstIndex(where: { $0.title == newValue }) else { return }
            withAnimation {
                volume = CGFloat(value)
            }
        }
    }
}

struct ZenoSliderPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.horizontal) {
            ZenoSliderPickerView(items: SliderTest.allCases) { _ in  
            }
        }
    }
}
