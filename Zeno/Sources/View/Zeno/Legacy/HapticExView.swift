//
//  HapticExView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/13.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct HapticExView: View {
     var body: some View {
         NavigationView {
             VStack(spacing: 20) {
                 HStack {
                     Image(systemName: "iphone.radiowaves.left.and.right").foregroundColor(.orange)
                     Text("Notification type".uppercased())
                 }
                 .font(.title.bold())
                 Button("warning") { HapticManager.instance.notification(type: .warning) }
                 Button("error") { HapticManager.instance.notification(type: .error) }
                 Button("success") { HapticManager.instance.notification(type: .success) }
                                  
                 Group {
                     HStack {
                         Image(systemName: "iphone.radiowaves.left.and.right").foregroundColor(.orange)
                         Text("impact style".uppercased())
                     }
                         .font(.title.bold())
                     Button("heavy") { HapticManager.instance.impact(style: .heavy) }
                     Button("light") { HapticManager.instance.impact(style: .light) }
                     Button("medium") { HapticManager.instance.impact(style: .medium) }
                     Button("rigid") { HapticManager.instance.impact(style: .rigid) }
                     Button("soft") { HapticManager.instance.impact(style: .soft) }
                 }
             }
         }
     }
 }
 
struct HapticExView_Previews: PreviewProvider {
    static var previews: some View {
        HapticExView()
    }
}
